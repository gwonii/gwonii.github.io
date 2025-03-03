---
layout: article
title: "[Problem Solving] Navigation 오류 수정하기" 
tags:
- iOS
- RxFlow
- Problem Solving
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

화면전환 과정에서 발생했던 오류 수정 내용을 정리해 보고자 한다. 

<!--more-->

# 1. 목표
- 화면전환 과정에서 발생된 크래시를 제거한다.

# 2. 이유
- 협업툴의 경우, 다양한 화면전환이 존재한다. 간단한 present, push 동작부터 여러 개의 전환이 합쳐진 것들도 존재한다. 
- 이와 같이 복잡한 화면전환 과정에서 크래시가 발생되고 있었고 이를 해결하고자 하였다. 

# 3. 실행
- 화면전환 관련하여 발생된 크래시 원인을 정확히 분석하고 해결방안을 제시한다. 

## (원인 1) 연속된 화면전환에서 동작 오류
- 해당 오류는 "can't add as subviews" crash 로 인하여 자주 발생되었다.
- "can't add as subviews" 의 발생 원인은 주로 여러 pop/push/present/dismiss 동작 사이에서 animation 의 비동기 처리로 인해 발생될 수 있다는 것을 확인하였다.
- Dooray! 앱 에서는 비즈니스 요구사항에 따라 복잡하게 여러 화면전환이 섞여있는 경우가 많았다.
- general 한 step 을 사용하여 여러 화면전환 로직을 구성하였다.
- 거대해진 화면 전환 메소드로 인하여 유지보수에 있어서 보수적으로 대응

## (해결 1) 연속된 화면전환에서 동작 오류
### 1. CATransaction 을 이용하여 animation 동기화 처리
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
- 위와 같이 CATransaction 을 통해 `completion` 블럭을 사용하여 animation 의 동기화 처리가 가능하도록 변경하였다.

### 2. 화면전환 Step 재정의
- 기존에는 필요한 중복임에도 불구하고 중복을 제거하고자 하나의 Step 으로 다양한 상황의 커버하고자 general 한 step 을 구현하게 되었다.
- general 한 step 을 제거하고 화면별 요구사항에 맞는 Step 을 각각 정의하였다.
- Step 을 `화면전환 방식` 이 아닌 `화면의 상태` 로 정의하였다.

<br>
자세한 내용은 [RxFlow 에서 Step 에 대한 고민](https://gwonii.github.io/2023/09/03/RxFlow-Case-Naming.html) 을 참고해주세요! 

## (원인 2) 화면전환 후 메모리 누수 발생
- https://github.com/RxSwiftCommunity/RxFlow/issues/28
- RxFlow 에서 UIViewController > childViewController 사용시에 parentViewController 가 메모리가 제거되지 않으면 childViewController 의 Stepper 가 강한참조로 인해 RxFlow 내에서 메모리 해제가 되지 않는다.

## (해결 2) 화면전환 후 메모리 누수 발생'
- 우선 addChild 를 이용하여 RxFlow 화면전환을 하는 코드를 제거하고 addChild 대신 다른 독립적인 화면으로 이동하도록 변경
- RxFlow 내부 코드 수정으로 childViewController 의 stepper 의 참조를 해제할 수 있도록 변경 예정

# 4. 결과
- iPhone, iPad 화면 전환 크래시를 제거할 수 있었다.
- 유지보수성을 향상 시켰다.    
  - 분리된 step 으로 인하여 사이드 이펙트에 대한 두려움 없이 화면 전환 코드를 수정할 수 있었다. 
- 화면전환 시 메모리 누수 제거하였다.
- 복잡한 화면전환시 Crash 및 전환이 누락되는 문제 해결하였다.
- 코드 가독성 향상시켰다.
- 크래시를 수정하면서 RxFlow 내부에도 문제가 있는 것을 발견하였다. 