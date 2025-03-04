---
layout: article
title: Computed Property vs Function
tags:
- iOS
- Swift
- Language
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

항상 개발을 할 때면 무엇을 사용하는 것이 가장 좋을까? 라는 고민을 많이 하게 된다. 오늘은 연산프로퍼티와 함수중에 특정 상황에 어떤 것을 쓰면 좋을지 고민해보려고 한다. 

<!--more-->

# Computed Property vs Function



## 개요

이번에 프로젝트를 진행하다가 내가 올린 pr 내용중에 리뷰 한 줄을 받았다. 내용은 "이 함수를 없애고 연산프로퍼티로 만드는건 어떨까요?" 라는 내용이었다. 기존에도 연산프로퍼티와 함수를 둘 다 사용했었다. 하지만 둘을 사용하는 기준이 분명하지 않았고, 이 리뷰를 통해 궁금증이 생겼다. **Computed Property**와 **Function**은 어떨 때 사용되야 하는것인가?   

## 요약

- **Computed Property**와 **Function**은 무엇인가? 
- **Computed Property**와 **Function**의 차이는 무엇인가? 
- 나는 둘을 시의적절하게 사용할 수 있는가? 



## 본문

### 1) Computed Property와 Function이란? 

1. **`Computed Property`**: 보통 연산프로퍼티라고 하며 property이지만 처음 값은 계산된 결과에 따라 바뀌게 된다. 

<script src="https://gist.github.com/gwonii/9d5c399595f7926dcbc6e24d3a295eae.js"></script>

위 처럼 `name`는 일반적인 property라고 할 수 있다. 반면 계산된 결과에 따라 달라지는 `age`는 computed property이다. 



2. **`Function`**: 일반적으로 우리가 알고 있는 메소드이다. `func` 키워드를 사용하며 매개변수와 리턴값을 갖고 있다. 



###  2) Computed Property와 Function의 차이점 

* **상태**와 **행동**

둘의 가장큰 차이는 <u>property는 상태이고</u> <u>method는 행동</u>이라는 점이다. 상태는 클래스에서 사용될 변수들을 가리키고 행동은 변수들을 가지고 새로운 결과를 만들어내는 것이다. 일차원적으로 봤을  때 둘은 아예 다르다. 

* **매개변수**의 사용여부

일반적으로 **function**은 `매개변수들을` 가지고 새로운 `return`값을 만들어낸다. 하지만 **property**는 `return`값 ( 본인의 상태값)만 가질 뿐 매개변수를 가지고 있지 않는다. 대신 **computed property**는 처음 변수의 값이 연산된 값을 가질 뿐이다. 매개변수를 통해 계산을 하는 것이 아니라 클래스의 필드 값이나 다른 전역변수의 값을 이용하여 값을 정하게 되는 것이다. 



### 3) Computed Property의 사용 

프로젝트를 진행하면서 버튼의 활성화 상태를 가리키는 값을 사용게 되었다. 

**상황**

1. 전화를 연결하는 전화하기 버튼이 있다. 
2. 전화하기 버튼은 특정 조건에서만 활성화되고 그렇지 않은 경우 비활성화 되어있다. 
3. 활성화/비활성화 상태를 알려주는 값이 `ViewModel`에 존재한다. 



처음에 위 상황을 구현하기 위해서 Bool 값을 반환하는 메소드를 만들었다. 

<script src="https://gist.github.com/gwonii/2371c728b0f5930cd2344247674b84a8.js"></script>

위 처럼 `canCall` function을 만들어서 활성화/비활성화 상태를 표현하도록 만들었다. 하지만 이 코드에는 여러 문제가 있었다. 

**문제점**

1. 이 함수는 매개변수의 값만을 이용하여 return 값을 만드는 순수함수가 아니다.  (클래스의 상태값을 이용하여 return 값을 만드는 함수이다. )
2. 현실세계에서 바라볼 때 Bool 값을 리턴할 뿐, 행동이라고 말하기 애매하다. 



이러한 문제점으로 인하여 **function**을 사용할 것이 아니라 **Computed Property**를 사용하도록 권유받았다. <u>호출에 대한 비용이 적고 복잡한 함수가 아니라면 또는 단순히 상태값을 나타내고 싶을 때 **property**를 쓰는 것이 일반적인 것이다.</u>

그래서 메소드를 **Computed Property**로 구현해보았다. 

<script src="https://gist.github.com/gwonii/8a8f78da51144c445f8a84041dc096d6.js"></script>



### 예상되는 문제점

예전에 책에서 설계를 할 때 불필요한 property를 많이 만들지 말라는 얘기를 들었다. property가 많아지면 결국 class가 가지고 있는 상태들이 많아져서 무거워진다는 것이다. 그러면 역할의 분리가 힘들어질 수 있다. 

적절한 **상태**와 **행동**을 통해 올바른 메시지를 보낼 때, 그 class를 잘 만들어진 class라고 할 수 있다. 

위와 같은 문제점은 나의 개인적인 생각이다. 그런데 이 문제점은 설계를 통해 쉽게 해결할 수 있다고 생각한다. <u>property가 많아지는 것은 해당 class에 과도한 책임이 부여되었다고 생각할 수 있다. 그렇다면 역할들을 분리하고 class들끼리 서로 협력할 수 있도록 설계를 하는 것이다. 그러면 과도한 property의 생성을 줄일 수 있다고 생각한다.</u> 



## 사설 

이번 포스트는 어떻게 보면 굉장히 사소한 내용일 수 있다. 하지만 이러한 사소한 생각들이 앞으로 나를 더 발전시킬 것이라고 생각한다. 사소하더라도 항상 설계를 하고 개발을 할 때는 생각을 많이 해야된다!! 그래야 몸이 덜 고생한다. 



> [참고문헌 1. Functions vs Computed property — What to use?](https://medium.com/swift-india/functions-vs-computed-property-what-to-use-64bbe2df3916)





























