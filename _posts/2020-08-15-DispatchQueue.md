---
layout: article
title: DispatchQueue 알아보기
tags:
- Swift
- iOS
- GCD
- Thread
- Sync&Async
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

자주 보지만, 잘 알지 못했던 Dispatch Queue에 대해 알아보자...

<!--more-->

# DispatchQueue



## 개요

### 1. GCD

DispatchQueue를 알아보기 전에 **GCD**의 개념을 먼저 알아보자. 

#### GCD ( Grand Central DispatchQueue )

GCD는 **Concurrency**와 **Thread**를 관리하는 방법중에 하나이다. 

GCD이전에는 OperationQueue를 이용해서 비동기 처리를 해왔다. 하지만 모바일 특성에 맞게 프로세스의 효율을 높히기 위하영 애플은 새로운 개념을 도입한 것이다. 



### 2. DispatchQueue

- **DispatchQueue**는 앱에서 **Task**를 비동기적으로 처리하기 쉽게 만들어주는 강력한 도구이다. 
- **DispatchQueue**를 이용하여 모든 쓰레드에서 작동하는 task들을 관리할 수 있다. 
- 사용하기 쉽고, 쓰레드를 직접 이용하는 것보다 효율적이다. 



#### 구조 

dispatchQueue는 말 그대로 Queue이다. 그렇기 때문에 기본적으로 **FIFO**의 구조로 작동한다. 



#### 종류 

**DispatchQueue**는 크게 세 가지로 구분해볼 수 있다. **`Serial Queue`**, **`Concurrent Queue`**, **`Main Dispatch Queue`**



##### 1)  Serial Queue

Serial Queue는 **(Private Dispatch Queue**라고 알려져 있으며, 큐에 추가된 순서대로 하나씩 Task를 작업합니다.

각각의 Queue는 모든 Queue들과 연관지어 동시에 작동한다. 

예를들어 4개의 **Serial Queue**를 만들어 Task를 작동시켰을 때, 각각의 Queue는 하나의 Task들을 작업한다. 하지만 각각의 Queue는 독립적으로 동시에 작동된다. 



##### 2) Concurrent Queue

Concurrent Queue는 ( **Global Dispatch Queue** ) 라고 불리고 있다. 

Concurrent Queue는 Queue에 들어온 순서대로 Task를 진행한다. 하지만 한 번에 한 개의 Task를 작동시키는 것이 아니라, 여러 개의 Task를 동시다발적으로 실행시킨다.



##### 3) Main Dispatch Queue 

MainDispatch Queue는 앱의 main thread에서 task를 작업하도록 한다. 

전역적으로 사용이 가능하게 만들어진 **Serial Queue**라고 생각할 수 있다. 





#### 실험 구현 

위 Dispatch Queue에서 **Serial Queue** ( sync, async )를 진행하고, 

**Concurrent Queue** ( sync, async )를 진행해보려고 한다. 



**Serial Queue** `sync`

```swift
let DQa: DispatchQueue = .init(label: "DQa")
let DQb: DispatchQueue = .init(label: "DQb")

DQa.sync {
    for item in 1...3 {
        print("DQa: \(item)")
        sleep(1)
    }
}

DQb.sync {
    for item in 1...3 {
        print("DQb: \(item)")
        sleep(1)
    }
}
```

**결과**

```swift
/*
 DQa: 1
 DQa: 2
 DQa: 3
 DQb: 1
 DQb: 2
 DQb: 3
 */
```



**예상했던 결과**

> 처음에는 **Serial Queue**가 하나의 큐는 순차적으로 task를 진행하고, 각각의 큐는 독립적으로 task를 처리한다는 얘기를 듣고 
>
> 마치 **async** 한 것 처럼 작동할 줄 알았다. 하지만 그렇지 않았다… 
>
> **그렇다면, 각각의 Queue는 독립적으로 task를 처리한다.** 는 무슨 말인걸까?



**예상**

위의 코드를 생각해보면, 이렇게 구현이 되어있지 않을까 생각된다. 

```swift
DispatchQueue.global().async {
	DQa.sync {
    	for item in 1...3 {
        	print("DQa: \(item)")
        	sleep(1)
    	}
	}
	
	DQb.sync {
   	 	for item in 1...3 {
     	   print("DQb: \(item)")
    	   sleep(1)
  	  	}
	}
}
```



> 이렇게 작동하고 있기 때문에 하나의 **Thread**는 두 `DQa`와 `DQb`를 순차적으로 실행했던 것이 아닐까? 





**Serial Queue** `async`

```swift
DQa.async {
        for item in 1...3 {
        print("DQa: \(item)")
        sleep(1)
    }
}

DQb.async {
        for item in 1...3 {
        print("DQb: \(item)")
        sleep(1)
    }
}
```



**결과**

```swift
/*
 DQa: 1
 DQb: 1
 DQa: 2
 DQb: 2
 DQa: 3
 DQb: 3
 */
```



> 예상한대로 `async`하게 잘 작동한다.. 



**Concurrent Queue** `sync`

```swift
DispatchQueue.global().sync {
    for item in 1...3 {
        print("DQa: \(item)")
        sleep(1)
    }
}

print("middle: 1")

DispatchQueue.global().sync {
    for item in 1...3 {
        print("DQb: \(item)")
        sleep(1)
    }
}

print("middle: 2")
```



**결과**

```swift
/*
 DQa: 1
 DQa: 2
 DQa: 3
 middle: 1
 DQb: 1
 DQb: 2
 DQb: 3
 middle: 2
 */
```



> 여기서 중간에 middle을 추가한 이유는 **Concurrent Queue**는 순서를 보장하고 있지 않기 때문이다. 
>
> 하지만 위 코드의 결과는 원하는 순서대로 출력이 되었다. 
>
> 그것은 각각의 Queue가 **sync**로 작동했기 때문이다. 



**Concurrent Queue** `async`

```swift
DispatchQueue.global().async {
    for item in 1...3 {
        print("DQa: \(item)")
        sleep(1)
    }
}

print("middle: 1")

DispatchQueue.global().async {
    for item in 1...3 {
        print("DQb: \(item)")
        sleep(1)
    }
}

print("middle: 2")
```



**결과**

```swift
/*
 middle: 1
 middle: 2
 DQa: 1
 DQb: 1
 DQb: 2
 DQa: 2
 DQb: 3
 DQa: 3
 */
```



> 위 코드는 **Concurrent Queue**를 **async**하게 동작시켰기 때문에 순서를 보장할 수 없다. 
>
> 그렇기에 중간의 middle이 먼저 출력되는 모습을 볼 수 있다.  



##### 다른 시각의 도전

만약에 아까 **Serial Queue**를 sync 하게 돌릴 때 기대했던 것처럼 출력되려면 어떻게 해야 할까? 

```swift
DispatchQueue.global().async {
	DQa.sync {
    	for item in 1...3 {
        	print("DQa: \(item)")
        	sleep(1)
    	}
	}
	
	DQb.sync {
   	 	for item in 1...3 {
     	   print("DQb: \(item)")
    	   sleep(1)
  	  	}
	}
}
```



**Serial Queue** sync가 동작되는 과정에 대해서 예상을 해보았다. 그러면 이것을 **Concurrent Queue**를 **async**하게 독립적으로 작동시키면 되지 않을까? 



```swift
DispatchQueue.global().async {
	DQa.sync {
    	for item in 1...3 {
        	print("DQa: \(item)")
        	sleep(1)
    	}
	}
}

print("middle: 1")

DispatchQueue.global().async {
	DQb.sync {
    	for item in 1...3 {
        	print("DQb: \(item)")
        	sleep(1)
    	}
	}
}

print("middle: 2")
```



> 이렇게 **Concurrent Queue**로 한 번 감싸주면 원하는대로 `DQa`와 `DQb`가 비동기적으로 작동한다. 

**결과**

```swift
/*
 middle: 1
 middle: 2
 DQa: 1
 DQb: 1
 DQb: 2
 DQa: 2
 DQb: 3
 DQa: 3
 */
```



> **Concurrent Queue**를 async하게 했으므로… 위 결과가 나올 듯하다.. 



그런데…. 

```swift
DispatchQueue.global().sync {
	DQa.sync {
    	for item in 1...3 {
        	print("DQa: \(item)")
        	sleep(1)
    	}
	}
}

print("middle: 1")

DispatchQueue.global().sync {
	DQb.sync {
    	for item in 1...3 {
        	print("DQb: \(item)")
        	sleep(1)
    	}
	}
}

print("middle: 2")
```



**결과**

```swift
/*
 middle: 1
 middle: 2
 DQa: 1
 DQb: 1
 DQb: 2
 DQa: 2
 DQb: 3
 DQa: 3
 */
```



> 오잉? **DQa**가 먼저 출력되고 **middle**이 출력될 줄 알았는데 그렇지 않았다… 
>
> 역시 **Concurrent Queue**이므로 DispatchQueue의 결과가 나오기 전에 middle이 먼저 출력된 것 같다. 



그렇다면… 

```swift
DQAlpha.sync {
    DQa.async {
        for item in 1...3 {
            print("DQa: \(item)")
            sleep(1)
        }
    }
}

print("middle: 1")

DQBeta.sync {
    DQb.async {
        for item in 1...3 {
            print("DQb: \(item)")
            sleep(1)
        }
    }
}
```

**결과**

```swift
/*
 middle: 1
 middle: 2
 DQa: 1
 DQb: 1
 DQa: 2
 DQb: 2
 DQa: 3
 DQb: 3
 */
```



> 이번에는 **Concurrent Queue**로 감싸주는 것이 아니라, **Serial Queue**를 **sync**하도록 감싸주었다. 
>
> … 그런데 비동기적으로 처리가 된 것이 아닌가…. 
>
> 아하… 어렵고도 어렵구나… 





