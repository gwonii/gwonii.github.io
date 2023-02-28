---
layout: article
title: String count는 O(n)?
tags:
- iOS
- Swift
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

유지보수를 하는 과정에서 String의 count와 isEmpty의 속도 차이에 대해 알게 되었고 어떤 것이 좋을지에 대한 고민을 담아보려고 한다.

<!--more-->

# String count 는 O(n) ?

## 배경

서비스가 커져감에 따라 앱의 빌드 속도와 앱 성능에 대한 고민이 점차 늘어나게 되었다.  
앱 성능 최적화를 위해 리팩토링 하는 와중에 눈에 띄는 코드가 있었다. 

```swift
let name: String = "gwonii"
if name.count == 0 { 
	// do something
}
```

이전에 배열과 스트링의 empty 여부를 확인할 때 `count == 0` 과 `isEmpty` 사용에 고민을 한 적이 있다. 

그 때는 단순히 `isEmpty`를 사용하는 경우 간혹 `!isEmpty` 을 사용하게 되어 가독성이 떨어진다는 리뷰를 받은 적이 있었다. 

그래서 extension으로 `isNotEmpty (== !isEmpty)`  를 구현해서 사용한 적이 있었는데, 결국 `count == 0` 또는 `count > 0` 과 같이 count를 이용하는 것으로 통일하자는 결과나 나왔다. 

( isNotEmpty 코드 리뷰에서는 지금 기억상으로 "프로퍼티에 부정어를 잘 사용하지 않는다." 다는 내용의 피드백을 받았었다. )

ex) !isNotEmpty 와 같은 표현을 사용하는 경우 가독성이 현저히 떨어질 수 있다. ( 상상도 하기 싫다. )

그래서 별 생각이 없이 count를 사용하고 있었는데 

**_Array의 경우 count 와 isEmpty 의 경우 O(1) 이지만, String의 경우 isEmpty는 O(1) 인 반면 count는 O(n) 이라는 것을 발견하게 되었다._** 

## 문제

**가독성과 성능 차이의 선택 문제** 

**고민해봐야 하는 사항**

1. 과연 count를 사용하는 것은 가독성이 좋지만, isEmpty를 사용하는 것은 가독성이 좋지 않은가? 
2. count와 isEmpty를 같이 사용하는 것은 통일성에 위배되는가?
3. space가 들어간 문자열은 어떻게 처리할 것인가? 

<br>

### 1. 과연 count를 사용하는 것은 가독성이 좋지만, isEmpty를 사용하는 것은 가독성이 좋지 않은가?

**Answer**

: 지금와서 생각해보면 크게 문제의식을 느끼지 않았기에 대다수의 의견인 count로 사용하자는 것에 동의하였지만, isEmpty가 가독성이 낮다는 생각은 하지 않았다. 

**isEmpty와 isNotEmpty를 직접 구현함으로써 가독성에 문제를 해결할 수 있다고 생각한다.**

또한 이전에 제시되었던 `!isEmpty` 또는 `!isNotEmpty` 을 쓰게 될 수도 있다는 문제점은 Lint를 적용하던가 또는 개발자 내에 `isEmpty`와 `isNotEmpty` 에는 !(부정표현) 을 사용하지 않기로 약속하면 된다. 

<br>

### 2. count와 isEmpty를 같이 사용하는 것은 통일성에 위배되는가?

**Answer**

: 지금 보면 count와 isEmpty는 역할이 분명히 다르다. 

count는 String의 문자열 개수를 Int로 리턴하는 프로퍼티이고 isEmpty는 빈 문자열 여부 Bool 을 리턴하는 프로퍼티이다. 

단순히 isEmpty 의 표현을 count로 대체했을 뿐이지 둘의 역할은 완전히 다르다. 그러므로 둘이 공존한다고 해서 코드의 통일성을 위배한다는 얘기는 잘못된 얘기라고 생각한다. 

### 3. space가 들어간 문자열은 어떻게 처리할 것인가? 
kotlin을 참고해보니, 이미 `isEmpty`, `isNotEmpty` 가 존재했다. 게다가 `isBlank` 라는 메소드도 존재했다. 해당 메소드의 역할은 count가 0이거나 whiteSpace로만 구성되어 있는 경우 true를 리턴하고 있었다.

이 메소드를 보니 더더욱 더 `string.count == 0` 이라는 표현은 위험할 수 있다는 생각이 들었다. 
```swift
let string: String = "   "
print(string.count) // -> 3 
```
위와 같이 whiteSpace가 포함되어 있는 경우 원하지 않는 결과가 수행될 수 있는 요지가 있었다. 

## 결론

결과적으로 기존에 String에 `count == 0` 이 아니라 `isEmpty` 를 써야 하는 논리적 근거가 충분하다고 생각했다. 

그래서 사수분께 나의 생각을 공유드리고 앞으로 `isEmpty`와 `isNotEmpty` 를 쓰자고 제안드렸다. 

그런데 걱정했던 것과 달리 사수분께서는 너그럽게 **"좋네요~"** 라고 말씀해주시고 나의 의견이 받아들여졌다. 그 순간 사수분께 인정받았다는 느낌이 들면서 기분이 너무 좋았다. 그 이후 사수분께 편하게 내 의견을 피력하게 되었고, 많이 까이기도 하고 받아주시기도 하셨다. 

이 일을 경험하면서 개발자에게 서로의 의견을 공유하는 것이 굉장히 중요하다는 것을 느꼈다. 또한 단순히 count를 isEmpty 로 변경한다고 해서 갑자기 앱이 눈에 띄게 빨라지진 않았지만 이렇게 작은 요소들이 합쳐져 더 좋은 서비스를 만들 수 있을 것 같다는 확신이 들었다. 