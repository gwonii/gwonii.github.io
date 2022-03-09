---
layout: article
title: Map, Filter, Reduce
tags:
- Swift
- iOS
- Swift Grammar
- Higher-order Function
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false


---

대표적인 고차함수인 Map, Filter, Reduce에 대해 알아보자... 

<!--more-->

# Map, Filter, Reduce



## 고차함수 정의

고차함수란 **다른 함수를 전달인자로 받거나** 함수실행의 **결과를 함수로 반환하는 함수**’를 뜻합니다.



## Map 

```swift
// Declaration
func map<U>(transform: (T) -> U) -> Array<U>	

[x1, x2, ... xn].map(f) -> [f(x1), f(x2), ... , f(xn)]
```

하나의 array에서 연산 (f)를 걸친 새로운 array를 만들어낸다. 



```swift
array.map({ (value -> Int in return value * value) })
|
|축약 후 
|
array.map( { $0 * $0 }) 
```

다음과 같이 코드가 축약될 수 있는 이유는 swfit에서는 **추론**이 가능하기 때문이다. 



## Filter 

```swift
// Declaration
func filter(includeElement: (T) -> Bool) -> Array<T>
```

`includeElement`를 지원하는 클로저는 항목이 포함되어야 하는지 아닌지 `true` or `false` 를 통해 확인한다. 



```swift
array.filter( { (value) -> Bool in return value % 2 == 0})
```

위의 코드는 `array`의 `value`가 짝수라면 배열에 넣고 그렇지 않으면 넣지 않는 배열을 만드는 코드이다. 



## Reduce 

```swift
// Declaration
func reduce<U>(initial: U, combine: (U, T) -> U) -> U
```

 `initial: U` reduce을 적용시킬 배열의 첫번째 지점

`combine: (U, T) -> U` 클로저에서 두 값을 이용해서 연산될 함수



```swift
array.reduce(0, { (beforeValue: Int, afterValue: Int) -> Int in return beforeValue + afterValue})
|
| // 축약후
|
array.reduce(0, { $0 + $1 })
|
| // 더 축약한다면, 
|
array.reduce(0, +)
```

#### reduce 동작과정 

1. initial값을 가지고 첫번째 연산을 진행한다. 
2. 그 이후 두 인자를 받아서 연산을 진행한다. 

**Example**

```swift
array: [Int] = [1,2,3]

array.reduce(0, { (first, second) -> Int in
                return first + second })
```

1. initial 값을 가지고 만들어진 첫번째 연산 —> 0 + 1 
2. 그 이후 1 + 1 (index: 0) , 2 + 2 (index: 1), 4 + 3 (index: 2)

그러면 결과값으로 7을 얻을 수 있다. 

















