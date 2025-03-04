---
layout: article
title: "[Problem Solving] UI 개발 생산성 향상 작업" 
tags:
- iOS
- UI
- UIKit
- Problem Solving
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

UI 개발을 하면서 불필요하게 사용되는 시간을 아끼고 개발 생산성을 향상시키고자 한 노력을 작성하고자 합니다. 

<!--more-->

# 1. 목적
- 신규 프로젝트 진행에 있어서 UI 개발 시간을 절약할 수 있는 방법을 찾고자 한다.

# 2. 이유
신규 프로젝트를 진행하게 되었다. 
- UI 구현을 위하여 `UIKit` 과 `SnapKit` 을 이용하기로 하였다. 
- 프로젝트 규모가 커질수록 UI 개발 및 UI 확인을 위한 빌드속도가 급속도로 증가하였다.
- Custom UI 를 체계적으로 관리하고 확인할 수 있는 수단이 필요하였다.

<br>

정해진 시간은 타이트했고 위의 스펙을 가지고 UI 를 구현해야 했다. 그래서 iOS 개발을 하는데 있어서 가장 시간이 많이 드는 부분을 고민하게 되었고, UI 작업에 드는 시간 비용이 크다는 것을 확인하였다. 그래서 UI 개발에 비용을 줄일 방법에 대한 논의를 하게되었다. 

# 3. 실행

## 원인

### 1. UI 개발 후 결과를 확인하는 시간이 오래 걸린다.
- Storyboard 또는 xib 를 사용하지 않는 경우, 코드로 UI를 작성한 후 앱을 실행시켜 결과를 확인해야 한다.
- 작은 프로젝트에서는 문제가 되지 않지만 큰 프로젝트의 경우 증분 빌드를 하여도 불필요한 시간을 쓰게 되었다. 

## 해결

### 1. "Hot Reload" 도입
- UIKit 에서도 Injectlll 를 사용하여 "Hot Reload" 를 지원할 수 있다는 것을 확인했다.
- Injectlll 을 이용하여 Linker Flag 를 설정하고 Inject.ViewControllerHost 를 포함하는 BaseViewController 를 구성하여 xcode에서 Hot Reload를 사용할 수 있게 되었습니다.

### 2. 공통 UI Comonents 작업
- 우선 피그마에서 공통적으로 사용되는 UI 를 선별하였다.
- 반복적으로 사용되는 UI 는 모듈을 따로 분리하여 공통 UI로 개발하였다.
- Feature 에서는 공통 UI 를 사용하여 이전보다 훨씬 빠르게 UI 를 구현할 수 있었다. 

### 3. UIKit Preview 적용
- UIKit 을 이용하여 코드로 UI를 작성하는 경우 코드만 보고 UI를 정확히 가늠하기 힘들다.
- UIKit 을 SwiftUI 로 wrapping 하여 Preview 에서 볼 수 있도록 작업하였다.

# 4. 결과
UI 개발 비용을 줄이기 위하여 여러 방법들을 조사해봤는데, 생각보다 다양한 방법으로 UI 작성 시간을 줄일 수 있었다.
만약 SwiftUI 를 사용하고 싶었지만, 최소 버전 이슈로 인하여 그렇지 못했다. 하지만 이후에도 SwiftUI 를 쓸 수 있다는 보장이 없기 때문에
위와 같이 UIKit 에서도 UI 개발 생산성을 올리기 위한 노력은 이후 프로젝트에서도 잘 활용될 수 있을 것 같다. 