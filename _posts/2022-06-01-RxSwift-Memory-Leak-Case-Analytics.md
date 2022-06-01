---
layout: article
title: RxSwift Memory Leak Case Analytics
tags:
- iOS
- Swift
- RxSwift
- Memory
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

RxSwift를 사용하다보면 순환참조로 인한 메모리 누수가 자주 일어나는데... 오늘 케이스 분석을 통해 같은 실수를 반복하지 말도록 해보아요...


<!--more-->

# RxSwift 순환참조 방지하기

RxSwift를 사용하면서 Memory Leak 이 빈번하게 발생된다. 코드를 작성할 때부터 신경써서 작성하지 않으면 순환참조 늪에 빠지게 된다. 

그래서 오늘은 직접적으로 경험한 사례들을 기반으로 Memory Leak 을 해결하는 방법에 대해 공유하려고 한다. 
<br><br>
## 순환참조 원인

순환참조는 기본적으로 상호간의 참조로 인하여 Memory Leak 의 직접적인 원인이다. 

`ViewController` -> `disposeBag` -> `subscription` -> `self(ViewController)`

위와 같은 형태로 보통 순환참조가 발생된다.

이 것을 해결하기 위하여 보통 [weak self] 또는 RxSwift에서 제공하는 withUnretained 메소드를 사용하기도 한다. 그리고 최근에는 subscribe(with:_) 를 통해 약한 참조를 걸 수 있도록 RxSwift에서 제공해주고 있다. 

```swift
public func bind<Object: AnyObject>(
        with object: Object,
        onNext: @escaping (Object, Element) -> Void
    ) -> Disposable {
        self.subscribe(onNext: { [weak object] in
            guard let object = object else { return }
            onNext(object, $0)
        },
        onError: { error in
            rxFatalErrorInDebug("Binding error: \(error)")
        })
    }
```

RxSwift에서 bind를 할 때, 클로저내 self의 약한 참조를 지원하기 위하여 with 파라미터를 추가하였다. 
( 이외의 메소드에서도 지원하고 있다. 그런데 왜 do() 메소드에는 지원하지 않고 있는걸까…? )

## 순환참조 코드 개선

### Case 1

**선언형 함수를 사용하자**

```swift
// Before
self.viewModel.gpsButtonIsHidden
	.drive(onNext: { self.gpsButton.rx.isHidden = $0 })
  .disposed(by: self.disposeBag)

// After
self.viewModel.gpsButtonIsHidden
  .drive(gpsButton.rx.isHidden)
  .disposed(by: self.disposeBag)
```

bind를 하는 경우 항상 클로저 함수를 넣어야 하는 것은 아니다. 

위와같이 바인딩 하는 과정에 클로저를 사용하지 않고 함수 선언으로 코드를 구현할 수 있다. 
<br><br>
### Case 2

```swift
// Before
rootView.contentView.menuErrorView.clickedRetryButton
    .emit(with: self, onNext: { (owner, _) in
        _ = owner._menuRepository.updateMenuItems()
            .do(
                with: self,
                onSubscribe: { (owner) in
                    owner.rootView.contentView.menuErrorView.isLoading = true
                },
                onDispose: { (onwer) in
                    owner.rootView.contentView.menuErrorView.isLoading = false
                }
            )
            .subscribe()
    })
    .disposed(by: disposeBag)

// closure 안에서 self 를 참조해버림..... "with: self"

// After
rootView.contentView.menuErrorView.clickedRetryButton
    .emit(with: self, onNext: { (owner, _) in
        _ = owner._menuRepository.updateMenuItems()
            .do(
                onSubscribe: { owner.rootView.contentView.menuErrorView.isLoading = true },
                onDispose: { owner.rootView.contentView.menuErrorView.isLoading = false }
            )
    })
    .disposed(by: disposeBag)
```

( 일단 emit 클로저 안에 새로운 subscribe을 수행하는 것이 조금 불편하지만 당장의 문제를 해결하는 것에 집중해보자… )

Before 코드를 보면 emit(with:_) 메소드를 통해 약한 참조 될 수 있도록 하였다. 하지만 문제는 closure 구문안에 새로운 subscribe 가 있고 do(with:_) 메소드를 또 사용하고 있다. 

그런데 여기서 do(with: self) 메소드가 문제가 된다. 약한 참조를 만들기 위한 코드이지만 emit() closure 안에서 self를 참조하고 말았다.

이렇게 의식없이 코드를 짜면 매일 문제가 생긴다.. 생각은 길게 코드 작성은 짧게….
<br><br>
### Case 3

```swift
// Before
self.action.checkBeaconRecetionStatus
    .do(onNext: { [weak self] in
        self?.processBeaconRecetionStatus()
    })
    .subscribe()
    .disposed(by: disposeBag)

// After
self.action.checkBeaconRecetionStatus
    .subscribe(with: self, onNext: { (owner, _) in
        owner.processBeaconRecetionStatus()
    })
    .disposed(by: disposeBag)
```

해당 코드에서는 순환참조가 발생되진 않았지만, do() 메소드 대신 subscribe 메소드를 사용하자는 취지에서 참조하였다. 
<br><br>
### Case 4

```swift
// Before
let openAction = UIAlertAction(
    title: title,
    style: .default,
    handler: { _ in
        action()
        self.showNextWaitingAlert()
    }
)

// After
let openAction = UIAlertAction(
    title: title,
    style: .default,
    handler: { [weak self] _ in
        action()
        self?.showNextWaitingAlert()
    }
)
```

해당 코드는 자주 실수하는 부분이다. 

```swift
open class UIAlertAction : NSObject, NSCopying {
    public convenience init(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil)
}
```

Action을 생성하려고 할 때 handler에 `@escaping` 키워드가 포함되어 있지 않아 [weak self] 를 사용하지 않는 경우가 있다. 

하지만 AlertAction handler를 보면 `((UIAlertAction) -> Void)?` 타입으로 선언되어 있다. 이 경우 `@escaping` 를 명시할 수 없어서 작성되지 않은 것이지 Optional의 value 값에 탈출 클로저가 담길 수 있는 것이다. 

그러므로 Optional closure인 경우 항상 [weak self] 약한 참조 처리를 해야 한다!

- `@escaping` 클로저는 순환참조를 발생시킬 수 있다.
- `non-escaping` 클로저는 순환참조를 발생시키지 않는다.
<br><br>
### Case 5

```swift
// Before
self.context.items
    .map { (items) in
        items.map { [weak self] (item) in
            TabBarItemButton(item, badge: self?.context.badgeStore.findByAppName(appName: item.menuItem.appName)?.driver)
        }
    }
    .driver
    .drive(onNext: { [weak self] (buttons) in
        self?.itemButtons.accept(buttons)
    })
    .disposed(by: self.disposeBag)

// After
self.context.items
    .map { [weak self] (items) in
        items.map { (item) in
            TabBarItemButton(item, badge: self?.context.badgeStore.findByAppName(appName: item.menuItem.appName)?.driver)
        }
    }
    .driver
    .drive(onNext: { [weak self] (buttons) in
        self?.itemButtons.accept(buttons)
    })
    .disposed(by: self.disposeBag)
```

해당 코드의 경우는 closure의 범위에 따른 [weak self] 처리를 잘못한 경우이다. 

Before 코드에서는 `closure { closure { [weak self] } }` 클로저 내부에 약한 참조를 하고 있기 때문에 결과적으로 순환참조가 발생되었다. 

위와 같은 케이스에서는 `closure { [weak self] closure { } }` 와 같이 외부 클로저에 약한 참조 처리를 해야 한다.