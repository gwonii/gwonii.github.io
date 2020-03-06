---
layout: article
title: SwiftUI와 Combine 체험기
tags:
- iOS
- SwiftUI
- Combine
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

2019년 SwiftUI가 발표되면서 `Combine`이라는 프레임워크가 함께 출시되었다. 하지만 SwiftUI가 굉장히 혁신적이었기에 큰 인기를 얻었지만, 상대적으로 Combine은 주목받지 못했다. 그래서 오늘은 SwiftUI와 함께 쓰이는 Combine에 대해 알아보는 시간을 가져보도록 하자. 

<!--more-->

# SwiftUI + Combine





## 개요 

2019년 SwiftUI가 발표되면서 `Combine`이라는 프레임워크가 함께 출시되었다. 하지만 SwiftUI가 굉장히 혁신적이었기에 큰 인기를 얻었지만, 상대적으로 Combine은 주목받지 못했다. 그래서 오늘은 SwiftUI와 함께 쓰이는 Combine에 대해 알아보는 시간을 가져보도록 하자. 



## 이 글을 통해 내가 배워야 할 것! 

이 글은 큰 틀에서 SwiftUI에서 Combine 프레임워크가 어떻게 쓰이는지 알아볼 것이다. 정리를 해보자면, 

* `Combine` 프레임워크는 무엇이며, SwiftUI와 어떻게 함께 사용되는지 알게 될 것이다. 
* **`Publisher`**, **`Subscriber`**, **`Operator`**이 무엇이며 어떻게 사용되는지 알게 될 것이다. 
* 그리고 구체적으로 코드로 어떻게 위의  것들이 구현되는지 알게 될 것이다!!! 



## 예제 

위의 학습을 위해 로그인 과정에서 `userName`과 `userPassword`의 적합성을 판단하고 로그인을 가능하게 하는 로직을 구현할 것이다!! 



### 기능 스펙 

- Users need to enter their desired username
- They also need to pick a password


- The username must contain at least 3 characters
- The password must be non-empty and strong enough
- Also, to make sure the user didn’t accidentally mistype, they need to type their password a second time, and both of these passwords need to match up



## 과정

기본적으로 로그인 화면을 위한 기본 준비를 하려고 한다. 

```swift
class UserViewModel: ObservableObject {
  // Input
  @Published var username = ""
  @Published var password = ""
  @Published var passwordAgain = ""

  // Output
  @Published var isValid = false
}
```

기본적으로 Combine을 사용하여 **MVVM**의 구조로 앱을 구현할 것이다. 그렇기에 **ObservableObject** 프로토콜을 채택하여 class를 구성하였다. 프로퍼티로는 사용자에게 입력될 `userName`, `password`, `passwordAgain` 과 그로 인하여 출력될 `isValid`로 구성된다. 

UI의 화면은 간단히 ViewModel에 입력될 요소들을 표현한다. 

```swift
struct ContentView: View {

  @ObservedObject private var userViewModel = UserViewModel()

  var body: some View {
    Form {
      Section {
        TextField("Username", text: $userViewModel.username)
          .autocapitalization(.none)
        }
        Section {
          SecureField("Password", text: $userViewModel.password)
          SecureField("Password again", text: $userViewModel.passwordAgain)
       }
       Section {
         Button(action: { }) {
           Text("Sign up")
         }.disabled(!userViewModel.valid)
       }
     }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
```

1. 계속해서 관찰 할 ViewModel 형태의 변수를 선언한다.

**@ObservedObject** 어노테이션을 이용하여 **UserViewModel** 형태의 객체를 관찰할 것이다. 

2. Form 형태로 데이터들을 입력받는다.



위의 형태를 보통 **Data Binding**이라고 한다. **ViewModel**의 프로퍼티와 실제로 사용될 **View**의 데이터와 연결하는 것이다.



### Combine의 꽃, Publisher, Subscriber, Operator 

* **Publisher** : 


`Publisher`는 하나 또는 여러 개의 `Subsriber`에게 데이터를 전달한다. 

`Publisher` 프로토콜은 **output**과 **Error**를 가지고 있다. 

```swift
public protocol Publisher {
  associatedtype Output
  associatedtype Failure : Error
  func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
}
```



* **Subscriber** : 


`Subsriber`는 특정한 하나의 `Publisher` 인스턴스를 구독한다. `Subscirber`의 **Input**과 **Failure**은 `Publisher`의 **Output**과 **Failure**와 연결된다. 

```swift
public protocol Subscriber : CustomCombineIdentifierConvertible {
  associatedtype Input
  associatedtype Failure : Error

  func receive(subscription: Subscription)
  func receive(_ input: Self.Input) -> Subscribers.Demand
  func receive(completion: Subscribers.Completion<Self.Failure>)
}
```



* **Operator** : 


`Publisher`와 `Subscriber`는 View와 ViewModel이 양방향으로 싱크를 맞게 해주는데 중심적인 역할을 한다. Combine 프레임워크의 기본이 되는 것이다. 

반면 `Operator`는 Combine 프레임워크의 **SuperPower**라고 할 수 있다. 

`Operator`는  `Publisher`를 작동시키고, 연산을 진행하고 또 다른 `Publisher`를 생산한다. 

예를 들어 

* `filter`를 통해, 조건에 맞지 않는 값들을 걸러낼 수 있다. 
* `debounce`를 통해, 비용이 큰 동작을 수행할 때 user가 input을 멈출 때 까지 기다리게 하는 동기적 처리를 가능하게 해준다. 
* `map`을 통해, input value를 새로운 값으로 변경시킬 수 있다. 

etc…..

이렇게 ReactiveX에서 가능했던 비동기처리를 가능하게 해주는 역할을 Combine또한 수행해준다. 여기서 중요한 점은 

**Combine은 first-party이고 Rx는 third-party라는 점이다.** 그로 인해 Combine은 월등한 퍼포먼스를 보여준다. 





## Issue



### init() 할 때 CombineLatest한 항목에 대해 주의하라 

uesrName과 userPassword를 입력하고 그에 따른 에러 문구를 띄워주려고 할 때 문제가 생겼다. 

기존에는 

```swift
private var isPasswordValidPublisher: AnyPublisher<PasswordCheck, Never> {
    Publishers.CombineLatest(isPasswordsEqualPublisher, isPasswordEmptyPublisher)
        .map { passwordIsEqual, passwordIsEmpty in
            if passwordIsEmpty {
                print("passwordIsEmpty")
                return .empty
            } else if !passwordIsEqual {
                print("passwordNoMatch")
                return .noMatch
            } else {
                print("passwordIsValid")
                return .valid
            }
    }
.eraseToAnyPublisher()
}
```



```swift
init() {
  isPasswordEmptyPublisher	// Publisher
    .receive(on: RunLoop.main)
    .map { valid in
        valid ? "Password is empty" : ""
}
.assign(to: \.userPasswordMessage, on: self)
.store(in: &cancellableSet)

isPasswordsEqualPublisher	// Publisher
    .receive(on: RunLoop.main)
    .map { valid in
        valid ? "" : "Password don't match"
        
}
.assign(to: \.userPasswordMessage, on: self)
    .store(in: &cancellableSet)
}
```

`isPasswordEmptyPublisher`와 `isPasswordEqualPublisher`를 **CobineLatest** 한 후에 **init()** 구문에서 따로 해당 메시지를 `userPasswordMessage`에 연결해주었다. 

그런데 그 결과 **Empty**임에도 불구하고 **NotEqual**을 출력하기도 하고, **NotEqual**임에도 불구하고 **Empty**문구를 띄워주었다. 

원인을 고민해본 결과 각각 `isPasswordEmptyPublisher`, `isPasswordEqualPublisher`가 독립적으로 **assign()**을 하고 있었고 그것이 주된 원인이라고 생각했다. 위 두 publisher는 이미 `isPasswordValidPublihser`로 combineLatest가 되어있으므로 assign()을 할 때는 `isPasswordValidPublihser`에서 모두 처리를 해야 된다고 생각했다. 

그래서 

```swift
isPasswordValidPublisher
    .receive(on: RunLoop.main)
    .map { PasswordCheck in
        switch PasswordCheck {
        case .empty:
            return "Password is empty"
        case .noMatch:
            return "Password don't match"
        default:
            return ""
        }
}
.assign(to: \.userPasswordMessage, on: self)
.store(in: &cancellableSet)
```

위 처럼 `isPasswordValidPublisher`에서 모든 password에러 사항에 대해 분기처리를 하고 assign을 할 수 있도록 만들었다. 

그 결과 문제는 해결되었다. 행복하다. 



## 여담

분명히 추가적으로 문제가 있는 부분이 있을 것이다. 하지만 Combine의 모든 프로세스를 이해하고 있지 않기 때문에 이상한 점을 명확히 지적할 수가 없다. 계속 학습하면서 조금더 세밀하게 Combine을 다룰 수 있도록 해야겠다.

> [포스트 전체 코드 (feat. gwonii)](https://github.com/gwonii/SwiftUI-Project/tree/master/Project_C/Project_C/Src) 


>  [**원문** 출처 - SwiftUI + Combine (feat. Peter Friese)](https://peterfriese.dev/swift-combine-love/)

