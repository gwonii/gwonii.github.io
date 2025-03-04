---
layout: article
title: '[TuistPlaygroud] Tuist 로 KMP shared module 추가하기  (4탄/N)'
key: 2025030407
tags:
- 'iOS'
- 'Architecture'
- 'Dependency_Injection'
- 'Tuist'
- 'TuistPlayground'
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

현재 프로젝트는 KMP 를 이용한 멀티 플랫폼으로 구성되어 있다. iOS 에서는 Shared Module 을 프로젝트에 추가해야 하고 그 방법에 대해서 정리해보고자 한다. 

<!--more-->

# 1. 목표
- 현재 프로젝트는 KMP 를 이용한 멀티 플랫폼으로 구성되어 있다.
- iOS 에서는 KMP 의 shared module 을 SPM 을 통해 프로젝트에 추가하여 빌드할 수 있도록 해야 한다.
- iOS 빌드를 수행하기 전에 특정 시점에 맞춰 Shared Module 을 빌드시켜야 한다. 

# 2. 이유
- 현재 프로젝트에서는 KMP, Tuist 를 같이 사용하기로 하였다.
- KMP 의 경우 외부 package 이기 때문에 기존의 target을 추가하는 방식과는 조금 다르다.
- shared module 은 특정 시점에 빌드되어야 하고 개발에 불편을 주면 안된다. 

# 3. 실행

## 1. Shared Module gradle 설정하기
- KMP shared module 을 SPM 용으로 빌드될 수 있도록 사전에 gradle 을 설정해야 한다. 

### 코드 작성
```kotlin
kotlin {
    val xcframeworkName = "SampleShared"
    val xcf = XCFramework(xcframeworkName)

    listOf(
        iosArm64(),
        iosSimulatorArm64(),
    ).forEach {
        it.binaries.framework {
            export(project(ProjectLibs.SAMPLE_DOMAIN))
            export(project(ProjectLibs.SAMPLE_DATA))
            export(project(ProjectLibs.SAMPLE_PRESENTATION))
            export(project(ProjectLibs.SAMPLE_UI))

            baseName = xcframeworkName
            xcf.add(this)
        }
    }
}
```
- `val xcframeworkName = "SampleShared"`: xcframework 의 이름을 설정합니다.
- `listOf(...)`: 빌드되어야 할 기기 정보를 추가한다. (device, simulator)
- `export(project(...))`: "SampleShared" 라는 framework 가 의존해야 하는 항목들을 추가한다.

### 설명
- gradle 은 해당 framework 가 어떻게 빌드되어야 하는지에 대한 정보를 정의한다.
- 위의 방식은 xcframework 형태로 빌드를 시키지만, cocoapods 의 형태로도 가능하다.

## 2. iOS 프로젝트에 Shared Module 추가하기

```swift
extension Project {
    enum Framework: String {
      case app

      var dependencies: [TargetDependency] {
        switch self {
          case .app:
            return [
              .xcframework(path: "{파일 위치}/SampleShared.xcframework")
            ]
        }
      }
    }
}
```
- 위와 같은 방식으로 Shared Module 을 `xcframework` 형태로 의존성을 추가할 수 있다.
- 만약 `SampleShared.xcframework` 가 사전에 빌드되지 않는다면 빌드 오류가 발생될 것이다.

## 3. make 파일을 이용한 tuist 커스텀 명령
- 프로젝트를 실행시키기 위해서는 정해진 단계를 거쳐야 한다. 
- `build shared module` -> `tuist generate` -> `xcode build`
- github 에서 clone 을 받을 때 마다 위의 동작을 수행시킬 수는 없으므로 커스텀 명령이 필요할 것 같다. 

### 1. .mise.toml 파일 설정
- tuist 명령어를 수행시킬 때, 정해진 tuist 버전을 사용할 수 있도록 버전을 명시한다. 

```
// .mise.toml

[tools]
tuist = "4.40.0"
```

### 2. generate.sh 스크립트 작성
- make 파일에서 실행시킬 shell script 를 작성한다. 

**build shared module**
```shell
if [ "$1" = "--build-shared" ]; then
  echo "$PROJECT_ROOT"
  $PROJECT_ROOT/gradlew :...:sample_shared:assembleSampleSharedXCFramework \
    --project-dir $PROJECT_ROOT
  echo "Build and Export Finished"
else
  echo "Build and Export Passed"
fi

$PWD tuist generate
```
- gradlew 를 이용하여 "SharedSample" 을 xcframework 로 생성하는 명령어를 수행시킨다. 
- `--project-dir`: gradlew 가 있는 폴더 위치를 설정한다. (gradlew 가 있는 위치를 설정하지 않으면 오류가 발생된다.)
- `tuist generate` shared module 을 빌드한 후에 프로젝트 생성을 요청한다.


### 3. make 스크립트 작성
```shell
.PHONY: generate
generate:
	sh ./Scripts/generate.sh

.PHONY: generate-build-shared
generate-build-shared:
	sh ./Scripts/generate.sh --build-shared
```
- 일반 프로젝트 생성과 shared module 포함한 프로젝트 생성 두 개의 커스텀 명령을 작성하였다. 
  - **default generate**: `% make generate`
  - **build shared module & generate**: `% make generate-build-shared`

# 4. 결과
- shared module 은 각 모듈별로 gradle 을 설정해주어야 한다.
- 위와 같은 방법으로 KMP shared module 을 추가할 수 있다. 
- make 스크립트를 통해, 쉽게 shared module 을 빌드할 수 있다.

# 5. 맺음말
- 이렇게 kotlin 모듈과 iOS 프로젝트에 적용하면서 빌드 과정에 대해 더 깊이있게 알 수 있게 되었다.
- 더 나아가 kotlin 프로젝트에서도 많은 기여를 하면 좋겠는데, 아직 kotlin 이 많이 낯설다..
- 추후 kmp shared module 도 "tuist cache" 를 이용하여 캐싱하려고 한다. (만약 캐싱이 가능하다면...)