---
layout: article
title: SwiftUI와 Combine 사용기
tags:
- iOS
- SwiftUI
- Combine
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

2019년 SwiftUI가 발표되면서 `Combine`이라는 프레임워크가 함께 출시되었다. 하지만 SwiftUI가 굉장히 혁신적이었기에 큰 인기를 얻었지만, 상대적으로 Combine은 주목받지 못했다. 그래서 오늘은 SwiftUI와 함께 쓰이는 Combine에 대해 알아보는 시간을 가져보도록 하자. 
---

<!--more-->
---

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

#### 1. 계속해서 관찰 할 ViewModel 형태의 변수를 선언한다. 

**@ObservedObject** 어노테이션을 이용하여 **UserViewModel** 형태의 객체를 관찰할 것이다. 

#### 2. Form 형태로 데이터들을 입력받는다. 



위의 형태를 보통 **Data Binding**이라고 한다. **ViewModel**의 프로퍼티와 실제로 사용될 **View**의 데이터와 연결하는 것이다.



### Combine의 꽃, Publisher, Subscriber, Operator 

* **Publisher** : 
* **Subscriber** : 
* **Operator** : 



>  [원문 출처 - SwiftUI + Combine (feat. Peter Friese)](https://peterfriese.dev/swift-combine-love/)