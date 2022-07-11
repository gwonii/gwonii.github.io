---
layout: article
title: Why Use SwiftUI
tags:
- iOS
- Swift
- SwiftUI
- UIKit
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

오랜만에 이전에 공부했었던 SwiftUI를 왜 사용하는지에 대해 간단하게 정리해보려고 한다. 

<!--more-->

# SwiftUI 개요

선언적 UI로 Apple의 모든 플랫폼에 대응하기 위하여 고안된 UI 프레임워크. 

### 선언적 구문

명령형 프로그래밍의 방식으로 UI를 구성하는 것이 아니라 선언형 프로그래밍을 이용하여 UI를 구성

```swift
import SwiftUI

struct ContentView: View {
    
    @State var searchName: String = ""
    @ObservedObject var viewModel: ViewModel = .init()
    
    var body: some View {
        VStack {
            TextField("Please enter a search word.", text: $searchName)
                .textFieldStyle(.roundedBorder)
                .background(Color(.systemGray6))
                .padding(15)
            List(
                self.viewModel.books
                    .filter { $0.title.contains(searchName) || self.searchName.isEmpty }
            ) { (book) in
                TableCell(book: book)
            }
            .listStyle(.plain)
            .refreshable {
	                await self.viewModel.updateBooks(_ searchName: String)
            }
        }
    }
}

struct TableCell: View {
    let book: Book
    
    var body: some View {
        HStack(alignment: .center) {
            Text("\(book.title)")
                .frame(width: 100, alignment: .leading)
            Text("\(book.author)")
            Text("\(book.year)")
        }
    }
}
```

<aside>
💡 명령형 vs 선언형 프로그래밍 방식

- `명령형` 프로그래밍은 **How** 에 대한 고민을 코드로 표현하였다. 
- `선언형` 프로그래밍은 **What** 에 대한 고민을 코드로 표현하였다.

</aside>

<Br>

# 도입된 이유

## 1. 상속을 버리다.

### **기존 UI 상속의 문제점**

UIKit은 모든 View들은 class로 구현되어 있다. 그런데 이렇게 Class로 구현되어 있는 View들은 겉보기에 아무 문제가 없지만 내부적으로 몇 가지 문제들을 내포하고 있다. 

<Br>

### 1) **수 많은 프로퍼티**

iOS 에서는 text를 표현하기 위하여 UILabel 이라는 View를 사용한다. 

그런데 이 View는 `NSObject` - `UIResponder` - `UIView` - `UILabel` 의 상속 관계를 가지고 있다. 

그 결과 UILabel을 단순히 text를 보여주는 용도로만 사용하더라도 불필요한 프로퍼티들도 따라오게 된다. 

그리고 여기서 더 끔찍한 일은 `NSObject`, `UIResponder` , `UIView`, `UILabel` 의 클래스를 명확히 이해하지 못하고 각각의 메소드와 프로퍼티를 사용하는 경우다. 

또는 UILabel과 UITextView 의 상속관계를 제대로 이해하지 못하고 사용하는 경우도 있겠다. 

UITextView의 상속관계는 `NSObject` - `UIResponder` - `UIView` - `UIScrollView` - `UITextView`

<Br>

### 2) **무한한 상속**

가령 특수문자로 대화를 하는 세상이 왔다고 가정해보겠다. 

그래서 Apple측에서는 특수문자 전용 클래스를 만들려고 했고, 해당 클래스의 상속 관계를 고민하게 되었다. 

그러다가

**Apple 5년차 A개발자**: "특수문자도 text를 표현하기 위해 만들어졌으니까 UILabel에 상속시켜서 만들면 되겠다."

**Apple 10년차 B개발자: "**근데 여러줄로 표현하고 스크롤을 할 수 도 있으니까 UITextView에도 상속시켜서 만들어야겠다."

그리고 실무자 **Apple 1년차 개발자**는 

.... - UILabel - UISpecialCharacter

.... - UITextView - UISpecialCharacterView

.... - UIButton - UISpecialCharacterButton

...........

실제로 벌어져서는 안되고 벌어질릴도 없는 얘기겠지만 위의 얘기한 View를 상속하는 방식을 계속 고수하게 된다면 언젠간 맞닥드릴 수 도 있다. 

<Br>

### 3) Class를 버리고 Struct를 채용하다

위와 같은 이유들로 class를 이용한 상속이 아닌 Struct를 이용하게 되었다. 

그렇다면 Struct로 View를 어떤 방식으로 사용했을까? 

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2022-07-11-Why-Use-SwiftUI/UIKit-vs-SwiftUI-Text.png?raw=true" alt="01" style="zoom: 80%;" />


struct는 기본적으로 값 타입이다. 그렇기 때문에 새로운 변수에 할당될 때 값을 복사하게 된다. 

그래서 `SwiftUI - Text`는 View의 설정값을 변경할 때 func 으로 구현되어 있다. 

( 이 부분은 선언적 UI의 기본이 된다. )

View의 기본 속성인 Body 

```swift
struct ContentView: View {
	var body: Some View {
		...
		Text("") 

	}
}
```

SwiftUI에서 기본 프로젝트를 생성하는 경우, 위와 같은 코드가 만들어진다. 

여기서 body 는 연산 프로퍼티로 되어 있는데 SwiftUI가 View를 바라보는 관점을 정확히 알 수 있다. 

SwiftUI에서는 View 자체를 하나의 함수로 바라본다. 

반대로 class는 값들으 복사하는 것이 아니라 참조를 하는 방식이기 때문에 프로퍼티를 값을 변경하는 방식으로 View의 속성을 변경한다. 

### 4) 상속이 아닌 확장

**View에 frame을 설정하는 방법**

```swift
Struct ContentView: View {
	var body: some View {
		

		Text("hello, world!")
			.frame(width: 50, height: 50, alignment: .center)
	}
}
```

SwiftUI에서는 위와 같은 방법으로 frame을 수정할 수 있다. 거의 모든 View들은 frame을 설정할 수 있을텐데 상속이 불가능한 Struct `Text` 는 어떻게 frame을 설정할 수 있는 것일까? 

**UIKit - UILabel**

```swift
// UIView > UILabel

class UIView {
	var frame: CGRect
	var bounds: CGRect
}

class UILabel { 
	override var frame: CGRect
	override var bounds: CGRect
}
```

**SwiftUI - Text**

```swift
extension Text: View {
	...
}

extension View {
	@inlinable public func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View
}
```

위와 같이 Text에 View의 frame 메소드를 확장하여 사용

## 3. 통합 플랫폼 UI 개발

iOS, macOS, watchOS 등 모든 Apple 플랫폼에서 사용할 수 있는 통합 UI 코드를 개발할 수 있다. 

- **Struct를 통한 UIComponents 통일**
- **새로운 SwiftUI layout engine**

SwiftUI 에서는 자식뷰가 본인의 size를 설정하고 부모뷰에 넘겨준다. 

- **SwiftUI를 사용하는 경우 UIKit의 AppDelegate, SceneDelegate 를 사용하지 않고 고유의 App Lifecycle을 갖는다.**

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2022-07-11-Why-Use-SwiftUI/UIKit-vs-SwiftUI-Main.png?raw=true" alt="01" style="zoom: 80%;" />

SwiftUI의 경우 App 을 채택하는 첫 화면 struct에 `@main` 키워드를 사용하여 앱을 구동시킨다. 

(info file 에도 적용을 해주어야 하는가)

기존의 iOS를 개발하기 위한 `UIKit`, macOS를 개발하기 위한 `AppKit`  들은 플램폿별로 Interface Builder를 가지고 있었다. 그렇기 때문에 iOS와 macOS 사이에 호환이 불가능하였다. 

## 4. 디자인 도구

- 디자인 캔버스를 통해서 코드를 변경하는 경우 실시간으로 UI가 업데이트 됩니다. 
( 기존에 iOS 진영에서 스토리보드를 사용하지 않는 경우 UI 를 실시간으로 확인 할 방법이 없었습니다. )
- 디자인 캔버스에 드래그엔 드랍을 이용하여 UI 구성요소를 추가할 수 있습니다.

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2022-07-11-Why-Use-SwiftUI/SwiftUI-Sample.png?raw=true" alt="01" style="zoom: 67%;"/>
<Br><Br>
<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2022-07-11-Why-Use-SwiftUI/SwiftUI-Previews.png?raw=true" alt="01" style="zoom: 67%;"/>

## 5. 낮은 러닝커브

**기존에 UIKit을 사용하게 되는 경우**

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2022-07-11-Why-Use-SwiftUI/UIKit-Structure.png?raw=true" alt="01" style="zoom: 67%;"/>

이렇게 다양하고 깊게 알아야 하는데…

그런데 SwiftUI를 사용하게 되면 여러가지 요구사항들에 대해서 유연하게 대처할 수 있는가? 

다음 이시간에...