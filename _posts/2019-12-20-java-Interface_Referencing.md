---
layout: article
title: 인터페이스 참조하기!
tags:
- Java
- 'Effective Java'
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

평상시에 자연스럽게 클래스로 선언을 미리 해놓는 경우가 많다. 그렇게 되면 나중에 다른 클래스로 쉽게 변경시킬 수 가 없다. 그러한 방법을 해결하기 위해 클래스가 아닌 인터페이스로 선언을 하자. 그리고 때에 따라 클래스로 인스턴스를 생성하자. 

<!--more-->
---

## 객체를 참조할 때는 그 인터페이스를 사용하라!



평소에 적당한 인터페이스 자료형이 존재한다면, 인자나 반환값, 변수 그리고 필드의 자료형은 클래스 대신 인터페이스로 선언하자. 

실제 클래스를 참조할 필요가 있는 순간은 인스턴스가 생성될 때이다. 

```java
case1 (좋은 예)
	List<Person> personList = new ArrayList<>();

case2 (나쁜 예)
    ArrayList<Person> people = new ArrayList<>(); 
```



**인터페이스 자료형을 자주 쓰게 되면 프로그램은 더욱 유연해진다.** 

가령 갑자기 객체의 실제 구현을 다른 것으로 바꾸고 싶으면 호출하는 이름만 다른 클래스로 이름을 바꿔주면 된다. 

```java
case3 (좋은 예)
	List<Person> pepo = new Vector<>();
```

위와 같은 방식으로 유연성을 확보하자. 











