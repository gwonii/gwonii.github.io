---
layout: article
title: 'Encoding & Decoding'
tags:
- CS
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

JSON을 정리했으니, 인코딩, 디코딩도 한 번 정리해야죠?? 

<!--more-->

# Encoding & Decoding



## 개요

이전 `JSON 파헤치기`라는 내용을 포스트하면서 거기에 크게 신경쓰지 않고 사용하던 개념이 있었습니다. 

그것은 바로 **Encoding과 Decoding**...

그래서 내용을 따로 정리해서 블로깅하려고 합니다~ 

`JSON 파헤치기` 를 보지 못하신 분은 

[gwonii 블로그, JSON 파헤치기](https://gwonii.github.io/2020/08/31/JSON.html)

## 정의

**encoding**: 부호화하다. 

`부호화`라는 것이 분야마다 다양하게 해석될 수 있지만, 컴퓨터 프로그래밍 관점에서는 

**입력 데이터를 컴퓨터 속에서 사용하는 코드로 변환하는 것** 정도로 이해하면 좋을 것 같다. 





ex) Character Encoding

1) 모스부호

모스 부호도 문자 인코딩 방식중에 하나이다. 

2)

* ASCII Code 
* UNICode

아스키 코드와 유니코드는 문자나 기호들의 집합을 컴퓨터에 저장하거나, 통신 목적으로 이용될 때 주로 사용된다. 





**ASCII Code**: **American Standard Code for Information Interchange**

말 그대로 미국에서 정의한 표준화된 부호체계이다. 

**특징**

아스키 코드는 7비트 즉, 128개의 고유한 값을 사용하여 문자열을 표현한다. 

1바이트에서 1비트는 통신 에러 검출을 위해 사용된다.



**사설**

1바이트로 표현되는 경우: **SBCS(Single Byte Character Set)** 라고 한다. 

아닌 경우: **MBCS(Multi-Byte Character Set)**



잘 모르지만, 1바이트 이상의 데이터를 사용하는 아스키 코드도 있는 것 같다. 



**UNICode**

유니코드 협회(Unicode Consortium) 에서 제정하였고, 전 세계의 모든 문자를 컴퓨터에서 일관되게 표현하고 다룰 수 있도록 설계된 산업 표준이다. 아스키코드를 16비트로 확장하여 전 세계의 모든 문자를 표현한다.



## 개념

여기서 주로 알아보려고 하는건 Swift에서 사용되는 `Encoding`과 `Decoding`이다. 



### 1. Codable

A type that can convert itself into and out of an external representation

해석해보면, 자신을 변환하거나 외부표현( External Representation )으로 변환할 수 있는 타입을 얘기한다. 





인코딩과 디코딩을 설명하기 전에 `Codable`에 대해 알아보자. 

`Codable`은 간단하게 얘기하면 `Encoding`과 `Decoding`을 합쳐놓은 것이다. 





**Declaration**

```swift
typealias Codable = Decodable & Encodable
```



### 2. Encodable

A type that can encode itself to an external representation.

자신을 외부표현으로 인코딩 할 수 있는 타입

<br/>

이전의 개념을 적용해보자면, 

EX) JSON

한 `object` `JSONEncoder` 를 통해 Data 타입으로 만들 수 있다.

다시 말해 `JSON` 형태의 모양으로 컴퓨터가 이해할 수 있는 `Data`를 만들었다고 할 수 있다.

<br/>

> 그냥 이전에 JSON을 사용해서 `JSONEncoder`를 사용했다. 그냥 `Encoder`를 사용해서도 `Data` 타입을 만들 수 있다. 

<br/>

**Example1**

```swift
struct Person: Codable {
	let name: String
  	let age: Int
}
```

위의 구조체는 `Codable` protocol을 채택하고 있다. 

그렇기 때문에 `Econding`, `Decoding`을 할 수 있는 타입이 된다. 

<br/>

**Encoding**

```swift
// property
let encoder: JSONEncoder = .init()
let gwonii: Person = .init(name: "gwonii", age: 28)

// func
func encodePersonToJson(person: Person) -> String? {
  guard let jsonData = try? encoder.encode(person),
  	let jsonString = String(data: jsonData, encoding: .utf8) else {
    	return nil
  	}
  
  return jsonString
}

// result
encodePersonToJson(gwonii)

/*
{
  "name": "gwonii",
  "age": 28
}
*/

```

<br/>

**Formatter**

`JSON` 형태를 `formatter`를 이용해서 보기좋게 표현할 수 있다. 

<br/>

**prettyPrinted**

```swift
// setting
encoder.outputFormatting = .prettyPrinted

// result
/*
{ "name": "gwonii", "age": 28 }
*/
```

<br/>

**sortedKeys**

```swift
// setting
encoder.outputFormatting = .sortedKeys

// result
/*
{
  "age": 28,
  "name": "gwonii"
}
*/
```

`sortedKeys`를 이용하게 되면 key값을 가지고 알파벳순으로 재정렬해준다. 

<br/>

**Formatting의 혼합사용**

`formatting`의 경우 여러 종류의 설정을 함께 할 수 있다. 

```swift
// setting
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

// result
/*
{ "age": 28, "name": "gwonii"}
*/
```

위와 같이 간단하게 프린트하면서 key값을 기준으로 출력할 수 있다. 

> 이외에도 





### Decodable

A type that can decode itself from an external representation.

자신을 외부표현에서 디코딩할 수 있는 타입

<br/>

`Encoding`과 반대로 `Data`의 형태를 다시 `Object`로 변환시킬 수 있는 타입을 말한다. 

다시 말해 `Data` 타입에서 사람이 볼 수 있는 타입으로 변환된 것이다. 



**Decoding**

```swift
// property
let decoder: JSONDecoder = .init()

// func
func decodeJsonToPerson(jsonString: String) -> Person? {
  let jsonData = jsonString.data(using: .utf8)
  let person: Person? = try? decoder.decode(Person.self, from: jsonData)
  return person
}
```

이 처럼 간단하게 `JSON`을 이용해서 `Encoding` & `Decoding`을 해보았다. 

<br/>

### 추가 자료

> 이 예시는 이전 post와 관련된 내용이므로 이해가 되지 않는다면 이전 포스트를 보고오세용
>
> [gwonii 블로그, JSON 파헤치기](https://gwonii.github.io/2020/08/31/JSON.html)





이전에 `[[String: Any]]`을 JSON 형태로 변환해야 하는 상황이 있었다. 

```swift
func postBadgeSetting(badgesData: [[String: Any]]) -> Single<BadgeResponse> {

  // Step 1
	guard let data = try? JSONSerialization.data(
      withJSONObject: badgesData, options: []) else {
            return .never()
      }
        
  // Step 2
	guard let badgesString = String(data: data, encoding: .utf8) else {
		return .never()
	}
        
  return self.requestSingle(
    path: "/api/user/mobile/badge/notisetting",
    header: HTTPHeader(name: "Content-Type",
	value: "application/json"),
    method: .post,
    parameters: [:],
    encoding: badgesString)
}
```

 

일단 **Step1**과 **Step2** 를 보면 `Object`를 `JSON`으로 encoding하는 과정이다. 

그런데 위의 `JSONEncoder`를 사용하는 것이 아니라, `JSONSerialization`을 사용하고 있다. 

그 이유는 `[[String: Any]]` 타입이 `Encodable`하지 않기 때문이다. 

`JSONSerialization`을 이용하면 `Encodable` protocol을 채택하지 않아도 data 타입으로 encoding이 가능하다. 





그리고 **Step2**에서 data 타입의 JSON을 String으로 변환하고 있다. 

그런 다음 `request`에 담아 API 요청을 하는 모습을 볼 수 있다. 





## 사설

이렇게 인코딩 & 디코딩에 대해 알아보는 시간을 가졌다. 좋은 기회였다. API 요청을 보낼 때 그냥 아무 생각없이 레퍼런스 자료들을 보면서 했지만 이렇게 하나 하나 파고드니까 이해하고 있지 못했던 큰 틀 중 하나의 톱니를 알 게 된 것 같아 기쁘다… 











