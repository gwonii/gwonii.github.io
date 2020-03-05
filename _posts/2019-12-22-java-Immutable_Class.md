---
layout: article
title: Immutable class 사용기
tags:
- Java
- Immutable Class
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

immutable은 무엇인가? 이전에 코드를 작성하면서 java 에도 val이라는 타입이 있는 것을 발견하였다. val 타입의 경우 우변의 타입에 따라 자동적으로 타입이 변하게 된다. 그런데 코틀린에서는 기본적으로 var은 불변객체이다. 그런데 자바는 그렇지 않다. 메리트의 정도가 다른 것이다. 그런 의미에서 immutable에 대해 알아보자.

<!--more-->
---



## Immutable이란? 

**Immutable class란 변경이 불가능한 클래스이며, 가변적이지 않은 클래스이다.** 

그렇다면 왜 가변적이지 않은 클래스가 중요한 것인가? 

첫째로 생각나는 것은, 방어적인 코드를 작성하지 않아도 되기 때문이다. 기본적으로 클래스는 생성자, 접근 메소드들로 인해 값이 변할 수 있다. 하지만 클래스내에 값이 변하기를 원하지 않는 경우라면 이러한 변화요소들을 모두 막기가 힘들다. 

그렇기 때문에 처음부터 Immutable class로 사용하는 것이다. 



### 대표적인 Immutble class 

1. `String`

   보통 String을 변화시키려고 할 때 사람들은 해당하는 String 값을 바꾼다고 생각한다. 하지만 , String의 경우 값을 바꾸면, 값이 변하는 것이 아니라 새로운 주소에 새로운 객체를 생성한다. 

   `주의`그렇기 때문에 무분별한 String의 사용은 자칫 메모리의 부하를 일으킬 수도 있다... 

2. `String` vs `StringBuilder`

   StringBuilder는 String과 다르게 mutble한 특성을 가지고 있다. 그렇기 때문에 값을 할당하면 String처럼 새로운 객체를 생성하는 것이 아니라, 값을 변경한다. 

   `장단점` StringBuilder는 쉽게 값을 변경하고 자원을 재활용한다는 장점을 가지고 있다. 하지만 반대로 말하면, 언제든지 어떤 메소드에 의해 값이 변경될 수도 있는 것이다. 그런데 그 사소한 값의 변경이 프로그램에 치명적인 결함을 만든다면,,, 그 때가서 후회해도 늦을 것이다. 



