---
layout: article
title: Terminal 을 통해 UIWindow 계층 구조 알아보기!
key: 2023092301
tags:
- iOS
- Swift
- Debug
- Xcode
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

"Xcode Debug View Hierarchy"를 사용하지 않고 UIWIndow 의 계층구조를 좀 더 쉽게 볼 수 있는 방법에 대해 알아보고자 한다.

<!--more-->

# Motivation

항상 UI 디버깅을 할 때에는 **`Xcode Debug View Hierarchy`** 을 사용했었는데 시간도 오래 걸리고 UI로 하나하나 찾아가면서 보는게 쉽지 않았다. 

그래서 terminal 에서 lldb 를 통해 Controller hierarchy 를 출력해주는 도구가 없을까 싶었다…

# Contents

## PrintHierarchy with UIViewController

```lldb
expr -l objc++ -O -- [[[UIWindow keyWindow] rootViewController] _printHierarchy]
```

(lldb) 에서 위의 명렁어로 hierarchy 를 쉽게 볼 수 있었다. 

그러면 결과값으로 

```lldb
<UINavigationController 0x12183a000>, 
	state: appeared, 
  view: <UILayoutContainerView: 0x12170fc20>
   | <Store.StoreViewController 0x122604ea0>, 
			state: disappeared, 
			view: <UIView: 0x12170dca0> not in the window
   | <Store.TrackDetailViewController 0x121725970>, 
			state: appeared, 
			view: <UIView: 0x1217462d0>
```

위와 같은 형태로 예쁘게 출력된다. 

위에 출력된 결과물에서 파악할 수 있는 정보는 

- UINavigationController 를 포함한 ViewController 의 계층 관계
- 각 Controller 의 노출여부 ( state: appeared / state: disappeared )

그래서 실제로 어떤 화면이 노출되어있고 노출되어 있지 않은지 알 수 있다. 

## PrintHierarchy with UIView
UIView 의 hierarchy 를 보려고 할 때는
```lldb
(lldb) expr -l objc -O -- [[[UIApplication sharedApplication] keyWindow] recursiveDescription]
```
를 통해 확인할 수 있다. 그런데 직접 사용해서 보니 UIWindow 에 있는 모든 UIView 계층을 보여주다보니 양이 엄청나다...

## lldb가 아닌 다른 방법 활용하기

위의 terminal 에서 출력되는 것을 보고 다른 방법으로 hierarchy 를 볼 방법은 없을까 하는 와중에

화면전환시 마다 terminal 에 Controller Hierarchy 를 출력시키면 어떨까 싶은 아이디어가 떠올랐다. 

```swift
if let keyWindow = UIApplication.shared.keyWindow {
    if let rootViewController = keyWindow.rootViewController {
        rootViewController.printHierarchy()
    }
}
```

화면 전환하는 공통 클래스에 위와 같은 코드를 심어놓으면 화면전환할 때마다 Controller의 Hierarchy 를 알 수 있다!

또는 특정 UIViewController 나 UINavigationController 의 계층이 알고 싶다면, 

```swift
extension UIViewController {
    func printHierarchy(indentation: String = "") {
        print(indentation + String(describing: self))
        
        if let childViewControllers = self.children as? [UIViewController] {
            for childViewController in childViewControllers {
                childViewController.printHierarchy(indentation: indentation + "  ")
            }
        }
    }
}
```
와 같은 방식을 사용해볼 수도 있을 것 같다! 

# Conclusion

화면전환 또는 복잡한 화면에서의 계층을 쉽게 볼 수 있다니… 좋은 정보다.