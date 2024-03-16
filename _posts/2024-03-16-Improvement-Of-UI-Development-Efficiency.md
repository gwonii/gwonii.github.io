---
layout: article
title: Improvement of UI Development Efficiency
tags:
- iOS
- Swift
- UIKit
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---
UI 개발 효율성을 위한 작업

<!--more-->

# Overview
신규 프로젝트를 진행하게 되었는데 타이트한 일정이 주어졌다. 그래서 iOS 개발을 하는데 있어서 가장 시간이 많이 드는 부분을 고민하게 되었고, UI 작업에 드는  시간 비용이 크다는 것을 확인하였다. 그래서 UI 개발에 비용을 줄일 방법에 대한 논의를 하게되었다. 

# Cause Analysis
- UI 구현을 위하여 `UIKit` 과 `SnapKit` 을 이용하기로 하였다. 
- 프로젝트 규모가 커질수록 UI 개발 및 UI 확인을 위한 빌드속도가 급속도로 증가하였다.
- Custom UI 를 체계적으로 관리하고 확인할 수 있는 수단이 필요하였다.

# Solution
위 문제를 해결하기 위하여 “Hot Reload 도입” 과 “UI Component 공통화”  을 제안했다.

위의 문제의 원인은 분명했다. 원인은 코드를 작성하고 빌드를 하고 UI를 확인하는데 시간이 오래 걸린다는 것이었다. 그렇다면 빌드를 하지 않고 UI를 확인할 수 있으면 쉽게 문제가 해결된다고 생각했다.

그래서 문제를 해결하기 위해 빌드를 수행하지 않고 UI를 확인할 수 있는 방법들을 찾기 시작했다. 그러다 이전에 Flutter 프로젝트를 진행했었을 때의 경험이 생각이 났다. Flutter의 경우 기본적으로 Hot Reload를 지원하고 있었고 Xcode의 iOS Simulator 에서도 분명히 Hot Reload를 할 수 있다는 확신이 들었다. 

그러다 결국 Injectlll 라이브러리를 찾게 되었다. 사용하기 위해 간단히 Linker Flag 를 설정하고 Inject.ViewControllerHost 를 포함하는 BaseViewController 를 구성하여 xcode에서 Hot Reload를 구현할 수 있게 되었습니다.

그리고 두번째로 UI Component 공통화 작업을 진행했다. 공통적으로 사용될 수 있는 UI들을 먼저 CustomView로 작업했다. 그리고 Custom UI를 일괄적으로 확인할 수 있도록 CustomView들을 UIViewRepresentable을 채택하여 SwiftUI PreviewProvider를 활용하여 한 눈에 CustomView 들을 볼 수 있도록 구성하였다.

# Achievement
- Injectlll 를 이용하여 빌드를 하지 않고 UI를 확인할 수 있었기 때문에 불필요한 빌드 시간들을 줄일 수 있었다.
- UI Component Preview 를 통해 우선적으로 자주 사용되는 UI Component CustomView를 만들 수 있었고 추후 개발 시간 단축에 큰 도움이 되었다.