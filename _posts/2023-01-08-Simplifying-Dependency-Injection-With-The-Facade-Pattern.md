---
layout: article
title: 'Simplifying Dependency Injection with the Facade Design Pattern (번역)'
tags:
- iOS
- Swift
- DependencyInjection
- DesignPattern
- ProblemSolving
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

Facade를 이용한 Dependency Injection에 대한 블로그 내용을 번역하고 학습해보려고 합니다.

<!--more-->

참고자료: https://medium.com/@pedroalvarez-29395/ios-simplifying-dependency-injection-with-the-facade-design-pattern-bd863630da32


## 본문
우리가 코드를 작성하면서 의존성을 주입해야 하는 상황이 많이 생기는데 의존성 주입해줘야 하는 대상이 많은 경우 코드가 혼잡스러워 보일 수 있다는 의견으로 시작된다. 

```swift
class SuperClass {
	private let dependency1: Dependency1
	private let dependency2: Dependency2
	private let dependency3: Dependency3
	private let dependency4: Dependency4

	init(
		dependency1: Dependency1,
		dependency2: Dependency2,
		dependency3: Dependency3,
		dependency4: Dependency4
	) {
		self.dependency1 = dependency1
		self.dependency2 = dependency2
		self.dependency3 = dependency3
		self.dependency4 = dependency4
	}
}
```
주입받는 객체들이 많다면 위와 같이 (불편한) 코드들이 만들어질 것이다. 

<br>

위와 같은 문제를 해결하고자 글쓴이는 “`Facade`” 에 대해 언급하였다. 

잠깐 facade에 대해서 간략하게 정리를 하자면 

<aside>
💡 Facade

The **facade pattern** (also spelled *façade*) is a [software-design pattern](https://en.wikipedia.org/wiki/Software_design_pattern) commonly used in [object-oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming). Analogous to a [facade](https://en.wikipedia.org/wiki/Facade) in architecture, a facade is an [object](https://en.wikipedia.org/wiki/Object_(computer_science)) that serves as a front-facing interface masking more complex underlying or structural code.

정리하면… 앞에 외벽의 인터페이스를 하나 두고 나머지 실체는 보이지 않도록 구현하는 디자인 패턴이다.

</aside>

<br>

Facade를 활용하여 의존성을 주입하려고 한다면

### 1번 방법

```swift
protocol DependencyFacade {
	var dependency1: Dependency1 { get }
	var dependency2: Dependency2 { get }
	var dependency3: Dependency3 { get }
	var dependency4: Dependency4 { get }
}

class DefaultDependencyFacade {
	private let dependency1: Dependency1
	private let dependency2: Dependency2
	private let dependency3: Dependency3
	private let dependency4: Dependency4

	init(
		dependency1: Dependency1,
		dependency2: Dependency2,
		dependency3: Dependency3,
		dependency4: Dependency4
	) {
		self.dependency1 = dependency1
		self.dependency2 = dependency2
		self.dependency3 = dependency3
		self.dependency4 = dependency4
	}
}

class SuperClass {
	private let dependencyFacade: DependencyFacade
	
	init(dependencyFacade: DependencyFacade) {
		self.dependencyFacade = dependencyFacade
	}
}
```

### 2번 방법

```swift
protocol HasDependency1 { 
	var dependency1: Dependency1 { get set } 
}
protocol HasDependency2 { 
	var dependency1: Dependency2 { get set } 
} 
protocol HasDependency3 { 
	var dependency1: Dependency3 { get set } 
} 

class SuperClass {
	// Dependencies가 Facade의 역할을 하게됨
	typealias Dependencies = HasDependency1 & HasDependency2 & HasDependency3

	private	let dependencies: Dependencies
	
	init(dependencies: Dependencies) {
		self.dependencies = dependencies
	}
}
```

블로그에서는 위와 같이 `DependencyFacade` 를 따로 구성하여 의존성을 모아주는 역할의 protocol + class 를 사용하였다. 

위의 두 가지 방식으로 구현하게 되면 가장 큰 장점은

```swift
class SuperClass {
	private let dependencyFacade: DependencyFacade
	
	init(dependencyFacade: DependencyFacade) {
		self.dependencyFacade = dependencyFacade
	}
}
```

실제 클래스에서 의존성 관련 코드가 깔끔해진다는 것이다. 또한 의존성의 집합 Facade의 경우 여러 곳에서 재활용될 수 있는 장점도 있다. 

<br>

## Testable code

DependencyFacade 를 통해 여러 depenency의 조합을 만들어 낼 수 있다. 

그리고 각각의 dependency는 쉽게 테스트 할 수 있어야 한다. 

```swift
class SomeTests: XCTestCase {
  var sut: TestingClass?

	override func setUp {
		sut = TestingClass(dependency: DependencyMock)
	}

	func testMethod {
		// Some test
	}
}
```

기존에 dependency protocol 을 정의하였고 typealias를 통해 dependencies 또한 protocol 정의되어 있다. 그렇기 때문에 쉽게 단위 테스트가 가능해진다. 

## 결론

## 

지금까지 논의된 코드는 Facade와 Dependecy Inection 이 두 디자인 패턴이 적용되었다. 위 코드의 목적을 다시 되새겨 보자면 최종적으로 주입된 코드를 사용하는 주체에서 쉽게 코드를 이해하게 하기위함이다.

<br>

실제로 개발을 할 때에도 수많은 `repository`를 주입받은 `ViewModel`을 자주 볼 수 있었다. `Entity` 단위로 repository를 구현하다보면 수 많은 repository가 생기게 된다. 그리고 그 repository는 ViewModel에 주입하여 사용된다. 

<br>

그런데 위와 같은 코드는 위에서 언급한 내용외로 유지보수성이 뛰어난 장점이 있는 것 같다.

<br>

보통 ViewModel에 새로운 repository를 추가혀고 할 때 initialize 부분의 paramter를 수정하게 된다. 그러면 해당 class 또는 struct 부분에서 수정을 해야할 뿐만 아니라 해당 ViewModel을 생성하는 곳에서도 코드를 수정해야 한다. 

<br>

하지만 위의 코드는 그럴 필요 없이 typealias에서 새로운 Dependency protocol을 채택해주기만 하면 된다.