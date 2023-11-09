---
layout: article
title: Binding data without RxSwift ( 번역 )
tags:
- iOS
- Swift
- RxSwift
- DataBinding
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

라이브러를 하나 만드려고 하는데 RxSwift 없이 데이터 바인딩을 하고 싶다...

<!--more-->

# Binding data without RxSwift ( 번역 )

## 1. Introduction

사내에서 기존 `그룹웨어` 앱과 형제같은 `경영지원` 앱을 개발하게 되었다. 형재같은 앱이다 보니까 기본적인 디자인 컨셉이 비슷했다. 그래서 팀내에서 제안이 들어왔다.

**김아무개:** 어차피 이후에도 `경영지원` 같은 형제 앱들을 만들게 될 수 도 있으니 공통되는 UI Component를 라이브러리로 분리하는건 어떨까요? 

다들 위 제안에 공감했고 내가 공통되는 UI Component를 라이브러리로 분리하여 `경영지원` 앱과 `그룹웨어` 앱에 모두 적용시키기로 하였다. 

그런데 여기서 한 가지 고민사항이 있었다. 라이브러리로 분리를 하게 된다면 다른 라이브러리에 대한 의존성을 모두 제거해야 하는 것이 아닌가? 

가령 UI 라이브러리를 만든다고 하면 Layout 을 그릴 때는 `SanpKit`을 사용하고 싶고 Binding을 할 때에는 `Rx`를 사용하고 싶을텐데, 내가 만들려고 하는 라이브러리가 다른 외부 라이브러릴를 사용하게 되면 추후에도 계속 의존성 관리를 해야 하는 비용이 발생될꺼라 생각되었다. 

SnapKit과 Rx만 사용한다면 라이브러가 버전업 될 때마다 마이그레이션을 하면 될테지만 독립적인 하나의 라이브러리를 만들고 싶은 마음에 모든 서드파티 라이브러리를 제외하는 것으로 결정하였다. 

그래서 오늘은 Rx를 사용하지 않고 ViewBinding을 구현하고자 관련 간단한 포스트를 번역하고자 한다~ 

## 2. Contents

[Binding data without RxSwift](https://brunomunizaf.medium.com/binding-data-without-rxswift-8dda15fdcd2c)

### Boxing

setter 들을 overriding 통해 Observable 을 구현할 수 있다. MVVM의 전반적인 코드들을 리팩토링하는 대신 가장 관심있을 Boxing 이라는 객체의 구현체를 소개해보려고 한다. 이 객체는 generics type T를 통해 랩핑된다. 그리고 Boxing의 값이 변경될 때마다 closure를 업데이트하고 값을 방출한다.

```swift
// Boxing.swift

final class Box<T> {
  var listener: ((T) -> Void)?
  var value: T {
    didSet { listener?(value) }
  } 

  init(_ value: T) {
    self.value = value
  }

  func bind(listener: ((T) -> Void)?) {
    self.listener = listener
    listener?(value)
  }
}
```

위와 같은 코드는 view와 관련된 코드 (view 또는 viewController)와 로직들이 완전히 분리될 수 있기 때문에 훌륭하다. 엄밀히 말하면 view 관련 코드는 view와 action들을 다루는 일들만 하도록 해야 한다. 위의 Box 는 값이 증가했는지, 감소했는지 혹은 UILabel에 무슨 text가 사용되었는지 알지 못한다. 모든 로직들은 ViewModel에 구현되어 있다. 이것들은 간단한 예시이지만 핵심포인트는 ViewController에는 테스트 할 어떤 것도 존재하지 않게 한다는 것이다. 

```swift
// ViewController.swift
import UIKit

final class ViewController: UIViewController {
    // MARK: UI
    let label = UILabel()
    let incrementButton = UIButton()
    let decrementButton = UIButton()

    // MARK: Properties
    let viewModel = ViewModel()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Setup
        view.addSubview(label)
        view.addSubview(incrementButton)
        view.addSubview(decrementButton)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        incrementButton.backgroundColor = .red
        incrementButton.setTitle("Increment", for: .normal)
        incrementButton.translatesAutoresizingMaskIntoConstraints = false
        incrementButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        incrementButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        incrementButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100).isActive = true
        incrementButton.addTarget(self, action: #selector(viewModel.increment), for: .touchUpInside)

        decrementButton.backgroundColor = .red
        decrementButton.setTitle("Decrement", for: .normal)
        decrementButton.translatesAutoresizingMaskIntoConstraints = false
        decrementButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100).isActive = true
        decrementButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 100).isActive = true
        decrementButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -100).isActive = true
        decrementButton.addTarget(self, action: #selector(viewModel.decrement), for: .touchUpInside)

        // MARK: Binding
        viewModel.countBox.bind { [weak self] in
            self?.label.text = "\($0)"
        }
    }
}
```

코드의 increase, decrease 기능은 ViewModel을 통해 테스트가 가능하다. 

### ViewModel

```swift
// ViewModel.swift
final class ViewModel {
    let countBox: Box<Int> = Box(0)

    @objc func increment() {
        countBox.value += 1
    }

    @objc func decrement() {
        countBox.value -= 1
    }
}
```

### Test

```swift
// DataBindingTests.swift
import XCTest

@testable import DataBindings

final class DataBindingsTests: XCTestCase {
    var sut: ViewModel!

    override func setUp() {
        sut = ViewModel()
    }

    func test_Increment() {
        var value: Int!
        sut.countBox.bind { value = $0 }
        sut.increment()

        XCTAssertEqual(value, 1)
    }

    func test_Decrement() {
        var value: Int!
        sut.countBox.bind { value = $0 }
        sut.decrement()

        XCTAssertEqual(value, -1)
    }
}
```

# 3. Review

위 포스트의 데이터 바인딩 처리는 간단한 ViewBinding에는 무리없이 사용할 수 있을 것 같다. 

하지만 RxSwift 라이브러리가 강력한 이유는 다양하게 내장된 Observable, Operator, Scheduler 설정 등 수 없이 많은 기능들을 쉽게 사용할 수 있다는 것이다. listener를 간단한 데이터 바인딩이외에 다양한 extension 함수들을 선언하여 사용해야 할 것 같다. 

하지만 내가 필요로 하는건 간단한 ScrollableTabBarView 이기 때문에 위의 포스트를 충분히 활용할 수 있을 것 같다!