---
layout: article
title: '[TuistPlaygroud] Tuist로 구조설계 하기  (1탄/N)'
key: 202502232
tags:
- Tuist
- Architecture
- iOS
- TuistPlayground
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false

---

Tuist 를 이용하여 프로젝트 설계를 단계적으로 작성해보려고 한다. 

<!--more-->

# 1. 목표
- Tuist 를 이용하여 요구조건에 맞는 멀티 모듈 프로젝트를 구성한다.

## 요구사항
- Feature는 UI, Presenter, UITest, PresenterTest 로 나눈다.
- 프로젝트는 `AppStore` (앱 모듈), `Service` (앱 모듈 이외의 모듈 모음) 로 구성한다. 
- swift-composable-architecture 라이브러리를 추가하여 UI, Presenter 에서 사용할 수 있도록 제공한다. 
- Shared(KMP) 는 우선 제외한다.

## 전체 구조

```swift
// (P): Project
// (F): Folder
// (T): Target

├── (P) App
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
├── ...
├── (P)Shared/ (KMP)
│   ├── MessengerDomain
│   ├── ...
├── (F)ThirdParty
│   ├── swift-composable-architecture
│   ├── ...
```

# 2. 수행

## 환경
- Tuist 4.40.0
- Xcode 16.2
- Swift 6

## Tuist Project Helper 구현하기
- 크게 AppTarget 과 FrameworkTarget 으로 구분한다. 

### AppTarget
```swift
// Tuist > ProjectDescriptionHelpers > Project+Target.swift
public static func makeAppTargets(
    rootPath: String = ".",
    name: String,
    destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
    dependencies: [TargetDependency] = [],
    baseBundleID: String
) -> [Target] {
    let mainTarget: Target = .target(
        name: name,
        destinations: destinations,
        product: .app,
        bundleId: "${BUNDLE_IDENTIFIER}",
        deploymentTargets: .iOS(minimumOSVersion),
        infoPlist: .extendingDefault(with: Project.infoPlist()),
        sources: ["\(rootPath)/\(name)/Sources/**"],
        resources: ["\(rootPath)/\(name)/Resources/**"],
        dependencies: dependencies,
        settings: .settings(
            base: Project.baseSettings(),
            configurations: [
                .debug(
                    name: "Debug",
                    settings: [
                        "BUNDLE_IDENTIFIER": "\(baseBundleID)",
                        "DISPLAY_NAME": "\(name)-dev"
                    ]
                ),
                .release(
                    name: "Release",
                    settings: [
                        "BUNDLE_IDENTIFIER": "\(baseBundleID)",
                        "DISPLAY_NAME": "\(name)"
                    ]
                )
            ]
        )
    )
    return [mainTarget]
}
```

### FrameworkTarget
- 조건에 따라 framework와 대응되는 test target 을 구성하도록 하였다. 
```swift
// Tuist > ProjectDescriptionHelpers > Project+Target.swift
public static func makeFrameworkTargets(
    rootPath: String = ".",
    name: String,
    destinations: ProjectDescription.Destinations = [.iPhone, .iPad],
    dependencies: [TargetDependency],
    testDependencies: [TargetDependency] = [],
    baseBundleID: String,
    useTestTarget: Bool = true,
    useResources: Bool = false
) -> [Target] {
    let sources: Target = .target(
        name: name,
        destinations: destinations,
        product: .framework,
        bundleId: "\(baseBundleID).\(name)",
        deploymentTargets: .iOS(minimumOSVersion),
        infoPlist: .default,
        sources: ["\(rootPath)/\(name)/Sources/**"],
        resources: useResources ? ["\(rootPath)/\(name)/Resources/**"] : [],
        dependencies: dependencies,
        settings: .settings(
            base: Project.baseSettings(),
            configurations: [
                .debug(
                    name: "Debug",
                    settings: [
                        "BUNDLE_IDENTIFIER": "\(baseBundleID).\(name)"
                    ]
                ),
                .release(
                    name: "Release",
                    settings: [
                        "BUNDLE_IDENTIFIER": "\(baseBundleID).\(name)"
                    ]
                )
            ]
        )
    )

    let tests: Target = .target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(baseBundleID).\(name)Tests",
        deploymentTargets: .iOS(minimumOSVersion),
        infoPlist: .default,
        sources: ["\(rootPath)/\(name)/Tests/**"],
        resources: [],
        dependencies: [.target(name: name)] + testDependencies,
        settings: .settings(
            base: Project.baseSettings(),
            configurations: [
                .debug(
                    name: "Debug",
                    settings: [
                        "BUNDLE_IDENTIFIER": "\(baseBundleID).\(name)Tests"
                    ]
                ),
                .release(
                    name: "Release",
                    settings: [
                        "BUNDLE_IDENTIFIER": "\(baseBundleID).\(name)Tests"
                    ]
                )
            ]
        )
    )

    return useTestTarget ? [sources, tests] : [sources]
}
```

## Third Party 패키지 구성하기

### service package
```swift
// Tuist > ProjectDescriptionHelpers > Project+Package.swift
public static let servicePackages: [ProjectDescription.Package] = [
    .remote(url: "https://github.com/pointfreeco/swift-composable-architecture.git", requirement: .exact("1.17.1")),
    ...
]
```

### test package
```swift
// Tuist > ProjectDescriptionHelpers > Project+Package.swift
public static let testPackages: [ProjectDescription.Package] = [
    .remote(url: "https://github.com/Quick/Nimble.git", requirement: .exact("13.7.1")),
    .remote(url: "https://github.com/Quick/Quick.git", requirement: .exact("7.6.2"))
]
```

## 모듈 의존성 구성하기

### CommonFramework
- FeatureUI, FeaturePresenter 에서 사용할 공통 모듈을 구성한다. 

```swift
// Tuist > ProjectDescriptionHelpers > Project+Framework.swift
public enum CommonFramework: String, CaseIterable {
    case commonPresenter = "CommonPresenter"
    case commonUI = "CommonUI"

    public var dependcies: [TargetDependency] {
        switch self {
            case .commonPresenter:
                return [
                    .package(product: "ComposableArchitecture")
                ]
            case .commonUI:
                return [...]
        }
    }
}
```

### FeatureFramework
- MessengerUI, MessengerPresenter 는 CommonPreseter 를 추가하여 TCA 를 사용할 수 있도록 하였다. 

```swift
// Tuist > ProjectDescriptionHelpers > Project+Framework.swift
public enum FeatureFramework: String, CaseIterable {
    case messengerPresenter = "MessengerPresenter"
    case messengerUI = "MessengerUI"

    public var dependcies: [TargetDependency] {
        switch self {
            case .messengerPresenter:
                return [
                    .target(name: CommonFramework.commonPresenter.rawValue)
                ]
            case .messengerUI:
                return [
                    .target(name: Self.messengerPresenter.rawValue),
                    .target(name: CommonFramework.commonUI.rawValue),
                    .target(name: CommonFramework.commonPresenter.rawValue)
                ]
        }
    }
}
```

## 다중 프로젝트 워크스페이스 구성하기

### Workspace
- appclication 과 service 프로젝트를 포함한 workspace 를 구성한다. 

```swift
// workspace.swift
let workspace = Workspace(
    name: "HOGWON",
    projects: [
        "application",
        "service"
    ]
)
```

### application
```swift
// application > Project.swift
let project: Project = Project(
    name: name,
    organizationName: organization,
    targets: [
        Project.makeAppTargets(
            name: Framework.app.rawValue,
            dependencies: Framework.app.dependcies,
            baseBundleID: baseBundleID
        ),
    ].flatMap { $0 }
)
```

### service
- 기존에 구성한 CommonFramework 와 FeatureFramework enum 값을 이용하여 target 을 구성한다. 

```swift
// service > Project.swift
let project = Project(
    name: name,
    organizationName: organization,
    packages: Project.servicePackages + Project.testPackages,
    targets: [
        Project.CommonFramework.allCases
            .flatMap { framework in
                Project.makeFrameworkTargets(
                    name: framework.rawValue,
                    dependencies: framework.dependcies,
                    baseBundleID: baseBundleID,
                    useTestTarget: false
                )
            },
        Project.FeatureFramework.allCases
            .flatMap { framework in
                Project.makeFrameworkTargets(
                    name: framework.rawValue,
                    dependencies: framework.dependcies,
                    testDependencies: Project.testDependencies,
                    baseBundleID: baseBundleID,
                    useTestTarget: true
                )
            }
    ].flatMap { $0 }
)
```

# 3. 개선점
1. TCA Wrapper Framework 구성하기
2. "Package.swift" 파일 이용하여 Third Party 패키지 추가하기

### 1. TCA Wrapper Framework 구성하기
- 현재 TCA 는 Static Library 형태로 제공되고 있다. 
- 처음에는 FeatureUI, FeaturePresenter 에 각각 의존성을 추가하였으나, 
`Package 'ComposableArchitecture' has been linked from target 'CalendarPresenter' and target 'CalendarUI', it is a static product so may introduce unwanted side effects.` 오류 가 발생됨
- 결국 "Do Not Embed" 형태로 CommonPresenter 를 통하여 TCA 의존성 제공
- 하지만 CommonPresenter 는 점차 규모가 커질 수 있으므로 TCA 의 독립성이  떨어질 수 있음. (가령 TCA 만 의존하고 싶거나 혹은 TCA 를 제외한 CommonPresenter 만 의존하고 싶거나 ...)
- CommonPresenter 대신에 TCAFramework 와 같은 TCA 를 wrapping 하는 역할의 framework 를 사용해볼 수 있을 것 같다. 

### 2. "Package.swift" 파일 이용하여 Third Party 패키지 추가하기
- 현재 사용한 방식의 경우 `tuist generate` 시에 spm 의존성을 확인하고 추가한다. 
- 만약 기존에 tuist cache 가 없다면 spm 을 추가하는데 시간이 걸릴 수 있다. 
- 그래서 "Package.swift" 를 이용하여 `tuist install & tuist generate` 을 통해 SPM 을 구성한다면 개발 속도에 큰 도움이 될 것 같다. 

# 4. 맺음말
- 다음 편에서는 위의 개선점을 개선하고 Tuist 를 이용하여 KMP shared module 을 추가하는 방법을 작성해보려고 한다. 