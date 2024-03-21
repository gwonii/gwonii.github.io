# Improvement Navigation Error With RxFlow

# Background

Dooray! 앱에서 iPhone, iPad 화면 전환 오류가 잦았고, 특히나 iPad SplitView 에 대한 호환성 문제가 많았다. 

그러나 메소드 하나를 수정하려고 하니 영향을 주는 부분이 너무 많았다. 그래서 코드를 수정할 때마다 UI 테스트를 통해 계속 확인해야 하는 불편함이 있었다.

결국 RxFlow 구조 개선을 제안했고 나의 의견은 받아들여졌다. 

# Cause Analysis

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

# Solution

### Step 의 재정의

각 상황에 따른 Step 을 각각 정의하였다. 

- ChatViewIsRequiredFromChannelList
- ChatViewIsRequiredFromDeeplink
- . . .

그리고 Flow 내에서 화면전환 메소드를 재사용할 수 있도록 하였다.
push, present 에 따라 메소드를 구분하였고, dismiss 가 필요한 부분에서는 dismiss completion 과 (push, present) 를 합쳐서 구현하였다. 
<br>

외에도 특별한 케이스의 경우에도 쉽게 화면전환 코드를 구성할 수 있었다. 
<br>

또한 불필요하게 사용되던 화면 전환 delay 코드들을 모두 제거하였다. 

# Achievement
- iPhone, iPad 화면 전환 오류 개선
- 유지보수성 향상
    
    : 분리된 step 으로 인하여 사이드 이펙트에 대한 두려움 없이 화면 전환 코드를 수정할 수 있었다. 
- 코드 가독성 향상
- Alert, Toast 등의 코드 Flow로 이동