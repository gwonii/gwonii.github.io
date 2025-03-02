---
layout: article
title: "[AI] Apple Intelligence 맛보기" 
tags:
- Apple Intelligence
- AI
- iOS
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

Apple 에서 새롭게 등장한 Apple Intelligence 에 대해서 간단하게 조사해보고자 한다. 

<!--more-->

# 1. 목표

- 협업툴 서비스에서 OnDeviceAI 형태로 사용자에게 제공할 수 있는 서비스가 있을지 자료조사
- Apple 에서 새로 제공하는 Apple Intelligence 자료조사

# 2. 이유

현재 AI는 AI 챗봇 (단순 ChatGPT) 을 넘어 다양한 서비스에서 기능을 제공하고 있다. 

- 검색 기반 AI, Perplexity
- Software AI Agent, Cursor 또는 Claude Code
- Office AI Agent, MS AI
- 협업툴 AI, Notion 또는 Slack
- …

다양한 서비스로 AI 기능을 제공하는 사례를 보면서 내가 현재 개발하고 있는 협업툴 시장에서도 AI 기능을 다양하게 활용할 수 있다고 생각했다. 
<br>
특히나 협업툴에서 On Device AI 형태로 서비스를 제공한다면 큰 시너지를 낼 수 있다고 생각한다. 
<br>
현재 Dooray! 협업툴에서는  메신저, 캘린더, 업무 관리, 위키, 주소록, 조직도 등 다양한 기능을 제공한다. 이와 같은 기능에 On Device AI 를 활용하면 어떤 새로운 서비스를 만들 수 있을지 고민해보고자 한다.

# 3. 실행
- 우선 Apple 에서 직접 제공하는 Apple Intelligence 기능을 알아보고자 한다.
- Apple Intelligence 에서는 여러 기능을 제공하지는 해당 포스트에서는 `Writing Tools` 과 `Siri with AppIntent` 기능에 대해 알아보고자 한다.

## Apple Intelligence 제약사항
- Device: iPhone 15 Pro +, iPad 6세대 +, M1 Mac +
- OS: iOS 18.x


## Apple Intelligence - Writing Tools

- Writing Tools 은 Device 내부적으로 지원하는 **`문서 및 메세지 작성 지원 기능`**이다.
- 특별한 구현을 하지 않아도 Apple Intelligence 를 지원한다면 TextView 에서 사용이 가능합니다.

### 제공 기능

- 재작성
    - 오류 (맞춤법, 문법) 수정 및 단순 재작성
    - 문장 스타일 변경 ( ex. 친근하게, 전문적으로 … )
- 변형: 요약, 핵심 키워드, 리스트, 표
    - Text 를 특정 요청에 맞게 새롭게 변형시킨다.
- GPT 요청

Writing Tools 사용시 이미지
<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-02-Apple-Intelligence-Preview-Image/AppleIntelligence_4.png?raw=true" alt="01" style="zoom: 80%;" />
- A (ChatGPT): GPT 에게 해당 문장에 대해 어떻게 수정할지 요청합니다.
- B (재작성): 맞춤법, 문법 오류 수정 및 문자의 스타일을 변경합니다.
- C (변형): 요약, 핵심 키워드, 리스트, 표 형태로 Text 를 변형합니다.
- D (ChatGPT): 특정 요구사항에 맞는 글을 새로 작성합니다.

### Apple API

- Writing Tools 은 커스텀이 가능합니다.

1. [writingToolsBehavior](https://developer.apple.com/documentation/uikit/uiwritingtoolsbehavior)
    - 옵션 제공 범위를 설정합니다.
    - none: writing tools 기능을 제공하지 않는다.
    - default: 사용자의 설정에 따라 writing tools 제공한다.
    - completed: 재작성 메뉴 선택시 우선적으로 변경 내용이 반영된다.
    - limited: 재작성 결과 내용과 함께 (복사, 변경, 공유) 컨텍스트 메뉴를 제공한다.
2. [wiritingToolsCoordinator](https://developer.apple.com/documentation/uikit/uiwritingtoolscoordinator)
    - writing tools 를 custom 할 때 사용한다.
    - delegate 를 이용하여 다양한 요구조건을 구현할 수 있음. (ex. writing state 에 따라 처리하기, animation 처리, 수정 예외 처리하기 등)

```swift
func textViewWritingToolsWillBegin(_ textView: UITextView) {
    // Take necessary steps to prepare. For example, disable iCloud sync.
}

func textViewWritingToolsDidEnd(_ textView: UITextView) {
    // Take necessary steps to recover. For example, reenable iCloud sync.
}

if !textView.isWritingToolsActive {
    // Do work that needs to be avoided when Writing Tools is interacting with text view
    // For example, in the textViewDidChange callback, app may want to avoid certain things when Writing Tools is active
}
```

1. [allowWritingToolsResultOptions](https://developer.apple.com/documentation/uikit/uitextview/allowedwritingtoolsresultoptions)
    - 수정 결과의 포맷 옵션을 설정한다.
    - plain text, rich text, list, table 4개의 옵션을 제공하며 중복 선택이 가능하다.

### 결론

장점
- 개발자가 특별히 개발하지 않아도 사용자에게 해당 기능을 제공할 수 있다.
- Apple 에서 제공하는 API 를 통해 커스텀이 가능하다. 

단점
- LLM 을 쓰는 것에 있어서 자유도가 떨어진다.
- 아직 한글을 지원하지 않는다.
- 추후에 어떤 방식으로 업데이트 될 지 알 수 없다.
- 성능이 떨어진다면 Apple 이 아닌 해당 기능을 탑재한 서비스 앱에서 욕을 먹을 가능성이 크다..

## Apple Intelligence - Siri with AppIntent

- Siri ( + Spotlight, shortcut) 와 AppIntent 를 활용하여 App 의 기능을 간편하게 수행시켜주는 역할을 합니다.
- 앱의 기능을 시스템과 통합하여 편리한 사용자 경험을 제공합니다.

### 제공 기능

- Siri, Spotlight, Shortcut 을 이용하여 AppIntent 로 구성된 앱의 기능을 동작시킵니다.

### 코드

두 가지 기능의 구현을 하였다. 
1. Siri를 통해 해야 할 일 (Todo) 을 입력하여 앱에 할 일을 추가한다. 
2. Siri를 통해 키워드를 포함하는 할 일 리스트를 찾는다.


### 1. AppIntent 구현 ( 해야 할 일 추가 )

```swift
import Foundation
import AppIntents
import SwiftUI

struct AddTodoItemIntent: AppIntent {
    static var title: LocalizedStringResource = LocalizedStringResource("Add Todo Item")

    @Parameter(title: "Todo Title")
    var todoTitle: String

    func perform() throws -> some IntentResult {
        TodoListViewModel.shared.addTodoItem(title: todoTitle)
        return .result()
    }
}
```

- Siri 를 통해 수행시킬 명령 단위인 AppIntent 를 작성한다.
- `static var title: LocalizedStringResource = LocalizedStringResource("Add Todo Item")` 은 명령 수행시 노출될 타이틀을 설정한다.
- `@Parameter(title: "Todo Title")` 은 해당 명령에서 파라미터를 입력하게 하고 싶을 때 사용한다.
- `func perform() throws -> some IntentResult` 메소드를 통해서 파라미터를 입력받은 후 처리할 메소드를 입력한다.
<br>
<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-02-Apple-Intelligence-Preview-Image/AppleIntelligence_2.png?raw=true" alt="01" style="zoom: 80%;" />
- 타이틀을 “Todo TItle” 이라고 작성하였지만, 디바이스에서는 위와 같이 자연스럽게 질문하도록 변경된다. 

### 2. AppShortcutsProvider 구현 (해야 할 일 추가)

```swift
struct MovieAppShortcutProvider: AppShortcutsProvider {
    @State var isVisible: Bool = true

    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTodoItemIntent(),
            phrases: [
                "Add Todo \(.applicationName)"
            ],
            shortTitle: "Add Todo",
            systemImageName: "popcorn.circle"
        )
}
```

- AppShortcutsProvider 를 구현하게 되면 Siri 에서 해당 명령어를 인식하게 만들 수 있다.
- `phrases` 을 통해 Siri 가 해당 명령을 찾을 수 있도록 한다.
<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-02-Apple-Intelligence-Preview-Image/AppleIntelligence_1.png?raw=true" alt="01" style="zoom: 80%;" />
- AppShortcutsProvider 을 통해 생성된 명령을 Apple Intelligence 를 통해 호출할 수 있다. 

### 3. AppIntent 구현  ( 키워드를 통해 할 일 리스트 확인하기 )

```swift
struct FindTodoListIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Todo List"

    @Parameter(title: "Find todo itess by keyword")
    var keyword: String

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let allTodoItems = TodoListViewModel.shared.todoItems
        let targetTodoItems = allTodoItems.filter({ $0.title.contains(keyword) })

        let todoItems = targetTodoItems.isEmpty ? allTodoItems : targetTodoItems
        return .result(
            dialog: IntentDialog("검색 결과"),
            view: TodoItemsSnippetView(value: todoItems)
        )
    }
}
```

- `@Parameter(title: "Find todo itess by keyword")` 은 검색에 필요한 키워드를 입력받는다.
- `func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView` 기존 “Add Todo” 와 달리 `provideDialog` 와 `ShowsSnippetView` 가 추가되었다. 해당 프로토콜을 통하여 사용자에게 추가적인 Dialog 를 제공할 수 있다.
- `IntentResult.result(dialog, view)` 를 통해 검색 결과를 커스텀하게 노출시킨다.

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-02-Apple-Intelligence-Preview-Image/AppleIntelligence_3.png?raw=true" alt="01" style="zoom: 80%;" />
- Dialog 와 SnippetView 에 따라 위의 이미지가 노출되고 사용자의 입력을 받을 수 있는 커스텀 뷰를 제공할 수 있다. 

### 4. AppShortcutsProvider 구현 (키워드를 통해 할 일 리스트 확인하기)

```swift
AppShortcut(
    intent: FindTodoListIntent(),
    phrases: [
        "Find todo by \(.applicationName)",
        "Find \(\.$keyword) In \(.applicationName) app",
        "In \(.applicationName) app, Todo Item from \(\.$keyword)"
    ],
    shortTitle: "Find gonii Todo",
    systemImageName: "trash.circle"
)
```
- `phrases` siri 가 인식할 수 있는 명령을 다양하게 만들 수 있다.

### 결론

장점
- SIri 라는 도구를 통해 어디서나 앱의 기능을 수행시킬 수 있다.
- SIri 라는 매개체로 다양한 아이디어를 적용해 볼 수 있을 것 같다.

단점
- 한글 지원이 되지 않는다.
- `AppShortcut > phrase` 에서 AppIntent 를 호출하는 여러 힌트들을 작성하였지만, 인식률이 떨어지는 경우가 종종 발생했다.

# 4. 결과

## 총평

현재 로컬 LLM 을 사용하려면 TensorFlow 를 이용하여 경량화된 LLM 을 패키지에 설치하여 사용해야 하는데, 아직 경량 LLM의 용량이 크기 때문에 실제 서비스 앱에 내장시키기는 쉽지 않다. 

그렇기에 제미나이를 디바이스에 탑재하여 로컬 LLM 에 쉽게 접근하는 Android 의 방식은 나쁘지 않은 것 같다. 

하지만 Android 에 들어가는 제미나이는 굉장히 경량화된 LLM 모델이다. 그렇기 때문에 보통 사람들이 사용하는 ChatGPT 4o 와 비교를 한다고 하면 성능상 굉장히 떨어진다. 

그렇기에 iOS 와 같이 자체 ML 을 사용하여 도메인 기반 AI 기능을 제공해주는 것도 괜찮은 방법이라고 생각한다. 

또한 Siri 와의 연동을 통해 앱과 사용자가 더 긴밀하게 연결될 수 있도록 노력하는 것이 좋은 것 같다. 

# 5. 맺음말

Siri with AppIntent 기능의 경우 앱에서 활용해볼 수 있을 것 같다. 

가령 Siri를 통해 앱의 특정 기능을 수행시키는 것이 아니라, 앱 내에서 보이스 또는 문자로 특정 기능을 수행시키는 것이다. 

협업툴의 경우, 모바일에서 다양한 기능을 제공한다. 하지만 사용자들을 해당 기능을 잘 사용하지 않고 보통 메신저 또는 문서 뷰어의 용도로 많이 사용한다. 

앱 내에서도 보이스를 통해 특정 기능을 수행시킬 수 있다면, 사용자는 쉽게 다양한 기능을 사용할 수 있게 만들 수 있을 것 같다.
<br>

[전체 소스 코드](https://github.com/gwonii/OnDeviceAISample)