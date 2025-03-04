---
layout: article
title: I Decide Not To Use NSCache
tags:
- iOS
- Swift
- Foundation
- NSCache
- Dictionary
- 'Problem Solving'
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

NSCache와 Dictionary의 차이는 무엇이고 나는 무엇을 사용해야 하는걸까?

<!--more-->

# I Decide Not To Use NSCache

## Background 

새로운 기능 요구사항이 추가되었다.
**"조직도와 대화방 리스트에 사용자의 실시간 근태상태를 노출시켜주고 싶습니다."**

그래서 기능 요구사항에 따라 개발 요구사항들을 정리하였습니다. 

* 실시간으로 데이터를 저장하기 위하여 메모리내에 유저의 근태상태 정보를 캐싱한다. 
* XMPP 프로토콜에 의해 전달되는 데이터를 통해 캐싱된 데이터를 갱신시킨다. 
* "조직도", "대화방 리스트" 화면에서 캐싱된 근태상태 정보를 바인딩하여 UI를 업데이트 시킨다. 

```swift
├── Data
│   ├── DictionaryMemoryStorage.swift
│   └── NSCacheMemoryStorage.swift
├── Domain
│   ├── MemoryStorage.swift
│   └── Model
│       └── CommuteStatus.swift
└── Presenation
```

위와 같은 구조를 가지고 UI에서 사용할 수 있도록 MemoryStorage를 구성하도록 하였다. 

그렇다면 나는 **DictionaryMemoryStorage**, **NSCacheMemoryStorage** 중 어떤 것을 사용하는게 좋을 지 선택해야 했다. 그래서 둘을 철저하게 비교하면서 현재 요구사항에 맞는 구현체를 사용하려고 했다. 

이 포스트에서는 NSCache를 위주로 요구사항을 구현하는데 적절한가에 대한 시각으로 작성되었다. 그래서 Dictionary에 대한 자세한 내용은 담지 않았다. Dictionary에 대한 이해를 위해서는 다른 포스트를 참고해주길 바란다. 

<Br>

## NSCache

메모리를 관리하는데 있어서 `NSCache`을 직접적으로 사용해본 적이 없어서 간단하게 살펴보려고 한다. 

[NSCache Apple Document](https://developer.apple.com/documentation/foundation/nscache)

```swift
open class NSCache<KeyType, ObjectType> : NSObject where KeyType : AnyObject, ObjectType : AnyObject {

    open var name: String
    unowned(unsafe) open var delegate: NSCacheDelegate?
    open func object(forKey key: KeyType) -> ObjectType?
    open func setObject(_ obj: ObjectType, forKey key: KeyType)
    open func setObject(_ obj: ObjectType, forKey key: KeyType, cost g: Int)
    open func removeObject(forKey key: KeyType)
    open func removeAllObjects()

		// 저장소의 최대 용량(byte)
    open var totalCostLimit: Int
		// 저장소의 최대 저장 가능한 데이터 개수
    open var countLimit: Int
    open var evictsObjectsWithDiscardedContent: Bool
	
	// dicardable 한 content들이 discard 된 후에 evics 하게 할 것이냐? 
// evics:  Cache object 가 빠질 때
}
```

NSCache는 NSMutableDictionary를 이용해서 구현되어 있다. 그렇기 때문에 기본적으로 HashTable을 이용하여 데이터에 접근하게 된다.

**특징**
* ObjectType은 class만 사용이 가능하다. 
(만약 struct dataModel을 사용하고 싶다면 wrapper을 통해 Object를 만들어야 한다.)
* 저장소에 대한 설정을 할 수 있다. 데이터 최대 용량 및 최대 개수 등...
* NSCache Delegate를 제공한다. 

```swift
public protocol NSCacheDelegate : NSObjectProtocol {
    @available(iOS 4.0, *)
    optional func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any)
}
```
위 delegate를 통해 캐시된 데이터에서 evict 될 객체를 확인할 수 있다. 

추가적인 특징은 Dictoary와 비교를 해보며 알아보면 좋을 것 같다. 


**NSCache 주의사항**
NSCache 명세를 보면 key값이 Hashable 하지 않더라도 사용할 수 있도록 되어있다. 
하지만 customKey를 만들어 사용할 때 Hashable을 만족하지 않는다면 store, object 메소드를 수행해도 원하는 데이터를 불러올 수 없다. 

그렇기 때문에 CustomKey를 Hashable을 만족하도록 구현하거나
NSObject를 상속받고 isEqual, hash 메소드를 override 하여도 된다. 

<Br>

## NSCache vs Dictionary

|  | NSCache | Dicitonary |
| --- | --- | --- |
| Type | Class | Struct |
| Memory Management | automatic | passive |
| Thread | thread safe | non thread safe |
| read / write
Speed | looser | winner |

### Memory Management 

메모리를 관리하는데 있어서 NSCache는 **automatic** 하다고 한다.
언뜻보면 자동적으로 관리를 해주기 때문에 굉장히 좋은 기능이라고 할 수 있다. 하지만 현재 나의 요구사항을 구현하기 위해 적절한지는 의심해봐야 한다. 

필자는 전체 사용자에 대한 근태상태 정보를 저장하고 있어야 한다. 여기서 하나의 데이터라도 유실된다면 NSCache가 가지고 있는 데이터 전체가 신뢰할 수 없는 데이터가 된다. 

OS자체적으로 NSCache는 메모리 용량을 확인하고 불필요하다고 판단되는 데이터를 삭제한다. 
그런데 여기서 삭제되는 로직은 블랙박스기 때문에 개발자가 통제할 수 없다.

OS는 메모리를 효율적으로 사용하기 위하여 불필요한 데이터를 삭제하는 것이지만 필자에게는 절대 있어서는 안되는 일이다.

<Br>

💡 **When use NSCache?**

그렇다면 NSCache는 언제 사용하는 것일까?
보통 자동적으로 In-Memory의 데이터가 자동적으로 관리되었으면 하는 부분에 사용될 것이다. 
예를들면 이미지 데이터를 In-Memory에 저장하고 있을 때 사용할 수 있을 것 같다. 

모바일에서 빠르게 이미지를 그리기 위해서 In-Memory에 저장해 두는 것이 속도적인 면에서 훨씬 유리하다. 하지만 이미지 데이터는 다른 데이터 타입에 비해 상대적으로 큰 데이터이다. 그런데 이런 데이터를 단순히 빠르기 로드하기 위해서 모든 이미지 데이터를 In-Memory에 저장하는 것은 불필요할 것이다. 

그래것 KingFihser 라이브러리 내부도 NSCache를 이용하여 구현되어 있는 것을 확인할 수 있다. 

[KingFisher](https://github.com/onevcat/Kingfisher)

```swift
public enum MemoryStorage {
  public class Backend<T: CacheCostCalculable> {  
      let storage = NSCache<NSString, StorageObject<T>>()
      var keys = Set<String>()

      private var cleanTimer: Timer? = nil
      private let lock = NSLock()

      ...
  }

  public func store(
            value: T,
            forKey key: String,
            expiration: StorageExpiration? = nil)
        {

          ...
        }

  public func value(forKey key: String, extendingExpiration: ExpirationExtending = .cacheTime) -> T? { ... }

  public func remove(forKey key: String) { ... }

  public func removeAll() { ... }

  ...
}
```

<Br>


### Thread Safe

NSCahce는 `Thread Safe`한 반변 Dictionary는 `Non Thread Safe` 하다고 한다. 
Dictionary를 사용하면서 Thread Safe 하게 사용하려면 Wrapper Dictionary를 만들어야 할 것 같다. 

```swift
class ThreadSafeDictionary<V: Hashable,T>: Collection {

    private var dictionary: [V: T]
    private let concurrentQueue = DispatchQueue(label: "customDictionary",
                                                attributes: .concurrent)

    init(dict: [V: T] = [V:T]()) {
        self.dictionary = dict
    }

    subscript(key: V) -> T? {
        set(newValue) {
            self.concurrentQueue.async(flags: .barrier) {[weak self] in
                self?.dictionary[key] = newValue
            }
        }
        get {
            self.concurrentQueue.sync {
                return self.dictionary[key]
            }
        }
    }

    subscript(index: Dictionary<V, T>.Index) -> Dictionary<V, T>.Element {
        self.concurrentQueue.sync {
            return self.dictionary[index]
        }
    }
    
    func removeValue(forKey key: V) {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeValue(forKey: key)
        }
    }

    func removeAll() {
        self.concurrentQueue.async(flags: .barrier) {[weak self] in
            self?.dictionary.removeAll()
        }
    }

}
```
위와 같이 Thread Safe 하게 만들어 사용할 수 있을 것 같다. 
해당 코드는 
[ThreadSafeDictionary](https://github.com/iThink32/Thread-Safe-Dictionary#:~:text=Dictionaries%20in%20Swift%20are%20not,concurrent%20queue%20with%20a%20barrier.)
를 참조하여 작성되었다. 

## Conclusion

필자의 요구사항을 위주로 NSCache와 Dictionary를 비교해보았다. 
결론은 제목에서 말했듯이 NSCache가 아닌 Dictionary를 쓰는 것이 적절하다고 판단되다. 
그 이유는 위에서 충분히 설명되었다고 생각한다~

<Br>

## Reference

[How to use custom type as a key for NSCache](https://medium.com/anysuggestion/how-to-use-custom-type-as-a-key-for-nscache-9bdbee02a8f1)

[ThreadSafeDictionary](https://github.com/iThink32/Thread-Safe-Dictionary#:~:text=Dictionaries%20in%20Swift%20are%20not,concurrent%20queue%20with%20a%20barrier.)

[KingFisher](https://github.com/onevcat/Kingfisher)

[NSCache](https://caution-dev.github.io/ios/2019/04/07/NSCache.html)