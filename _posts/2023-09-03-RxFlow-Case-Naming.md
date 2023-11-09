---
layout: article
title: RxFlow 에서 Step 에 대한 고민 (DOING)
tags:
- iOS
- Swift
- Library
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

NHN 회사에는 화면전환 Library로 RxFlow 를 사용하고 있는데 현재 작성된  Step 에 case 들을 보면서 "조금 더 개선할 수 있는 부분이 있지 않을까?" 라는 질문을 시작으로 글을 써보려고 한다. 

<!--more-->

# RxFlow란?

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

# Step...
Step은 RxFlow 에서 제공되는 protocol 이며 이동해야 할 각 화면들의 상태를 의미한다. 
<br>
// 해당 코드는 RxFlow gitgub 예제 코드를 참고하였습니다. 

```swift
enum DemoStep: Step {
	case userIsLoggedIn
	case userIsLoggedOut
	...
}
```

`Step` protocol 을 채택한 enum 을 만들고 화면전환에 필요한 case 를 정의한다. 
그리고 화면전환에 필요한 데이터가 있다면, 연관 데이터를 추가하기도 한다. 

그리고 `Flow` 에서 `Step` case 에 따라 화면전환 상세 코드를 작성하게 된다. 

# Step Case Naming 관점에서 바라본 문제점

현재 RxFlow 를 사용하면서 경험했던 문제들은 **"화면전환이 정상적으로 동작하지 않았다."** 는 것이다...
<br>
좀 더 자세히 얘기하자면, `Reactor` (현재 ReactorKit을 사용하고 있다) 는 `Flow` 을 참조하고 있으면 Step 을 이용하여 화면전환을 Flow 에 요청한다. 

<br>

그런데 

<br>

화면전환 Library 를 사용하는데 화면전환에 문제가 있다면 이것은 Library 에 엄청난 문제가 있는 것 처럼 보인다. 
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

<br>

그렇다면 아까 RxFlow github 에서 제공하고 있는 데모 코드와 무엇이 다른것인가?

<br>

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

두 case naming 의 차이를 정리해보자면, `화면의 상태`와 `화면전환 방식` 라고 생각한다. 

## `화면전환 방식` 을 기반으로 한 이름의 문제점

일단 나는 RxFlow Step 을 정의할 때 `화면전환 방식` 을 기반으로 한다면 문제가 된다고 생각한다. 

### 1. ViewModel 에서 화면전환의 로직을 일부분 담당하게 된다.


