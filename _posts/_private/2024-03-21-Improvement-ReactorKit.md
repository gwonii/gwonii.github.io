# Improvement ReactorKit

# Background

앱을 디버깅 하는 중에 의도치 않게 API 요청을 많이 하거나 Reactor 의 State 와 바인딩 된 UI 가 업데이트 되는 것을 발견하였다. 

그로 인해 앱 성능에 큰 문제가 되었다. 

# Cause Analytics

1. State 의 각 프로퍼티는 각각 UI 와 바인딩 되었고 `distinctUntilChanged` 코드가 누락된 경우가 있었다. 
2. State 구조체에 너무 많은 프로퍼티가 포함되어 있었다. 

# Solution

### 1. Pulse 도입

https://github.com/ReactorKit/ReactorKit?tab=readme-ov-file#pulse

Pulse 란 ReactorKit 에서 3.1.0 버전에서 처음 제공된 기능으로 State 의 변경된 property 를 감지하여 방출되도록 설계되었다.  

현재 Application 은 RxSwift 버전을 5.x.x 를 사용하고 있었고 그에 맞게 ReactorKit 또한 2.x.x 버전을 사용하고 있었다.

하지만 Pulse 를 사용하기 위해 RxSwift 와 ReactorKit 의 버전을 올렸다. 

그리고 `alertMessage` 와 같이 다른 state property 와 관련이 없는 항목의 경우 pulse 를 쓰도록 하였다. 

결국 `distinctUntilChanged` 을 사용하지 않더라도 변경된 State property 들만 UI 에 반영시킬 수 있었다. 

<br>

### 2. Reactor 분리 및 State 경량화

Pulse 를 사용할 수 있게 되었지만, 비대한 Reactor와 State 로 인하여 State 내에 대부분의 property 에 Pulse 를 사용해야 하는 상황이 발생되었다.

결국 하위 뷰에서 상위 Reactor State 를 바인딩 하는 것이 아닌 하위 뷰에도 Reactor 를 생성하도록 하였다. 

그리고 하위 뷰 Reactor 에서는 Domain 에 직접 접근하지 않고 상위 뷰 Reactor 에게 전달받아 사용하도록 하였다. 

왜냐하면 하위 뷰에서 Domain 을 접근하게 되면, 하위 뷰의 lifeCycle 을 고려하지 못하고 의도치 않은 DB, API 를 요청하는 경우가 생겼기 때문이다. 

그 결과 Reactor 와 State 의 규모가 작아지고 쉽게 관리할 수 있게 되었다.