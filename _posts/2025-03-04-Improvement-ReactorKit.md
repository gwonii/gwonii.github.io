---
layout: article
title: "[Problem Solving] ReactorKit 관련 코드 개선 작업" 
tags:
- iOS
- ReactorKit
- RxSwift
- Problem Solving
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

ReactorKit 을 잘못 사용하고 있는 부분을 확인하고 개선해보고자 한다. 

<!--more-->

# 1. 목표
- ReactorKit 관련 코드를 분석하여 잘못 사용되고 있는 부분을 개선한다. 

# 2. 이유
- ReactorKit 은 iOS 에서 상태관리를 위하여 사용되는 라이브러리이다. 
- 그런데 라이브러리를 잘못 오용하게 되어 크래시 및 성능상의 오류가 발생되었다. 
- 해당 문제들은 서비스 이용에 큰 불편함을 주기 때문에 빠르게 개선하고자 했다. 

# 3. 실행

## 1. 의도치 않은 API 요청으로 인해 서버에 부하를 야기하였다. 

### 원인
- 상태와 뷰를 일대일 대응시키고자 `CellReactor` 를 구성하여 직접 Local/Remote 데이터를 요청하였다. 
- `distinctUntilChanged` 가 누락되거나 `Equatable` 메소드를 새로 정의하지 않아 의미없는 변경에도 반복적으로 Local/Remote 데이터를 요청하였다. 

### 해결
- TableView 의 Cell 에는 따로 Reactor 를 구성시키지 않도록 하였다.
  - 간혹 Cell 의 이벤트가 많은 경우, 이벤트 바인딩을 위한 용도로만 사용하였다.
- View 전체의 Reactor 에서 Cell 데이터를 관리하고, Cell 에게는 View State 만 전달하는 방식으로 개선하였다. 
- `Equatable` 메소드가 정의가 누락된 부분들을 찾아 새롭게 정의하였다. 
- 또한 `Pulse` 와 `distinctUntilChanged` 를 사용하여 불필요한 변경은 무시될 수 있도록 개선하였다.


## 2. State 경량화

### 원인
- 상위/하위 계층을 구분하지 않고 Reactor 를 구성하여 하나의 State 에 과도한 정보들이 포함되었다.

### 해결
- 거대해진 Reactor 를 화면 구성요소에 따라 분리하였다.
- 상위 Reactor 를 먼저 구성하고, 검색창, 입력창 등의 구성요소에는 하위 Reactor 를 구성하였다. 
- 각 구성요소에서 처리해야 항목들은 하위 Reactor 에서 처리하고 전체 UI에 영향을 주는 것들은 하위 Reactor 와 바인딩된 상위 Reactor 에서 공통처리 할 수 있도록 하였다. 

## 3. Reactor 의 Thread 설정. 

### 원인
- Reactor 에서 쓰레드를 따로 지정하지 않아 메인 쓰레드가 사용되는 경우가 발생하였다. 
- Reactor 에서는 수 많은 액션과 상태변화로 사용자에게 불편함을 주었다. 

### 해결
- Reactor 별로 Serial Queue 쓰레드를 사용할 수 있도록 하였다. 
- 순차적으로 상태변화를 만들고 UI 에 전파될 수 있도록 하였다. 
- UI 에서는 Drivier, Signal 을 이용하여 항상 메인 쓰레드에서 UI 가 갱신될 수 있도록 보장하였다. 


# 4. 결과
- Reactor 관련 개선을 하면서 눈에 띄기 성능이 개선된 화면들을 볼 수 있었다. 
- 서버측에서도 과도한 API Call 로 인하여 문제되었던 부분들도 해결되었다.
- 아직 모든 서비스에 적용시키지는 못하였지만 하나하나 순차적으로 변경하려고 한다. 
