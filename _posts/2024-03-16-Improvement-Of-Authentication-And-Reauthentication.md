---
layout: article
title: Improvement work on app crash
tags:
- iOS
- Swift
- Crash
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---
인증 및 재인증 개선을 위한 작업

# Background
DaouOffice 앱에서 인증 및 재인증을 하는 과정에서 이슈 보고가 자주 들어왔고 확실히 뿌리를 해결하자는 요구사항이 들어왔다. 

# Cause Analysis
DaouOffice는 B2B 기반의 그룹웨어 서비스로 한 계정이 가지고 있는 설정값이 많다는 특징을 가지고 있었다. 여기서 생길 수 있는 수 많은 설정값의 경우의 수에 따라 예상치 못한 오류가 발생되고 있었다.

# Solution
수 많은 설정값에 따른 테스트 코드를 작성하고 개발자 차원에서 코드를 입증할 수 있도록 하였다. 

먼저 인증과정에서 요청하는 모든 API를 정리하고 response로 전달되는 프로퍼티들을 정리하였다. 요청하는 모든 API의 수는 9개였고 repsonse로 전달받는 모든 프로퍼티의 개수는 106개 였다. 

둘째로 프로퍼티 106개로 만들어질 수 있는 모든 경우의 수에 대한 테스트 코드를 작성하였다. 유의미한 케이스의 조합으로 만들어진 경우의 수는 약 500가지 정도였다. 

셋째로 위 500가지의 상황을 만들기 위하여 mock과 stub으로 구성된 Test Double 객체들을 구성하였다. 

넷째로 given, when, then 기반으로 mock과 stub을 이용하여 테스트 코드를 작성하였다. 

그리고 테스트 코드 작성과 함께 코드 커버리지 분석 도구를 구현하였다. 현재 작성된 테스트코드와 코드 커버리지를 수치화 시킨다면 더욱더 코드의 신뢰성을 높힐 수 있다고 판단하였다. 그래서 SwiftUI를 이용하여 macOS에서 이용가능한 코드 커버리지 분석 도구 툴을 따로 개발하였다.

# Achievement
월간 접수되었던 인증 이슈가 평균 12건에서 1건으로 줄어들었다. 또한 이미 작성된 인증 케이스를 통해 사용자의 정보만을 가지고 문제의 원인을 보다 빠르게 추적할 수 있었다.