---
layout: article
title: '[TuistPlaygroud] Tuist cache 이용하기  (3탄/N)'
tags:
- Tuist
- Architecture
- 'Dependency Injection'
- iOS
- TuistPlayground
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

Tuist cache 를 이용하여 빌드 속도 개선해보기

<!--more-->

# 1. 목표
- `tuist cache` 에 대해 간단히 알아보기
- `tuist install`과 `tuist cache` 를 이용하여 빌드 속도 개선하기

# 2. 실행

## tuist cache 란?
- Tuist 에서 프로젝트를 빌드시에 빌드 속도를 개선시켜주고자 제공하는 기능이다.
- 개발시에 클린 빌드가 종종 일어나고 특정 모듈의 경우, 다시 빌드하지 않아도 되는 경우가 발생한다.
  가령 외부 의존성의 경우 클린 빌드를 하더라도 매번 새로 빌드할 필요가 없다. 이와 같이 이전의 빌드를
  그대로 사용해도 되는 경우에 `tuist cache` 를 이용하여 해결할 수 있다. 

### 사용 방법
1. `Package.swift` 에 외부 의존성이 있는 경우, 우선 `tuist install` 명령어를 수행한다. 
2. `tuist cache` 를 이용하여 전체 모듈의binary cache 를 생성한다. 
3. `tuist generate` 를 통해 cache 된 내용을 추가하여 프로젝트를 생성한다. 

### Cache 사용시 generate 명령어

```shell
# 프로젝트 생성
tuist generate # 외부 종속성만 binary cahce 로 대체
tuist generate Search # 외부 종속성, Search 종속성 binary cahce 로 대체
tuist generate Search Settings # 외부 종속성, 그리고 Search 및 Settings 종속성 binary cahce 로 대체
tuist generate --no-binary-cache # No cache at all
```
- 외부 의존성만 binary cache 를 사용하게 할 수 있다. 
- 내부 framework 도 선택에 따라 binary cache 를 사용하게 할 수 있다. 

## 코드 실행 

```shell
╰─  tuist install (take 14s)
install ...
╰─  tuist cache (take 4m 42s)
cache ...
╰─  tuist generate (take 3s)
generate ...
```
- `install` -> `cache` -> `generate` 순으로 명령어를 수행한다.
- cache 할 때에 시간이 많이 소비된다. 

### 코드 수행 결과
```shell

// (P): Project
// (F): Folder
// (T): Target

├── (P) AppStore
├── (P) Service
│   ├── (F)Feature/
│   │   ├── (F)Messenger/
│   │   │   ├── (T)MessengerPresenter
│   │   │   ├── (T)MessengerUI
│   │   │   ├── (T)MessengerPresenterTests
│   │   │   └── (T)MessengerUITests
│   │   ├── ...
│   ├── (T)CommonUI/
│   ├── (T)CommonPresenter/
│   ├── (T)Cache/
│   │   ├── (T)ComposableArchitecture
│   │   ├── ...
├── ...
```
- 기존의 Package 만 모여있는 project 가 제거되고 프로젝트별로 Cache 폴더가 추가되었다. 


# 3. 결과
- 최초 cache 할 때는 시간이 조금 오래 걸린다. 
- 하지만 `전체 빌드` 또는 `클린 빌드` 시에 빌드 속도가 현격하게 빨라졌다.

## 외부 의존성 추가 방식에 따른 시간 비교
| 방식                | 프로젝트 생성 속도 | 빌드 속도 |
|-------------------|----------------|---------|
| 기본 SPM         | 73초           | 34초    |
| Package 사용 | 55초           | 35초    |
| Cache 사용       | 3초            | 5초     |

# 4. 개선점
- 프로젝트별로 외부 의존성이 달라지는 경우 처리가 추가되어야 할 것 같다. 

# 5. 맺음말
- 확실히 클린 빌드시에 외부 의존성 빌드를 안하니 개발 생산성이 엄청 올라갔다... 좋다... 