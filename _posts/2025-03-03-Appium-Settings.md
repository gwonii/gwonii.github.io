---
layout: article
title: "[Appium] Appium 환경설정 하기 (1편)" 
tags:
- Apple Intelligence
- AI
- iOS
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

Appium 을 사용하여 통합 테스트 자동화를 구축해보려고 한다. 1탄 환경설정하기!

<!--more-->

# 1. 목표
1. Appium 이 무엇인지 알아본다.
2. Appium 을 사용하기 위하여 사전에 무엇을 설정해야 하는지 확인한다. 

# 2. 이유
- 개발자들은 신규 Feature 를 개발하는 경우, 본인이 작업한 코드에 대해서 테스트를 한다. 
- 보통 Feature 개발과 함께 Unit Test 를 작성하지만, 자신이 작성한 코드에 불안감은 완전히 해소되지 않는다.
- 개발한 Feature 에 대해서 통합 테스트를 자동으로 수행시킨다면 개발자의 불안감을 해소시킬 수 있지 않을까? 하는 의문에서 Appium 작업을 시작하게 되었다. 

# 3. 실행

## Appium 이란?
Appium은 selenium 기반의 오픈 소스 모바일 애플리케이션 테스트 자동화 프레임워크로, iOS와 Android 앱을 자동으로 테스트할 수 있도록 도와주는 도구입니다.

## 특징
1. 크로스 플랫폼 지원
  - iOS, Android 네이티브 앱, 하이브리드 앱, 웹 앱 테스트 가능
  - 하나의 코드로 여러 플랫폼에서 테스트 가능

2. 다양한 언어 지원
  - Java, Python, JavaScript, Swift 등 다양한 프로그래밍 언어 지원

3. 실제 기기와 에뮬레이터 모두 지원

## Appium 과 Python 관련 라이브러리 버전 정보
- Appium 테스트 코드 작성시 python 을 사용하려고 한다. 

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-03-Appium-Settings-Image/appium_1.png?raw=true" alt="01" style="zoom: 80%;" />

## 개발 환경설정 관련 항목
- node 설치
- npm 설치
- appium 설치
- appium test driver 설치
- Appium-Python-Client 설치
- idb/adb 설치
- Appium Inspector 설치
- WebDriverAgent 설치 ( iOS 전용 )

> 상세한 내용이 보고 싶지 않으신 분들을 위하여 `installer.sh` 스크립트를 만들어 두었습니다. 
> 최하단을 확인해주세요~

### 1. node 설치
- `$ brew install node`

### 2. npm 설치
- `$ install npm`

### 3. appium 설치
- `$ sudo npm install -g appium`

### 4. 프로젝트에 appium 로컬 설정
- .env > export PATH={appium project}/node_modules/.bin:$PATH 항목 추가
- `$ source .env`

### 5. (iOS/Android) appium test driver 설치
- (iOS) `$ appium driver install xcuitest`
- (Android) `$ appium driver install uiautomator2`
- appium 을 통해 테스트를 위한 도구가 설치되어 있는지 확인 가능
  ```shell
  % appium driver list --installed
  ✔ Listing installed drivers
  - xcuitest@7.32.0 [installed (npm)]
  - uiautomator2@3.9.1 [installed (npm)]
  ```

### 6. Appium-Python-Client 설치
- python 스크립트를 통해 Appium 수행 도구
- `$ pip install Appium-Python-Client`

### 7. (iOS) idb 설치
- iOS UITest 를 위한 디바이스 설정 도구
- `$ pip3 install fb-idb`
  ```shell
  No such file or directory: '/usr/local/bin/idb_companion’ 오류 발생시
  idb_companion 가 설치되지 않은 것으로 확인
  idb_companion 설치
  idb-companion 안 fb-idb 와 달리 독립적인 binary 파일 이므로 따로 설치해야함
  ```
  - `$ brew tap facebook/fb`
  - `$ brew install idb-companion`
  - `$ idb_companion --version ( 정상 설치 체크 )`
    ```shell
    % idb list-targets 
    iPad (10th generation) | 48709A02-58B4-41F9-B1E0-8CB07773A4C4 | Shutdown | simulator | iOS 17.5 | x86_64 | No Companion Connected
    iPad Air 11-inch (M2) | 18745CCA-13CD-4D0E-B3BD-886EF78B0A82 | Shutdown | simulator | iOS 17.4 | x86_64 | No Companion Connected
    ...
    ```

### 8. (Android) adb 설치 및 확인
- Android Studio 와 Emulator 가설치되어 있다면, 보통 바로 사용가능함.
- 만약 adb 명령어가 동작하지 않는다면 환경변수 추가할 것
  ```shell
  export ANDROID_HOME=/.../Android/sdk
  export ANDROID_SDK_ROOT=/.../Android/sdk
  export PATH=$ANDROID_HOME/platform-tools:$PATH
  export PATH=$ANDROID_HOME/tools:$PATH
  ```

### 9. appium-inspector 설치
- appium-inspector 는 UI Client 로 직접 앱의 구성요소를 하나하나 확인하며 테스트를 해볼 수 있습니다.
- [Appium Inspector - git](https://github.com/appium/appium-inspector/releases)
- 해당 프로젝트에서 나의 환경에 맞는 파일 설치

### 10. (iOS) WebDriverAgent 설치 및 세팅
- iOS 전용 어플 모니터링 도구
- xcode project 이며, 테스트 할 디바이스에 설치 및 실행 시켜야 한다.
- [WebDriverAgent 관련 자료](https://blog.naver.com/wooy0ng/223473944904)


# 4. 결과
위의 절차를 모두 수행했다면, Appium 을 사용할 수 있는 준비를 완료하였습니다. 
<br>
이후에는 Python 으로 테스트 코드를 작성하여 통합 테스트 자동화를 구축할 수 있습니다. 

## 실행 방법
1. appium 실행
  - `$ appium`
2. WebDriverAgent 실행
  - 테스트 할 디바이스에 실행
3. python 스크립트 or Appium Inspector 실행
  - python 스크립트
    ```python
    from appium import webdriver
    from appium.options.ios import XCUITestOptions

    team_id = "team_id"

    options = {
      "platformName": "iOS",
      'platformVersion': '15.7.3',       # 디바이스의 iOS 버전 조정
      "automationName": "XCUITest",
      "deviceName": "iPhone",  # 사용하는 디바이스 이름에 맞춰 조정
      "udid": "",    # 디바이스의 UDID 기입
      "xcodeOrgId": f"{team_id}"    # 애플 개발자 Team ID 기입
    }

    server_url = "http://127.0.0.1:4723"

    driver = webdriver.Remote(server_url, options=XCUITestOptions().load_capabilities(options))
    print(f"deviceName: {driver.caps['deviceName']}")
    ```
  - Appium Inspector
    - Inspector 설정 값 입력
    <img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-03-Appium-Settings-Image/appium_2.png?raw=true" alt="01" style="zoom: 80%;" />
    - Session Start
    <img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-03-Appium-Settings-Image/appium_3.png?raw=true" alt="01" style="zoom: 80%;" />

# 5. 맺음말
- [installer.sh](...)