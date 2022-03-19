---
layout: article
title: Why Use Tuist?
tags:
- iOS
- Swift
- Xcode
- Library
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

프로젝트 파일 관리의 어려움을 딛고 Tuist를 도입하려고 하는데...?

<!--more-->

# Why Use Tuist?

## 1. Tuist?

<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Tuist-Git.PNG" alt="01" style="zoom: 67%;" />

Tuist is a command line tool **(CLI)** that aims to facilitate the **generation**, **maintenance**, and **interaction** with Xcode projects.

**Xcode의 프로젝트 파일을 생성, 관리 하는 툴입니다.** 

💡 Command Line Interface ( CLI )

**명령 줄 인터페이스**
([영어](https://ko.wikipedia.org/wiki/%EC%98%81%EC%96%B4): Command-line interface, **CLI**, **커맨드 라인 인터페이스**) 또는 **명령어 인터페이스**는 [가상 터미널](https://ko.wikipedia.org/wiki/%EB%8B%A8%EB%A7%90_%EC%97%90%EB%AE%AC%EB%A0%88%EC%9D%B4%ED%84%B0) 또는 [터미널](https://ko.wikipedia.org/wiki/%ED%85%8D%EC%8A%A4%ED%8A%B8_%ED%84%B0%EB%AF%B8%EB%84%90)을 통해 사용자와 컴퓨터가 상호 작용하는 방식을 뜻한다.

[https://ko.wikipedia.org/wiki/명령_줄_인터페이스](https://ko.wikipedia.org/wiki/%EB%AA%85%EB%A0%B9_%EC%A4%84_%EC%9D%B8%ED%84%B0%ED%8E%98%EC%9D%B4%EC%8A%A4)

<Br>

## 2. Xcode Project File?

Xcode가 무엇이기에 Xcode만 관리하는 라이브러리가 따로 있는 것일까? 


**Xcode.xcodeproj**

**프로젝트 파일은 `파일`, `리소스`, `모듈`, `앱 설정`, `계정정보`, `빌드 정보` 등 iOS와 관련된 모든 정보들을 담고 있는 파일이다.**

<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Build-Phases.PNG" alt="01" style="zoom: 67%;" />

_Build Phases_

<Br>
<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Build-Setting.PNG" alt="01" style="zoom: 67%;" />

_Build Setting_

<Br>
<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Custom-Property.PNG" alt="01" style="zoom: 67%;" />

_Custom Target Property_

<Br>
<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Signing.PNG" alt="01" style="zoom: 67%;" />

_Sigining_

<Br>

## 3. Difficulties of managing xcode project

### 프로젝트 파일의 구성요소 
**`Xcode.xcodeproj`**  는 실제로 파일이 아니라 폴더이다.
폴더 안에는 크게 3개로 나뉘어져 있다. 
`project.pbxproj`, `xcuserdata`, `xcshareddata`
 
**1. project.pbxproj**

project.pbxproj 는 실질적인 설정 파일이다. 
파일을 열어보면 프로젝트 내부의 파일들과 파일 유형에 따른 reference 정보들을 저장하고 있다. 

**2. xcuserdata**

xcuserdata 에는 각 모듈별 BreakPoint, Layout, 스냅샷 정보들이 담겨 있다. 
( 정확히 어떤 데이터인지 파일을 봐도 잘 모르겠다.... )

**3. xcshareddata**

xcshareddata 모듈별 빌드 설정 정보들이 담겨있다.
xcshareddata > xcschemes 에 들어가게 되면 각 모듈별 정보들을 볼 수 있다.  

### 프로젝트 파일 관리의 어려움
위의 프로젝트 파일 구성요소를 보면 프로젝트 정보와 설정 정보들이 담겨 있다.
이 중에서도 우리에게 시련을 주는 것은 project.pbxproj 이다. 

> 가령 여러명이 하나의 프로젝트에서 같이 작업을 하고 있다고 해보자. 
> 일반적으로 git에 프로젝트 파일 ( project.pbxproj ) 파일도 커잇을 하게 되는데 
> ( 여기에는 파일 정보들과 reference 정보들이 담겨있다고 하였다. )
> 이 파일의 reference 정보들은 각 작업자들마다 다르게 가지는 경우가 발생하게 된다. 
> 이러한 경우에 merge를 하는 과정에 conflict을 겪에 되고 보기도 힘든 광경을 보게 된다. 

<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Project-Conflict.PNG" alt="01" style="zoom: 67%;" />

위와 같이 대규모 conflict이 발생되는 경우 해결하기가 여간 쉽지 않다. 개발자들은 자기만의 해결방법이 있겠지만 
필자의 경우 타겟의 파일 전체의 reference 정보를 다시 제거하고 다시 설정하도록 했었다. 
( 굉장히 귀찮고 해선 안되는 작업이라고 생각한다. 왜냐하면 reference 정보 전체를 다시 생성했다는 것은 project.pbxproj 파일 전체가 바뀐거나 다름이 없기 때문이다. )

이렇게 시도 때도 없이 발생되는 conflict으로 인하여 Tuist 라는 프로젝트 관리 라이브러리를 접하게 되었다. 

<Br>

## 4. Why Use Tuist 
그렇다면 여러 방면에서 Tuist를 사용하면 얻을 수 있는 이점에 대해 공유해보려고 한다. 

### 1. 코드 충돌을 방지할 수 있기 때문에
사실 Tuist를 사용하는 가장 큰 이유이다. 
큰 서비스를 작업하게 되는 경우 보통 혼자서 작업하는 일은 드물다. 여러 개발자들과의 협업속에서 누군가 계속 프로젝트 파일에 conflict이 발생되도록 만든다면 같은 협업자들도 항상 스트레스 일 것이다. 

프로젝트 파일 conflict 해결이 어려운 이유를 좀 더 상세히 보면
하나의 파일을 생성하고 reference 정보가 생성되는 것이 우리가 생각하는 것 처럼 간단하지 않기 때문이다. 
보통 파일을 하나 생성하게 되면
<img src="../img/2022-03-19-Tuist-Part1-Why-Use-Tuist-Image/Project-Files.PNG" alt="01" style="zoom: 67%;" />
위와 같이 여러 section에 변동사항이 발생하게 된다. 
그런데 여러 개의 파일들이 충돌하게 되는 경우 우리가 저 section들의 정보들을 하나하나 찾아가면서 해결할 수 있을까? 

<Br>

### 2. 설정 내용들을 재사용할 수 있기 때문에
앞서 프로젝트 파일에 담겨있는 설정 파일들을 봤었다.
보통 우리가 프로젝트 파일을 생성하고 코드를 짜는 경우 설정파일에 한해서는 기본 default 값들로 유지하고 개발 중 필요한 정보들만 변경하게 된다. 
하지만 Build Phases, Build Setting 항목들을 보면 굉장히 많은 정보들이 있다는 것을 쉽게 볼 수 있다. 
이런 정보들의 경우 한 번 변경하게 되면 다시 건드리지 않는 특성들을 가지고 있다. 

그래서 보통 새로운 프로젝트를 시작할 때 이전에 만들었던 프로젝트들의 설정 정보들을 보고 작성을 하거나 오류가 발생된 후에야 문제를 파악하고 설정 값들을 변경한다. 

하지만 Tuist를 사용하게 되면 프로젝트에서 자주 사용되는 설정 정보들을 쉽게 관리할 수 있다. 
이 부분은 나중에 Tuist 사용기에 조금 더 언급해보도록 해보자. 

<Br>

### 3. 의미있는 커밋을 만들 수 있기 때문에
예를 들어 
- fix: main view 컴포넌트 정보 수정
- feature: viewModel 기능 추가
- refactor: 유즈케이스 리팩토링 

위와 같은 작업을 수행하고 커밋을 하려고 한다고 해보자.
처음 머릿속에서 작업내역을 잘 정리하고 개발을 하는 개발자라면 각 커밋별로 처음부터 나눠서 잘 개발을 할 것이다. 
하지만 필자의 경우 작업을 하다보면 위의 3개의 커밋들을 한 번에 작업하고 추후 변동내역들을 다시 확인하면서 커밋을 분리하곤 한다. 

여기까지는 각자 취향 차이라고 어느 정도 용인해줄 수 있다. ( 개인적인 생각으로.... )
하지만 용인할 수 없는 한가지가 있다. 위의 변경내역에서 파일들은 커밋별로 나누기가 쉽지만 프로젝트파일은 그렇지 않다는 것이다. 
프로젝트 파일에서 위 커밋단위를 나누려면 여간 어려운일이 아니다... 감히 도전하고 싶지도 않은 작업이다.
이러한 경우에 프로젝트 파일의 변경사항은 세 커밋 중 한 커밋에 몰래 넣곤 했다. 
하지만 엄연히 따지면 프로젝트 파일의 변경내역은 커밋에 포함되지 말아야 할 정보들도 담겨 있다. 

이 문제 또한 Tuist를 사용한다면 쉽게 해결할 수 있다. Tuist는 프로젝트 파일을 remote에 올리지 않고 ignore 시키기 때문이다. *^^* 

<Br>

### 4. ...
이외에도 자잘한 이유들이 있지만 Tuist를 심도있게 사용하면서 나중에 추가적으로 정리를 해보려고 한다. 
왜냐하면 외외에 Tuist의 이점들은 스스로 굉장히 주관적이라고 느껴지기 때문이다. 추후 확실한 근거를 갖게 되면 더 작성해보도록 해보자.

# Review
오늘은 직접 Tuist를 직접 사용하는 방법이 아닌 "Tuist를 왜 사용해야 하는가" 에 집중에서 글을 작성하였다. 
회사에서도 아무 근거 없이 "Tuist 적용하게 해줘!!" 라고 밑도 끝도 없이 말할 수 없었기 때문에 위 포스트 내용을 정리하게 되었다. 
결과적으로 현재 신규 프로젝트에서는 Tuist를 사용하고 있다. 같이 일을 하는 동료분들도 나와 같은 어려움을 공감해주었다. 
아직은 미숙하게 사용하고 있지만 앞으로 점점 심도있게 사용하면서 후기를 남겨보려고 한다. 
( 그리고 "Tuist Part2 사용기" 최대한 빠른 시일내에 작성하려고 한다. )

<Br>

# 관련자료
1. [Tuist github](https://github.com/tuist/tuist)
2. [Xcode 프로젝트 파일](https://hcn1519.github.io/articles/2018-06/xcodeconfiguration)
