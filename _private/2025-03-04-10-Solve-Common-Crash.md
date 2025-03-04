---
layout: article
title: '[Problem Solving] 주로 발생되는 Crash 정리'
tags:
- 'iOS'
- 'Swift'
- 'Crash'
- 'Problem Solving'
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

iOS 개발을 하면서 주로 발생되었던 Crash 항목들을 정리해보고자 한다. 

<!--more-->


# 1. 목표
이전 회사에서 지속적으로 앱 크래쉬 신고가 들어왔고, 이를 사전에 방지할 수 있는 방안이 필요했다.  
따라서 근본적인 문제를 분석하고, 코드 개선 및 제도화를 통해 최대한 앱 크래쉬를 제거하는 것을 목표로 하였다.

# 2. 이유
앱 크래쉬의 원인은 다양하며, 단순히 특정 이슈를 해결하는 것만으로는 근본적인 개선이 어렵다고 판단했다.  
전체 앱 크래쉬 이슈를 리스트화하여 반복적으로 발생하는 주요 원인을 파악하였고, 이를 해결하기 위한 체계적인 접근이 필요했다.  

주요 원인은 다음과 같았다.
1. Optional 강제 추출로 인한 nil 참조
2. Memory leak으로 인한 메모리 과부하
3. UI 로직이 background thread에서 동작되는 경우
4. Out of index 발생
5. 권한이 없는데 권한 관련 기능을 사용한 경우
6. Crash 추적 및 대응 체계 미비

# 3. 실행

## 1. Optional 강제 추출로 인한 nil 참조
- 모든 강제 추출 코드를 제거하고, nil case에 대한 예외처리를 추가하였다.
- nil이 발생하는 경우, 해당 데이터의 상태를 정의하고 적절한 예외처리 로직을 추가하였다.

## 2. Memory leak으로 인한 메모리 과부하
- 순환 참조를 방지하기 위해 클래스 내 프로퍼티 참조 시 `self` 키워드 사용을 최소화하도록 제안하였다.  
  - 특히 escaping closure 내부에서 `self`를 명시적으로 사용하도록 강제하여, 컴파일 시점에서 순환 참조 문제를 감지할 수 있도록 하였다.
- 화면별 메모리 사용량을 측정하고, PR 작성 시 메모리 디버깅 결과를 포함하도록 제도화하였다.

## 3. UI 로직이 background thread에서 동작되는 경우
- UI 프로퍼티를 `private` 접근제한자로 변경하여 외부에서 직접 변경하지 못하도록 설정하였다.
- 모든 View가 `handleOutput(_ output: Output)` 메소드를 구현하도록 구조를 통일하였다.
- `ViewModel(output) → ViewController(bind) → View - handleOutput()` 방식으로 역할을 분리하였으며,  
  ViewController에서 `handleOutput` 호출 시 `MainThread`에서 실행되도록 구성하였다.
- UI 갱신 로직을 특정 메소드에서만 수행하도록 통일하여, Thread 변경 시점을 명확히 보이도록 하였다.

## 4. Out of index 발생
- 배열의 index 접근 코드를 제거하고, `first`, `last` 등의 Array 인터페이스를 적극 활용하였다.
- 불가피하게 index 접근이 필요한 경우, Collection subscript를 확장하여 index 범위를 벗어날 경우 nil을 반환하도록 하였다.

## 5. 권한이 없는데 권한 관련 기능을 사용한 경우
- 위치 권한, 앨범 접근, 백그라운드 권한 등의 코드 변경 시, `권한 관련 처리` 라벨을 PR 코드 리뷰에서 반드시 확인하도록 제도화하였다.
- 해당 라벨이 포함된 PR은 팀원 전체가 신중하게 코드 리뷰를 진행하도록 유도하였다.
- 권한 관련 코드 변경 사항을 쉽게 트래킹하기 위해 `Tuist`를 도입하였다.

## 6. Crash 추적 및 대응 체계 구축
- Firebase Crashlytics 및 Xcode Organizer의 Crash Report 모니터링 담당자를 지정하였다.
- 주마다 담당자를 배정하여, 앱 크래쉬가 발생하면 신속히 대응할 수 있도록 체계를 마련하였다.

# 4. 결과
- 위의 과정들을 통해 코드 컨벤션을 정리하고, 크래쉬 예방을 위한 여러 작업을 제도화하였다.
- 그 결과, 앱 크래쉬율이 현저하게 감소하여, 최대 10%까지 발생했던 크래쉬율이 1% 미만으로 줄어드는 성과를 달성하였다.
- 지속적으로 크래쉬 원인을 리스트화하고 관리하며, 새로운 크래쉬 발생 시 신속한 대응이 가능하도록 개선하였다