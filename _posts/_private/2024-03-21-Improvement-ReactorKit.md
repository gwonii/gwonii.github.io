# Improvement ReactorKit

# Background
현재 앱 서비스는 ReactorKit 을 통해 MVI 아키텍처로 코드가 구현되어 있다. 

그런데 ReactorKit 의 하나의 Mutation 에 의해 의도하지 않은 State 가 방출되는 문제가 발생되었다. 

가령...