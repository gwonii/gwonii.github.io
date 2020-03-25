---
layout: article
title: URLSession을 이용한 네트워크 통신
tags:
- URLSession
- network
- iOS
- SwiftUI
- Combine
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

개발을 하는데 있어서 네트워크 통신은 기본이다. 그런데 iOS개발을 시작하고 제대로 네트워크 통신에 대해 공부해보지 못했다. 그래서 이번 기회에 회사 선배님의 코드도 이해할겸 URLSession을 이용하여 원초적인 네트워크 통신을 구현해보았다. 

<!--more-->



# Swift, Http로 network 통신하기 



## 개요

이제 DO 모바일 renewal 프로젝트를 시작하면서 첫번재로 받은 업무는 모바일의 DB와 Network 통신의 백엔드 부분이었다. 아직 UI 디자인이 나오지 않은 상태에서 UI개발을 진행할 수 없기에 먼저 백엔드 부분에 집중을 하게 되었다. 

현재 선배님께서 DO renewal 프로젝트에 사용할 network 통신 라이브러리를 직접 만들고 계신다. 원래는 **Alamofire**를 랩핑한 **Moya**를 사용하려고 했으나, 해당 DO 프로젝트에 더 맞는 통신 프로토콜을 위해 Http 통신을 직접 사용하여 라이브러리를 구성하셨다. 그렇기에 이후에 통신을 작업하는 과정에 swift에서의 http 통신에 미숙하다면, 큰 문제가 생길 것이기에 미리미리 공부를 시작한다. 

*2020-03-25 Wed*

현재 network 통신 라이브러리는 선배님이 직접 만든 라이브러리가 아닌 `Alamofire`로 변경되었다. 그 이유는 이 후에 여러 문제가 생길 수 있기 때문에!!! 나쁘지 않은 선택이라고 생각한다. 선배님은 많이 아쉬워 하시는 것 같지만… 



## 배울 것

* 기본 iOS 프레임워크에 내장되어 있는 http request를 이용해서 통신하기
* http request를 MVVM 구조와 연결시키기 

이 두가지만 확실하게 알아 간다면 나이스! 



### URLSession OverView

`URLSession`은  <u>is both a class and a suite of classes for handling HTTP- and HTTPS-based requests</u>

![p-f-01](<https://raw.githubusercontent.com/gwonii/SwiftUI-Project/master/Project_F/img/p-f-01.png>)

그림에서 보면 `URLSession`은 `Cache` , `Cookies`, `Cred`, `Protocols` 의 데이터 저장 형태와 Option을 담고 있는 `URLSessionConfiguration`과 해당 데이터를 전달하는 `Delegate`로 구성되어 있다. 

이러한 정보들을 가지고 http 통신을 가능하게 클래스의 일종이 바로 `URLSession`이다. 

> **원문**
>
> `URLSession` is the key object responsible for sending and receiving requests. You create it via `URLSessionConfiguration`, which comes in three flavors:



### URLSession Configuration에 따른 종류 

- ***default***: Creates a default configuration object that uses the disk-persisted global cache, credential and cookie storage objects.
- ***ephemeral***: Similar to the default configuration, except that you store all of the session-related data in memory. Think of this as a “private” session.
- ***background***: Lets the session perform upload or download tasks in the background. Transfers continue even when the app itself is suspended or terminated by the system.

해당 원문에 정리된 내용이다. 일단은 위 내용은 넘기고 직접 사용해보면서 경험해보도록 하자! 



또한 추가적으로 `URLSessionConfiguration`을 통해 `timeout value`, `caching polices`, `http header`등을 직접 설정할 수 있다. 



### URLSessionTask



`URLSessionTask`에는 세 가지의 타입이 있다고 한다. 

- ***URLSessionDataTask***: Use this task for GET requests to retrieve data from servers to memory.
- ***URLSessionUploadTask***: Use this task to upload a file from disk to a web service via a POST or PUT method.
- ***URLSessionDownloadTask***: Use this task to download a file from a remote service to a temporary file location.

이름 그래도 하는 일을 대충 알 수 있을 것 같다. 후

기존에 사용해보지 않은 method가 있다면, `URLSessionDownLoadTask` 정도? 기본적으로 GET 메소드나 POST 메소드는 사용해보았는데 파일을 직접 DownLoad 해본적은 없다. 이번 프로젝트에 사용해볼 수 있을 것 같다. 



![p-f-02](<https://raw.githubusercontent.com/gwonii/SwiftUI-Project/master/Project_F/img/p-f-02.png>)







## 과정

### 프로젝트 내용 

**특정 API를 이용해서 가수 노래제목을 받아 List 구현하기**



### 1. URLSession을 통해 데이터 요청하기 

**ServiceQuery.swift**

```swift
    func urlQuery(searchTerm: String) {
        
        /// step 1
        dataTask?.cancel()
        
        /// step 2
        if var urlComponents = URLComponents(string: "https://itunes.apple.com/search") {
            urlComponents.query = "media=music&entity=song&term=\(searchTerm)"
            
            /// step 3
            guard let url = urlComponents.url else {
                return
            }
            
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                /// step 4
                if let error = error {
                    self?.errorMsg += "DataTask error : \(error.localizedDescription) \n"
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self?.updateSearchResults(data)
                }
            }
        }
        dataTask?.resume()
    }
```



**Step 1**

* 먼저 기존에 사용되고 있던 sessionTask가 있을 수 있으므로 `dataTask?.cancel()`을 통해서 Task를 비워준다. 

**Step 2**

* 그 후 `URLComponents`을 이용해서 서버에 직접 데이터를 요청한다. 

그리고 이후에 `ulrComponents`에 query문을 추가해준다. 보통 server에 request를 보낼 때, 

>  `header`, `query`등등의 데이터를 담아 보낸다. 이건 나중에 시간날 때 따로 또 정리하도록 하자 . 

**Step 3**

query문이 담은 url이 온전하게 만들어졌다면, 해당 url을 가지고 `dataTask`를 만든다. 그리고 해당 Task를 통해 올바른 데이터가 왔다면, 200 응답이 오면서 **response**에 데이터가 담겨 왔을 것이고 

**Step 4** 

그렇지 않으면 **error**를 발생시켰을 것이다. 



그 후 

```swift
    private func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        tracks.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMsg += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        
        guard let array = response!["results"] as? [Any] else {
            errorMsg += "Dictionary does not contain results key\n"
            return
        }
        
        var index = 0
        
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? JSONDictionary,
                let previewURLString = trackDictionary["previewUrl"] as? String,
                let previewURL = URL(string: previewURLString),
                let name = trackDictionary["trackName"] as? String,
                let artist = trackDictionary["artistName"] as? String {
                tracks.append(Track(name: name, artist: artist, previewURL: previewURL, index: index))
                index += 1
            } else {
                errorMsg += "Problem parsing trackDictionary\n"
            }
        }
    }
```



json형식으로 전달된 데이터를 parsing하게 되면 데이터를 원하는대로 사용할 수 있다. 

거의 기존 ref의 코드를 따라고 있지만, 대략적인 흐름을 알 수 있다. 



### 핵심사항 

결국 urlSession을 통해 서버에 request를 보내는 것은 

1) `urlComponents`를 통해서 **URL**을 만든다. 

2) 만들어진 URL을 이용해 `URLSession`으로 SessionTask를 만든다. 

3) Session을 통해 server에 데이터를 요청하고 원하는 데이터를 받는다. 



위 처럼 데이터를 요청하고 받는데 있어서 복잡한 구성을 갖고 있지 않다. 



## ISSUE



**SwiftUI**위에서 구현을 하다보니 자연스럽게 **MVVM**의 구조로 구현하게 되었다. 그리고 **Combine**을 이용하여 `URLSession`을 통해 통신을 하는 과정을 **비동기적**으로 처리하였다. 그런데 Combine을 사용하는 과정에 있어서 문제가 생겼다. 



**request를 보낸 후 데이터를 받기전에 list를 화면에 출력한다. **

**mutex lack**이나 **Semaphore**를 이용해 보았지만, 사용법을 제대로 숙지하지 못해 문제를 해결할 수 없었다. 

url request를 보내고 **sleep**을 걸었다. 

원초적인 방법이지만, 문제는 해결되었다. 



위와같은 문제는 combine을 이용하여 처리할 수 있다고 생각한다. main thread에서 비동기처리를 하는 동시에 동기화해야 하는 부분에 한해서 조정이 가능할꺼라고 생각하지만 구현하지 못했다. 이후에 openCombine 클론뜨고 공부를 하면서 비동기 문제를 해결할 수 있는 방법을 천천히 찾아가보도록 하자…. 문제가 많다. ㅠ





## 여담

화이팅



> [포스트 전체 코드](https://github.com/gwonii/SwiftUI-Project/tree/master/Project_F)

> [원문 출처 - URLSession Tutorial: Getting Started](https://www.raywenderlich.com/3244963-urlsession-tutorial-getting-started)



