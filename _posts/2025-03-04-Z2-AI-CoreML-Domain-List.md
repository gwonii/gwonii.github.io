---
layout: article
title: '[AI 실험실] CoreML 도메인 기능 리스트'
key: 202503041542
tags:
- iOS
- Swift
- AI
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

CoreML 을 통해 기능을 구현하다보니 생각보다 CoreML 에서 제공하는 기능이 많은 것 같아서 정리해보고자 한다. 

<!--more-->

# 1. 목표
- Apple CoreML 에서 제공하는 도메인을 확인하고 도메인별 기능을 알아본다.

# 2. 이유
- CoreML 에서 Speech 도메인을 사용하였는데, 이외의 기능들도 많은 것 같아 혹시나 도움이 될까 싶어 조사해보려고 한다. 

# 3. 실행
- CoreML 의 도메인에는 크게 Speech, Vision, Natural Language, Sound Analysis 가 있다. 
- 해당 포스트에서는 Speech와 Vision에 대해 알아보자.

## 1. Speech
1. 음성-텍스트 변환(Speech-to-Text, STT)
사용자의 음성을 텍스트로 변환할 수 있어.

Apple의 Speech Framework와 함께 사용하면 실시간 변환도 가능.

예제: 음성 메모를 텍스트로 자동 변환

2. 텍스트-음성 변환(Text-to-Speech, TTS)
입력된 텍스트를 자연스러운 음성으로 변환할 수 있어.

Siri 음성을 활용하거나 맞춤형 TTS 모델을 사용할 수도 있어.

예제: 전자책을 음성으로 읽어주는 기능

3. 음성 명령 인식(Voice Command Recognition)
특정 음성 명령을 학습하여 사용자의 명령을 이해하고 실행할 수 있어.

예제: “음악 재생” 같은 특정 명령을 인식하여 동작 수행

4. 감정 분석(Speech Sentiment Analysis)
음성 데이터를 분석하여 감정을 판단할 수 있어(기쁨, 분노, 슬픔 등).

예제: 고객센터 상담 중 감정 분석하여 서비스 개선

5. 화자 인식(Speaker Recognition)
여러 사람의 음성을 분석하여 누구의 목소리인지 구별할 수 있어.

예제: 가족 구성원의 목소리를 구별하여 맞춤형 서비스 제공

6. 음성 요약(Speech Summarization)
긴 음성 데이터를 분석하여 핵심 내용만 요약할 수 있어.

예제: 강의 녹음을 요약하여 주요 내용만 텍스트로 제공

7. 키워드 감지(Keyword Spotting)
특정 키워드를 감지하여 즉시 반응할 수 있어.

예제: “헤이, Siri” 같은 특정 단어 감지 기능

8. 음성 필터링 및 잡음 제거(Speech Enhancement & Noise Reduction)
음성에서 배경 소음을 제거하여 더 깨끗한 음성을 추출할 수 있어.

예제: 영상 통화 중 잡음을 제거하여 더 선명한 음성 제공

9. 음성 번역(Speech Translation)
음성을 받아서 실시간으로 다른 언어로 번역할 수 있어.

예제: 여행 앱에서 실시간 음성 번역 제공

10. 음성 데이터 분석 및 태깅(Speech Data Analytics & Tagging)
음성을 분석하여 발음, 말의 속도, 강세 등을 평가할 수 있어.

예제: 언어 학습 앱에서 발음 교정 기능 제공

## 2. Vision

Services
1. 이미지 및 비디오에서 객체 감지(Object Detection)
이미지 또는 실시간 비디오에서 특정 객체(예: 사람, 자동차, 강아지 등)를 감지할 수 있어.

CoreML 모델(YOLO, SSD 등)을 Vision과 함께 사용하여 원하는 객체를 탐지 가능.

예제: 사진에서 특정 물체가 있는지 여부를 확인하는 기능

2. 이미지 분류(Image Classification)
CoreML에 학습된 모델(예: MobileNet, ResNet 등)을 Vision과 결합하여 이미지가 어떤 카테고리에 속하는지 예측 가능.

예제: 사진 속 동물이 강아지인지, 고양이인지 분류

3. 얼굴 감지(Face Detection) 및 얼굴 특징 추적(Face Landmarks)
Vision을 사용하여 이미지 또는 비디오에서 얼굴을 감지할 수 있어.

얼굴의 눈, 코, 입 등의 특징점(landmarks)도 추출 가능.

예제: 카메라 필터 앱에서 얼굴 인식 후 효과 적용

4. 텍스트 인식(Text Recognition, OCR)
Vision과 VNRecognizeTextRequest를 사용하면 OCR(광학 문자 인식) 기능을 구현할 수 있어.

한글, 영어 등 여러 언어 지원 가능.

예제: 명함을 스캔하여 연락처 자동 저장

5. 이미지 내 바운딩 박스(Rectangle Detection) 및 문서 스캔
문서나 카드 같은 직사각형 형태를 감지하여 자동으로 보정할 수 있어.

예제: 문서 스캔 앱에서 자동으로 문서 영역 감지 및 저장

6. 바코드 및 QR 코드 인식(Barcode & QR Code Detection)
QR 코드 및 다양한 바코드 형식을 인식할 수 있어.

예제: 결제 앱에서 QR 코드 스캔 기능 구현

7. 스타일 전이(Style Transfer)
CoreML 모델을 활용하여 이미지나 비디오에 특정 예술적 스타일(예: 반 고흐 스타일)을 적용할 수 있어.

예제: 사진을 그림처럼 변환하는 필터 앱

8. 손 제스처 인식(Hand Pose Detection)
Vision에서 손의 위치와 손가락의 각도 등을 분석할 수 있어.

예제: 손가락으로 숫자를 표시하면 자동으로 인식하는 기능

9. 사람 포즈 추적(Human Pose Estimation)
Vision을 이용해 사람의 자세(예: 팔, 다리 위치)를 감지할 수 있어.

예제: 피트니스 앱에서 운동 자세 분석

10. 이미지 유사도 비교(Image Similarity & Matching)
Vision을 활용하면 두 이미지가 비슷한지 비교할 수 있어.

예제: 사진 정리 앱에서 중복 사진 자동 정리

## 2. 

# 4. 결과
