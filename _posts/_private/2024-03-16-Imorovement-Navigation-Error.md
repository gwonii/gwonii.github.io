# Improvement Navigation Error

# Background
Dooray! 앱은 다양한 요구사항에 따라 복잡한 화면전환이 존재한다. 그러다 보니 다양한 화면 전환 오류가 존재하였다. 

1. 연속된 화면전환에서 동작 오류
2. 화면전환 후 메모리 누수 발생

화면전환 관련된 오류를 정리하다 보니 크게 위 3가지 유형의 문제를 발견하였다. 
Dooray! 앱 에서는 RxFlow 라이브러리를 사용하여 화면전환을 하였는데, 라이브러리 오류로 인한 문제도 있었고 화면전환 애니메이션 처리로 인한 문제 등 다양한 원인으로 문제가 발생되고 있었다. 

# Cause Analysis

## 1. 연속된 화면전환에서 동작 오류

- 해당 오류는 "can't add as subviews" crash 로 인하여 자주 발생되었다.
- "can't add as subviews" 의 발생 원인은 주로 여러 pop/push/present/dismiss 동작 사이에서 animation 의 비동기 처리로 인해 발생될 수 있다는 것을 확인하였다.
- Dooray! 앱 에서는 비즈니스 요구사항에 따라 복잡하게 여러 화면전환이 섞여있는 경우가 많았다.
- general 한 step 을 사용하여 여러 화면전환 로직을 구성하였다.

## 2. 화면전환 후 메모리 누수 발생
- https://github.com/RxSwiftCommunity/RxFlow/issues/28
- RxFlow 에서 UIViewController > childViewController 사용시에 parentViewController 가 메모리가 제거되지 않으면 childViewController 의 Stepper 가 강한참조로 인해 RxFlow 내에서 메모리 해제가 되지 않는다.

# Solution

## 1. 연속된 화면전환에서 동작 오류

### 1-1. CATransaction 을 이용하여 animation 동기화 처리
- 핵심적인 문제 중에 하나는 화면전환 코드의 animation 동작이 동기화 되지 않은 것이다. 

```swift
func popViewController(animated: Bool,
                       _ completion: ((UIViewController?) -> Void)? = nil) {
    var viewController: UIViewController?
    CATransaction.begin()
    CATransaction.setCompletionBlock({ completion?(viewController) })
    viewController = popViewController(animated: animated)
    CATransaction.commit()
}
```
- 위와 같이 CATransaction 을 통해 `completion` 블럭을 사용하여 animation 의 동기화 처리가 가능하도록 하였다. 

### 1-2. 화면전환 Step 재정의
- general 한 step 을 정의하여 복잡해진 화면 전환 메소드의 사용
- 필요한 중복임에도 불구하고 중복을 제거하고자 하나의 Step 으로 다양한 상황의 화면 전환을 커버
- 거대해진 화면 전환 메소드로 인하여 유지보수에 있어서 보수적으로 대응
<br>

### ex) `ChatViewIsRequired` 

채팅 화면이 필요한 상황에 사용되던 Step 이다. 하지만 `ChatViewIsRequired` Step 은 약 21 곳에서 호출되었다.

- 채널 리스트에서 대화를 터치한 경우
- 대화 검색을 통해 대화방으로 이동하는 경우
- 사용자 멘션을 통해 대화방으로 이동하는 경우
- 내부 알림을 통해 대화방으로 이동하는 경우
- . . .

이렇게 다양한 곳에서 `ChatViewIsRequired` Step 이 호출된 것도 문제였지만, 각 상황들에서 SplitView 를 고려해서 화면을 전환해야 하는 경우가 굉장히 많았다.

### Step 의 재정의

각 상황에 따른 Step 을 각각 정의하였다. 

- ChatViewIsRequiredFromChannelList
- ChatViewIsRequiredFromDeeplink
- . . .

그리고 Flow 내에서 화면전환 메소드를 재사용할 수 있도록 하였다.
push, present 에 따라 메소드를 구분하였고, dismiss 가 필요한 부분에서는 dismiss completion 과 (push, present) 를 합쳐 동작들의 동기화될 수 있도록 구현하였다. 
<br>

외에도 특별한 케이스의 경우에도 쉽게 화면전환 코드를 구성할 수 있었다. 
<br>

또한 불필요하게 사용되던 화면 전환 delay 코드들을 모두 제거하였다. 


## 2. 화면전환 후 메모리 누수 발생
- 우선 addChild 를 이용하여 RxFlow 화면전환을 하는 코드를 제거하고 addChild 대신 다른 독립적인 화면으로 이동하도록 변경
- RxFlow 내부 코드 수정으로 childViewController 의 stepper 의 참조를 해제할 수 있도록 변경 예정

# Achievement
- iPhone, iPad 화면 전환 오류 개선
- 유지보수성 향상    
    : 분리된 step 으로 인하여 사이드 이펙트에 대한 두려움 없이 화면 전환 코드를 수정할 수 있었다. 
- 화면전환 시 메모리 누수 제거
- 복잡한 화면전환시 Crash 및 전환이 누락되는 문제 해결
- 코드 가독성 향상
- Alert, Toast 등의 코드 Flow로 이동