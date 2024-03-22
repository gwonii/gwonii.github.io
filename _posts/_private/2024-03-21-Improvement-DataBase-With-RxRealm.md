# Improvement Realm Issue

# Background

현재 개발하고 있는 Application에서는 Realm DB를 사용하고 있다. 그리고 모든 데이터를 DB 에 우선 저장한 후 Presentation 에 전달하도록 구현되었다.

가령 Server 에 데이터를 요청하게 되면 Response 값을 바로 사용하는 것이 아닌 DB 에 Entity 를 저장하고 그것을 Presentation 과 바인딩 하여 사용하는 형태이다.

그러다보니 DB에 문제가 생기면 앱에 큰 문제를 일으킬 수 있었다. 그리고 불행히도 DB Crash 가 다수 발생되어 있었고 빠르게 오류를 수정해야 했다.

# Cause Analytics

Firebase 에서 확인 결과 다양한 crash 오류들을 확인할 수 있었다. 

- **RLMException - Realm accessed from incorrect thread.**
- **RLMException - The Realm is already in a write transaction**
- **RLMException - Realm at path ‘…’ already opened with different encryption key**
- **RLMException - Cannot register notification blocks from within write transactions.**
- **std::bad_alloc - Realm notification listener**

…

Crash 항목을 정리해봤을 때 크게 두 가지로 나눠볼 수 있었다. 

1. Realm Object 생성 및 접근 오류
2. Realm Memory 과부하 오류

## 1. Realm Object 생성 및 접근 오류

- **RLMException - The Realm is already in a write transaction**
- **RLMException - Realm accessed from incorrect thread.**
- **RLMException - Realm at path ‘…’ already opened with different encryption key**

위 문제의 경우 원인이 분명하였다. 

**1. Realm 객체에 CRUD 를 요청시에 Realm 객체를 계속 생성시킨다.** 

Realm 객체의 경우 Entity 에 따라 각 객체가 구분된다. (ex. ChannelRealm, MessageRealm, MemberRealm … )

그리고 Channel Data 를 요청할 때마다 ChannelRealm 을 생성 한 후 결과값을 리턴한다. 

그 결과 `aleardy opened` 와 같은 오류가 발생되었다. 

**2. Realm 객체 initialize와 access thread 가 main thread 이다.** 

Realm Documents 에 따르면 Realm initialize와 access thread 는 `main thread` 또는 `SerialQueue` 를 사용하라고 가이드 되어있다. 또한 생성한 thread 에서 반드시 접근해야 한다.

그런데 CRUD 요청시에 main thread 에서 Realm 객체를 생성 할 뿐만아니라 CRUD 작업을 수행하니 Thread 이슈가 발생될 수 밖에 없었다. 

## 2. Realm Memory 과부하 오류

해당 원인은 Realm 객체에 너무 많은 요청을 하게 되어 발생한 경우가 많았다.

많은 요청을 하게 된 원인은 각 View 에서 DB 에 직접 데이터를 바인딩하고 사용했기 때문이다. 

기존 구현된 코드에서는 실시간으로 데이터를 빠르게 변경시키기 위하여 TableView 의 cell 에서 Realm DB 를 구독하는 형태로 사용되었다. 

그렇다보니 Cell 의 lifeCycle 에 따라 무한히 많은 CRUD을 요청하게 되었고 결과적으로 App Memory 에 과부하를 만들었다. 

또한 `isInWriteTransaction` 키워드를 자주 사용하여 앱 성능에 문제를 일으키고 있었다. 

# Solution

## 1.1 Realm 객체에 CRUD 를 요청시에 Realm 객체를 계속 생성시킨다.

위 문제를 해결하기 위하여 Entity 에 따라 Singleton Realm 객체를 사용하고 공유할 수 있도록 하였다. 

그 결과 Realm 객체 생성 비용이 줄어들고 `already opend` crash 문제를 해결할 수 있었다. 

## 1.2 **Realm 객체 initialize와 access thread 가 main thread 이다.**

위 문제를 해결하기 위하여 Realm 객체의 생성 및 접근 시에 Dispatch SerialQueue 를 사용할 수 있도록 변경하였다.

Realm 에서는 생성 및 접근 Thread 가 동일해야 하므로 각 Entity 에 맞는 Realm 객체를 class 에 wrapping 하여 중간에 Thread 가 변경되지 않도록 하였다.

## 2. Realm Memory 과부화 오류

1. **TableView 내에 cell model 에서 각각 Realm 객체에 바인딩시키지 않고 TableView model 에서 관리할 수 있도록 하였다.** 

값의 변경이 발생되면 TableView 의 List Model 을 변경시키고 각 cell 들에 반영될 수 있도록 변경하였다. 

뿐만 아니라 작은 단위의 View Model 에서 직접 DB 를 바인딩하고 있는 코드를 모두 제거하였다. 

1. **단순 CRUD 요청시에 매번 확인하는 isInWriteTransaction 조건을 제거하였다.** 

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

Realm 내에서도 `isInWriteTransaction` 프로퍼티는 매번 사용하지 말라고 경고 하고 있다. 실제로 race condition 을 예방하고자 사용된 것으로 보이지만 불필요한 사용으로 판단하여 제거하였다.