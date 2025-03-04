---
layout: article
title: Swinject Library 에서 ObjectScope 사용시에 발생된 이슈 처리
tags:
- iOS
- Swift
- 'Dependency Injection'
- 'Problem Solving'
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

이전에 Swinject에서 의존성 코드 작성중에 ObjectScope weak 를 사용하다가 발생된 이슈를 정리하려고 한다.

<!--more-->


# Swinject?

Swinject는 swift로 만들어진 경량화된 의존성 주입 프레임워크이다. 

[Swinject Github](https://github.com/Swinject/Swinject)

---

# Swinject의 ObjectScope?

resolve를 통해서 생성된 객체를 유지하려면 어떻게 해야할까? 혹은 생성된 인스턴스의 lifecycle은 어떻게 될까? 해당 부분에 대한 설명은 Object Scope를 통해서 할 수 있다. Swinject 에서 제공하는 Object Scope는 4가지이다.

[Swinject Object Scope Github](https://github.com/Swinject/Swinject/blob/master/Documentation/ObjectScopes.md)

`ObjectScope`는 간단히 설명하면 객체의 생명주기를 다루는 설정 값이다. 

내장되어 있는 `ObjectScope` 에는 크게 4종류가 있다.

1. Transient
2. Graph(default)
3. Container
4. Weak

### 1. Transient
`Transient` 를 사용하는 경우 기본적으로 객체를 공유하지 않는다. register 메소드를 호출 한 후에 resolve를 호출 할 때 마다 새로운 객체들을 생성하고 전달한다. 

    /// A new instance is always created by the `Container` when a type is resolved.
    /// The instance is not shared.
  

### 2. Graph(default)
`Graph` 는 `Transient` 와 유사하게 resolve 메소드 호출시마다 새로운 객체를 생성한다. 하지만 `Transient` 와 다른 점은 Container의 `Factory Closure` 내에서 resolve 하는 경우 객체를 공유한다. 

    /// Instances are shared only when an object graph is being created,
    /// otherwise a new instance is created by the `Container`. This is the default scope.

### 3. Container
`Container` 는 우리가 알고 있는 일반적인 Singleton 객체로 사용할 수 있도록 한다. resolve 메소드 호출시에 최초 한 번만 객체를 생성하고, 그 이후는 기존에 생성된 객체의 주소를 참조하여 객체를 가져온다.

    /// An instance provided by the `Container` is shared within the `Container` and its child `Containers`.

### 4. Weak
`Weak` 는 `strong reference`를 유지하고 있는 동안 객체를 공유한다. 만약 reference가 없다면 항상 새로운 객체를 생성한다. 

    /// An instance provided by the `Container` is shared within the `Container` and its child `Container`s
    /// as long as there are strong references to given instance. Otherwise new instance is created
    /// when resolving the type.
  

Custom ObjectScope를 만드는 방법도 있지만 오늘 정리하려고 하는 내용과 무관하므로 제외하도록 한다...

궁금하다면 밑에 링크에서 직접 확인해보도록 하자~
[Swinject Custom Object Scope Github](https://github.com/Swinject/Swinject/blob/master/Documentation/ObjectScopes.md#custom-scopes)


# Weak 사용시 발생된 이슈
나는 `weak` 를 사용하면서 문제를 맞닥드렸다. 아주 기본적인 개념을 놓칠면서 발생된 실수였다...

### 이슈 정의
: Object Scope로 weak 타입으로 객체를 register하고 특정 class에서 resolve 한 객체를 strong reference를 유지하고 있는 상황에서 다른 객체에서 resolve를 하였는데, 기존의 객체를 공유하는 것이 아닌 새로운 객체를 생성하였다. 

말로는 잘 이해가 안될 수 있으니 코드를 바로 확인해보자.
( 내가 쓴 말이지만 나도 헷갈린다... 글쓰기가 이렇게 어렵습니다 ㅠㅜ)

```swift
/// Container.swift

container.register(WebViewContainer.self, name: WebViewPage.signIn.rawValue) { _ in
      // WebViewContainer의 생성 코드는 임시 코드로 대체한다.
			return WebViewContainer(
				viewController: get(type: .signIn),
				coordinator: get(type: .signIn)
			)
		}.inObjectScope(.weak)
```
먼저 `Container.swift` 에서 `WebViewContainer` 타입을 register 하였다. 

```swift
/// WebViewContainer.swift

import UIKit

public struct WebViewContainer: Hashable {
	public init(
		viewController: WebViewController,
		coordinator: WebViewCoordinator
	) {
		self.viewController = viewController
		self.coordinator = coordinator
	}

	public let viewController: WebViewController
	public let coordinator: WebViewCoordinator
}
```
`WebViewContainer.swift` 는 위와 같이 구성되어 있다.

```swift
/// SampleViewController.swift

public final class SampleViewController {
  ...

	private var signInWebViewContainer: WebViewContainer? = get(WebViewPage.signIn.rawValue)
  // get 메소드는 resolve를 warapping 되어 있는 메소드 이다. 

	...
}

```
위 코드처럼 resolve 메소드를 호출하여 생성된 객체를 `SampleViewController` 프로퍼티로 strong reference 를 만들어 두었다. 


```swift
/// SampleCoordinator.swift
public final class SampleCoordinator: BaseCoordinator {
	func presentWebView(_ webViewPage: WebViewPage) {
		let container: WebViewContainer = get(webViewPage.rawValue)
		childCoordinators.append(container.coordinator)
		container.viewController.modalPresentationStyle = .fullScreen
		navigationController.present(container.viewController, animated: true)
	}
	...
}
```
그리고 화면전환을 위하여 ViewController에서 저장하고 있는 객체를 사용하려고 한다. 

하지만 여기서 기존에 생성한 `WebViewContainer` 객체가 아닌 새로운 객체를 생성하였다...

한 번에 문제가 뭔지 보이는 사람도 있을지 모르지만 나는 이 문제를 해결하기 위하여 오전 시간이 날아갔다...

### 이슈 원인 및 해결
원인은 간단했고, 해결은 더 간단했다...

**resolve 메소드를 호출하여 생성한 객체가 `struct` type 이었기 때문이다.**

기본적으로 기존에 생성된 객체를 공유하려면 heap 메모리에 객체의 주소를 저장해두고 해당 주소값을 이용해 객체에 접근을 해야한다. 
하지만 struct type의 경우 value type 이고 heap memory 에 주소값을 저장하지 않고 참조시마다 값을 복사한다.

iOS를 배우면서 아주 기본적인 개념인 `class` vs `struct` 문제를 직접 겪어보니 뒷통수를 한 대 맞는 기분이었다... 

그래서 코드는 `WebViewContainer` 를 struct에서 class로 수정했고, 이슈는 해결되었다~

이래서 기본이 중요하다고 하는구나... 만약에 class와 struct의 개념조차 잘 모르고 있었다면 문제를 해결하기 더 어려웠을 것 같다는 생각이 들었다. 

---

# 갈무리
기본만이라도 잘 하자...