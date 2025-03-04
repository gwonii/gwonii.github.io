---
layout: article
title: 'RxFlow 에서 Step 에 대한 고민'
tags:
- iOS
- Swift
- Library
- ProblemSolving
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

NHN 회사에는 화면전환 Library로 RxFlow 를 사용하고 있는데 현재 작성된  Step 에 case 들을 보면서 "개선할 수 있는 부분이 있지 않을까?" 라는 질문을 시작으로 글을 써보려고 한다. 

<!--more-->

# 1. 목표
- RxFlow 에서 Step 사용에 있어서 Best Practice 를 찾아보고자 한다. 

# 2. 이유
- RxFlow 에서는 화면전환의 단위를 Step 으로 정의한다. 그런데 Step 을 나누는 기준과 네이밍의 문제점이 있다고 판단하였다.
- 분명한 기준과 네이밍이 있다면 동료 개발자들이 좀 더 편하게 개발을 할 수 있을 것이라고 판단하였다. 

# 3. 실행

## RxFlow란?

RxFlow 를 설명하는 글을 쓰려고 하는 것은 아니므로 간단하게 정리하고 넘어가려고 한다. 

### 정의
**RxFlow is a navigation framework for iOS applications > based on a Reactive Flow Coordinator pattern.**
<br>
: RxFlow는 Coordinator Pattern 을 베이스로 한 RxSwift 로 구성된 화면전환 라이브러리이다. 

### 구성
- `Flow`: 각 flow는 앱 내에서 어디로 이동해야되는 지가 정의되어 있다.
- `Step`: 앱내에서 화면이동 상태(navigation state)를 나타낸다.
- `Stepper`: Step 을 방출하는 역할, 화면전환의 트리거 역할을 한다.
- `Presentable`: 추상화된 UI, 기본적으로 UIViewController 혹은 커스텀된 UI
- `Flowable`: Presentable 과 Stepper 들을 포함한 자료구조
- `Coordinator`: Flows와 Steps를 조합한 후 이것들을 이용하여 일관적으로 화면전환을 하는 역할

## Step 이란?
Step은 RxFlow 에서 제공되는 protocol 이며 이동해야 할 각 화면들의 상태를 의미한다. 

ex) 
```swift
// RxFlow Github Demo
enum DemoStep: Step {
	case userIsLoggedIn
	case userIsLoggedOut
	...
}
```
- `Step` protocol 을 채택한 enum 을 만들고 화면전환에 필요한 case 를 정의한다. 
- 화면전환에 필요한 데이터가 있다면, 연관 데이터를 추가하기도 한다. 
<br>

그리고 `Flow` 에서 `Step` case 에 따라 화면전환 상세 코드를 작성하게 된다.

## Step Case Naming 관점에서 바라본 문제점

현재 RxFlow 를 사용하면서 경험했던 문제들은 **"화면전환이 정상적으로 동작하지 않았다."** 는 것이다...

<br>

좀 더 자세히 얘기하자면, `Reactor` (현재 ReactorKit을 사용하고 있다) 는 `Flow` 을 참조하고 있으면 Step 을 이용하여 화면전환을 Flow 에 요청한다. 
화면전환 라이브러리를 사용하는데 화면전환에 문제가 있다면 이것은 라이브러리에 엄청난 문제가 있는 것 처럼 보인다. 
하지만 개인적으로 생각하는 실질적인 문제는 **RxFlow 를 잘못 사용하고 있다는 것이다.** 

<br>

특히나 `Step Case Naming` 에 있어서 크게 잘못 사용하고 있다는 생각을 했다. 

<br>

현재 사용하고 있는 case 들의 예시를 적어보자면 이렇다.
```swift
enum DemoStep: Step {
	case dismiss
	case needToGoBack
	...
}
```
위와 같은 case 들만 있는 것은 아니지만 내가 문제로 생각되는 case 들만 작성해보았다. 
그렇다면 아까 RxFlow github 에서 제공하고 있는 데모 코드와 무엇이 다른것인가?

```swift
// RxFlow Github Demo
enum DemoStep1: Step {
	case userIsLoggedIn
	case userIsLoggedOut
	...
}

// 현재 사용중인 방식 중 문제가 된다고 느껴진 코드
enum DemoStep2: Step {
	case dismiss
	case needToGoBack
	...
}
```
<br>

두 case naming 의 차이를 정리해보자면, `화면의 상태`와 `화면전환 방식` 라고 생각한다. 
일단 나는 RxFlow Step 을 정의할 때 `화면전환 방식` 을 기반으로 한다면 문제가 된다고 생각한다. 

## `화면전환 방식` 을 기반으로 한 이름의 문제점

1. **의미가 모호하다**  
   - `dismiss`, `needToGoBack` 같은 이름은 특정 화면의 상태를 나타내지 않고, 단순히 "이전 화면으로 이동"하거나 "화면을 닫는다"는 행위만을 의미한다.  
   - 이런 네이밍 방식은 개발자가 현재 어느 화면에서 어느 화면으로 이동하는지를 한눈에 파악하기 어렵게 만든다.

2. **확장성이 떨어진다**  
   - 새로운 화면이 추가되거나 네비게이션 로직이 변경될 때 기존 Step을 수정해야 하는 경우가 많다.  
   - 예를 들어, `dismiss`라는 Step이 여러 화면에서 사용되고 있다면, 특정 화면만 닫아야 하는 상황에서 별도의 조건문을 추가해야 하는 경우가 생길 수 있다.

3. **Flow 간의 일관성이 깨질 가능성이 높다**  
   - Step을 `화면전환 방식` 기반으로 정의하면, 개발자가 각 Flow마다 다른 방식으로 Step을 정의하게 될 가능성이 높아진다.  
   - 예를 들어, A 화면에서는 `closeAlert`을 사용하고, B 화면에서는 `dismiss`를 사용하는 식으로 일관성이 부족한 코드가 만들어질 수 있다.

---

## `화면의 상태` 를 기반으로 한 이름의 장점
1. **SRP 를 지킬 수 있다**
	- 하나의 Step 은 하나의 요구사항에 따라 변경될 수 있다.
	- 그런데 두 개 이상의 Step 을 공통으로 사용한다면, 요구사항이 변경되는 경우 대응하기 어렵다.

1. **의미가 명확하다**  
   - `userIsLoggedIn`, `profileUpdated` 같은 Step 이름을 사용하면, 현재 화면이 어떤 상태인지 쉽게 이해할 수 있다.  
   - 개발자가 Step을 보고 "이 상태에서는 어떤 화면이 활성화되어 있어야 하는지"를 명확하게 알 수 있다.

2. **코드 가독성이 좋아진다**  
   - Step의 의미가 명확하기 때문에, Flow 내부에서 화면전환을 정의할 때 논리적인 흐름이 깔끔해진다.  
   - 예를 들어, `userIsLoggedOut` Step이 발생하면 로그인 화면으로 이동하고, `userIsLoggedIn` Step이 발생하면 메인 화면으로 이동하는 식으로 일관된 로직을 유지할 수 있다.

3. **유지보수가 용이하다**  
   - 새로운 화면이 추가되거나 네이밍을 변경해야 할 때, Step의 의미만 잘 유지하면 큰 수정 없이도 기존 코드와 잘 맞아떨어진다.  
   - 특정 화면에서만 발생하는 상태를 명확하게 정의할 수 있기 때문에, 화면전환 로직을 더 예측 가능하게 만들 수 있다.

# 4. 결과
이번 고민을 통해 RxFlow에서 Step을 정의할 때 단순히 "화면을 이동하는 방식"이 아니라 "현재 화면이 어떤 상태인지"를 기반으로 네이밍하는 것이 더 바람직하다는 생각이 더 커졌다. ( 더 좋은 방법이 있을 수 있겠지만 현재는 이렇게 수정하는 것에도 만족스럽다. )

# 5. 맺음말
RxFlow는 매우 유용한 화면전환 라이브러리이지만, 올바르게 사용하지 않으면 오히려 개발 과정에서 혼란을 초래할 수 있다.  
특히 Step을 정의하는 방식이 잘못되면, Flow 관리가 어려워지고, 화면전환이 예상대로 동작하지 않는 문제를 겪을 가능성이 크다.

이번 글을 통해 RxFlow에서 Step을 정의할 때, "화면전환 방식"이 아닌 "화면의 상태"를 기반으로 네이밍하는 것이 중요하다는 점을 강조하고 싶다.  
앞으로도 더 나은 Best Practice를 찾아나가면서, 동료 개발자들과 함께 RxFlow를 효과적으로 활용할 수 있도록 고민해 나가야겠다.



