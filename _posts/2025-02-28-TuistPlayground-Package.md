---
layout: article
title: '[TuistPlaygroud] Tuist 외부 의존성 추가하기  (2탄/N)'
key: 2025022801
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

Tuist 를 이용하여 외부 의존성을 추가하고자 한다. 

<!--more-->

# 1. 목표 
- Tuist 를 이용하여 SPM 방식으로 프로젝트에 외부 의존성을 추가한다.
- Tuist 4.x 버전에서 변경된 방식으로 코드를 작성한다. 
- 외부 의존성 추가하는 방법을 비교해본다.

## 이유
- `Package.swift` 파일을 이용하여 사전에 `tuist install` 로 외부 의존성을 build 해놓을 수 있다. 
- 외부 의존성의 사전 빌드는 프로젝트 생성 시간을 줄일 수 있다.
- 또한 `tuist cache` 와 함께 사용하여 외부 의존성을 캐싱하여 빌드 속도를 높혀 개발 생산성을 올릴 수 있다. 

# 2. 수행
- 기존 프로젝트에서도 Tuist 에서 SPM 으로 외부 의존성을 추가했었다.
- 하지만 `Package.swift` 파일을 이용한 방법으로 변경하고자 한다. 
- 외부 라이브러리는 `swift-composable-architecture` 을 사용한다. (생각보다 라이브러리 용량이 커서 테스트 하기 용이하다.)

## 환경
- Tuist 4.40.0
- Xcode 16.2
- Swift 6

## (AS-IS) `Package.swift` 사용하지 않고 외부 의존성 추가하기 

### 코드 
```swift
// Tuist > ProjectDescriptionHelpers > Project+Package.swift
extension Project {
    public static let servicePackages: [ProjectDescription.Package] = [
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .exact("1.17.1")),
    ]

    public static let testPackages: [ProjectDescription.Package] = []
}
```
- Package.remote() 함수를 이용하여 사용할 외부 의존성을 정의한다. 

```swift
// Service > Project.swift

let project = Project(
    name: name,
    organizationName: organization,
    packages: Project.servicePackages + Project.testPackages,
    targets: [...]
)
```
- 외부 의존성을 추가해야 하는 프로젝트에서 `packages` 파라미터에 기존에 정의한 Package 를 추가한다. 

```swift
// Tuist > ProjectDescriptionHelpers > Project+Framework.swift

public var dependcies: [TargetDependency] {
    case commonPresenter = "CommonPresenter"

    switch self {
        case .commonPresenter:
            return [
                .package(product: "ComposableArchitecture")
            ]
    }
}
```
- `TargetDependency.package` 를 이용하여 사전에 정의한 외부 의존성을 타겟 모듈 정의한다.


### 실행 결과

```shell
% tuist generate
Loading and constructing the graph
It might take a while if the cache is empty
Using cache binaries for the following targets: 
Generating workspace TuistPlayground.xcworkspace
Generating project AppStore
Generating project Service
Resolving package dependencies using xcodebuild
Project generated.
Total time taken: 73.082s

// whole build: 34.6
```
- `tuist generate` 에는 약 73초가 소요되었고, 전체 빌드에서는 약 34초 정도가 소요되었다. 


## (TO-BE) `Package.swift` 사용해서 외부 의존성 추가하기 

### 코드

```swift
// Tuist > Package.swift

// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: ["ComposableArchitecture": .framework]
    )
#endif

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "1.17.1"))
    ]
)
```
- `Package.swift` 에 사용할 외부의존성을 추가한다.
- 해당 파일이 존재하는 경우에는 `tuist install` 이 수행될 수 있다. 
- `// swift-tools-version: 6.0` swift tool 버전을 명시하지 않은 경우 오류가 발생될 수 있으니 주의!

```swift
// Tuist > ProjectDescriptionHelpers > Project+Framework.swift

public var dependcies: [TargetDependency] {
    case commonPresenter = "CommonPresenter"

    switch self {
        case .commonPresenter:
            return [
                .external(product: "ComposableArchitecture")
            ]
    }
}
```
- `TargetDependency.external` 을 이용하여 외부 의존성이 필요한 타겟 모듈에 정의한다. 

### 실행결과

```shell
╰─  tuist install
install ...
╰─  tuist generate
Loading and constructing the graph
It might take a while if the cache is empty
Using cache binaries for the following targets: 
Generating workspace TuistPlayground.xcworkspace
Generating project xctest-dynamic-overlay
Generating project swift-clocks
Generating project swift-syntax
Generating project swift-case-paths
Generating project swift-collections
Generating project swift-navigation
Generating project swift-identified-collections
Generating project swift-dependencies
Generating project swift-composable-architecture
Generating project Service
Generating project swift-sharing
Generating project swift-custom-dump
Generating project AppStore
Generating project combine-schedulers
Generating project swift-perception
Generating project swift-concurrency-extras
Resolving package dependencies using xcodebuild
Project generated.
Total time taken: 55.422s

// whole build: 35.8
```
- `tuist generate` 에는 약 55초가 소요되었고, 전체 빌드에서는 약 35초 정도가 소요되었다. 


# 3. 결과
- tuist 4.x 버전에서 지원하는 방식으로 `Package.swift` 을 이용하여 외부 의존성을 사전 빌드할 수 있도록 하였다.
- 전체 빌드 시간은 크게 차이가 나지 않았다. 
- 프로젝트 생성 시간은 73초 --> 55초로 많이 줄어들었다.

# 4. 개선점
- `tuist install` 과 `tuist cache` 를 이용하여 빌드속도를 개선시킬 수 있을 것 같다. 