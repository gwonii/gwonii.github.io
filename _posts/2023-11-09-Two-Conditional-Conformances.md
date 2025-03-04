---
layout: article
title: Two Conditional Conformances Error
tags:
  iOS
  Swift
  Language
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

`swift-evolution/proposal/conditional-conformances` 를 보다가 두 개의 condition 을 설정할 수 없다는 것을 확인하고 당연하지만 몰랐던 사실이 있어 작성해보려고 한다. 

<!--more-->

# 개요
where 절을 이용하여 조건절을 추가하는 경우에 `두 개의 조건을 overload` 할 수 없다는 사실을 발견하였다. 
<br>
하지만 그 이유를 정확히 알지 못했고 이유가 궁금했다... 


# 발단

```swift
struct SomeWrapper<Wrapped> {
  let wrapped: Wrapped
}

extension SomeWrapper: Equatable where Wrapped: Int {
  static func ==(lhs: SomeWrapper<Wrapped>, rhs: SomeWrapper<Wrapped>) -> Bool {
    return lhs.wrapped == rhs.wrapped
  }
}

extension SomeWrapper: Equatable where Wrapped: String {
  static func ==(lhs: SomeWrapper<Wrapped>, rhs: SomeWrapper<Wrapped>) -> Bool {
    return lhs.wrapped === rhs.wrapped
  }
}
```
`Equatable` 을 순응하는 경우 조건을 추가하였다. 
첫번째로 Wrapped Type 이 Int 인 경우에도 SomeWrapper 가 Equtable 하도록 하였다. 

두번째로 Wrapped Type 이 String 인 경우에도 SomeWrapper 가 Equtable 하도록 하고 싶었다. 

하지만

`Conflicting conformance of 'SomeWrapper<Wrapped>' to protocol 'Equatable'; there cannot be more than one conformance, even with different conditional bounds`

에러가 발생되었고 그 이유가 궁금했다... Wrapped Type 이 Int와 String 인 경우에만 Equatable 할 수는 없다는 것인가?? 

# 해결
위와 유사하지만 조금 다른 예시를 확인할 수 있었다. 그리고 왜 안되는지 이유에 대해서 확실히 알 수 있었다. 

https://github.com/apple/swift-evolution/blob/main/proposals/0143-conditional-conformances.md#overlapping-conformances

에서 설명해주시기를 

```swift
struct SomeWrapper<Wrapped> {
  let wrapped: Wrapped
}

protocol HasIdentity {
  static func ===(lhs: Self, rhs: Self) -> Bool
}

extension SomeWrapper: Equatable where Wrapped: Equatable {
  static func == (lhs: SomeWrapper<Wrapped>, rhs: SomeWrapper<Wrapped>) -> Bool {
    return lhs.wrapped == rhs.wrapped
  }
}

extension SomeWrapper: Equatable where Wrapped: HasIdentity {
  static func == (lhs: SomeWrapper<Wrapped>, rhs: SomeWrapper<Wrapped>) -> Bool {
    return lhs.wrapped === rhs.wrapped
  }
}
```

본문에서는 

`Ambiguity, because T conforms to both Equatable and HasIdentity` 라고 하셨다... 

자세히 얘기하면

`It is due to the possibility of #4 occurring that we refer to the two conditional conformances in the example as overlapping. There are designs that would allow one to address the ambiguity, for example, by writing a third conditional conformance that addresses`

위와 같이 `where Wrapped: Equatable`, `where Wrapped: HasIdentity` 인 경우 

만약 `where Wrapped: Equatable & HasIdentity` 이면 어떡할 것인지가 문제가 되었다. 

만약 `Equatable` 이면서 `HasIdentity` 인 타입이라면 어떤 `==` 을 호출해야 하는지 컴파일러는 알 방법이 없다.

# 후기

생각보다 당연한 문제였다.. 내가 너무 생각이 짧았다. 하하하

## 참고자료
- https://github.com/apple/swift-evolution/blob/main/proposals/0143-conditional-conformances.md#overlapping-conformances