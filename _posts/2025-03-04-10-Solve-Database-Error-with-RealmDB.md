---
layout: article
title: "[Problem Solving] RealmDB 관련 크래시 해결하기" 
tags:
- iOS
- Database
- RxRealm
- Problem Solving
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

RealmDB 에서 발생했던 크래시 수정 내용을 정리해 보고자 한다. 

<!--more-->

# 1. 목적
- RealmDB 에서 발생하는 크래시의 원인을 분석하고 해결방안을 제시하고자 한다. 

# 2. 이유
현재 개발하고 있는 앱에서는 Realm DB를 사용하고 있다. 그리고 모든 데이터를 DB 에 캐싱된 데이터를 우선 사용하고 Remote 데이터로 덮어쓰일 수 있도록 구현되었다. 
가령 Server 에 데이터를 요청하게 되면 Response 값을 바로 사용하는 것이 아닌 DB 에 Entity 를 저장하고 그것을 Presentation 과 바인딩 하여 사용하는 형태이다.

<Br>

그러다 보니 서비스 전체적으로 RealDB 가 필수적으로 사용되고 있고 여러 오류가 발생되었다 

# 3. 실행

## 크래시 분석
Firebase 에서 확인한 결과 다양한 크래시 오류를 확인할 수 있었다. 

- **RLMException - Realm accessed from incorrect thread.**
- **RLMException - The Realm is already in a write transaction**
- **RLMException - Realm at path ‘…’ already opened with different encryption key**
- **RLMException - Cannot register notification blocks from within write transactions.**
- **std::bad_alloc - Realm notification listener**

<br>

Crash 항목을 정리해봤을 때 크게 두 가지로 나눠볼 수 있었다. 
- Realm Object 생성 및 접근 오류
- Realm Memory 과부하 오류

## 1. Realm Object 생성 및 접근 오류
- **RLMException - The Realm is already in a write transaction**
- **RLMException - Realm accessed from incorrect thread.**
- **RLMException - Realm at path ‘…’ already opened with different encryption key**

위 문제의 경우 원인이 분명하였다. 

<br>

### 원인 1
**1. Realm 객체에 CRUD 를 요청시에 Realm 객체를 계속 생성시킨다.** 

Realm 객체의 경우 Entity 에 따라 각 객체가 구분된다. (ex. ChannelRealm, MessageRealm, MemberRealm … )
그리고 Channel Data 를 요청할 때마다 ChannelRealm 을 생성 한 후 결과값을 리턴한다. 

<Br>

반복적인 Realm 객체 생성은 불필요한 리소스를 사용하며, 비동기적으로 객체 생성을 요청하는 경우 
`aleardy opened` 오류가 발생될 수 있다.

### 해결 1
- 위 문제를 해결하기 위하여 Entity 에 따라 Singleton Realm 객체를 사용하고 공유할 수 있도록 하였다.
- 또한 세션 생성시에만 새로운 Realm 객체를 생성하게 하여 반드시 필요한 구간에서만 객체가 변경될 수 있도록 하였다.
- 그 결과 Realm 객체 생성 비용이 줄어들고 `already opend` crash 문제를 해결할 수 있었다. 

---

### 원인 2
**2. Realm 객체 생성/접근 시에 쓰레드 제약이 없었다.** 
Realm Documents 에 따르면 Realm initialize와 access thread 는 `main thread` 또는 `SerialQueue` 를 사용하라고 가이드 되어있다. 또한 반드시 생성 당시 사용된 쓰레드로 접근해야 한다.

그런데 CRUD 요청시에 요청 블럭에 있는 쓰레드를 그대로 Realm 객체 생성/접근에 사용하고 있었다. 

결국 생성시에는 메인 쓰레드가 사용되고 접근시에는 백그라운드 쓰레드가 사용되는 상황이 많이 발생되었다. 
또한 Realm 객체 접근시에 메인 쓰레드를 사용하는 경우에는 사용자가 경험할 수 있을 정도의 cpu 과부화가 발생되었다.

<Br>

### 해결 2
- 위 문제를 해결하기 위하여 Realm 객체의 생성 및 접근 시에 Dispatch SerialQueue 를 사용하도록 변경했다.
- RealmDB 를 생성할 때만 쓰레드를 정할 수 있게 하고, 접근할 때는 객체 생성 때 사용된 쓰레드를 쓰도록 강제하였다. 
- 결국 개발자는 RealmDB 접근시에는 쓰레드를 고려하지 않아도 되었고, 쓰레드 관련 오류는 완전히 제거될 수 있었다.

## 2. Realm Memory 과부하 오류

### 원인
해당 원인은 Realm 객체에 너무 많은 요청을 하게 되어 발생한 경우가 많았다.

많은 요청을 하게 된 원인은 각 View 에서 DB 에 직접 데이터를 바인딩하고 사용했기 때문이다. 

기존 구현된 코드에서는 실시간으로 데이터를 빠르게 변경시키기 위하여 TableView 의 cell 에서 Realm DB 를 구독하는 형태로 사용되었다. 

그렇다보니 Cell 의 lifeCycle 에 따라 무한히 많은 CRUD을 요청하게 되었고 결과적으로 App Memory 에 과부하를 만들었다. 

또한 `isInWriteTransaction` 키워드를 자주 사용하여 앱 성능에 문제를 일으키고 있었다. 

### 해결

1. **TableView 내에 cell model 에서 각각 Realm 객체에 바인딩시키지 않고 TableView model 에서 관리할 수 있도록 하였다.** 

  - 값의 변경이 발생되면 TableView 의 List Model 을 변경시키고 각 cell 들에 반영될 수 있도록 변경하였다. 
  - 뿐만 아니라 작은 단위의 View Model 에서 직접 DB 를 바인딩하고 있는 코드를 모두 제거하였다. 

2. **단순 CRUD 요청시에 매번 확인하는 isInWriteTransaction 조건을 제거하였다.** 

```swift
/**
 Indicates whether the Realm is currently in a write transaction.

 - warning:  Do not simply check this property and then start a write transaction whenever an object needs to be
             created, updated, or removed. Doing so might cause a large number of write transactions to be created,
             degrading performance. Instead, always prefer performing multiple updates during a single transaction.
 */
public var isInWriteTransaction: Bool {
    return rlmRealm.inWriteTransaction
}
```

Realm 내에서도 `isInWriteTransaction` 프로퍼티는 매번 사용하지 말라고 경고하고 있다. 실제로 race condition 을 예방하고자 사용된 것으로 보이지만 불필요한 사용으로 판단하여 제거하였다.