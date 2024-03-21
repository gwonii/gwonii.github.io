# Improvement RealmDB

# Background

현재 개발하고 있는 Application에서는 Realm DB를 사용하고 있다. 그리고 모든 데이터를 DB 에 우선 저장한 후 Presentation 에 전달하도록 구현되었다. 

가령 Server 에 데이터를 요청하게 되면 Response 값을 바로 사용하는 것이 아닌 DB 에 Entity 를 저장하고 그것을 Presentation 과 바인딩 하여 사용하는 형태이다. 

그러다보니 DB에 문제가 생기면 앱에 큰 문제를 일으킬 수 있었다. 
그리고 불행히도 DB Crash 가 다수 발생되어 있었고 빠르게 오류를 수정해야 했다. 


# Cause Analytics
- CRUD transaction 오류
- Memory 과부화

Firebase 오류를 확인해본 결과 위와 같은 Crash 가 발생된 것을 확인할 수 있었다. 

위와 같은 오류가 발생된 이유는 다양했다. 

## 1. 불필요한 Realm 객체 생성

## 2. Realm 의 Main Thread 점유

## 3. 불필요한 DB Read

## 4. 무조건적인 Thread Safe