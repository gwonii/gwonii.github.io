---
layout: article
title: (Andorid) - 안드로이드에서 쓰레드는 어떻게 사용되는가? 
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
  
---
안드로이드에서 네트워크를 공부하면서 쓰레드에 대해 공부를 하게 되었다.
쓰레드는 기본적으로 프로세스 보다 더 많은 신경을 들여야 한다. 
안드로이드에서는 특히나 관심이 필요하다. 안드로이드에서 쓰레드가 어떻게 사용되는지 한 번 알아보자. 
<!--more-->
---

## 1 .Process와 Thread

### 1.1 프로세스란?

프로세스는 간단히 실행중인 프로그램이라고 할 수 있다. 안드로이드에서는 하나의 프로세스가 하나의 앱을 실행시키는 것이다. 그리고 운영체제에 의해 메모리 공간을 할당받아 프로그램을 실행시킨다. 이런 프로세스는 프로그램에 사용되는 데이터, 메모리, 자원 그리고 쓰레드로 구성되어 있다. 

### 1.2 쓰레드란? 

쓰레드는 프로세스내에서 실제로 작업을 수행하는 주체라고 할 수 있다. 

<br>

### 1.3 프로세스와 쓰레드의 차이 

**1)** 프로세스는 쓰레드와 달리 system call에서 생성된다. (안드로이드에서도 마찬가지로 시스템에서 액티비티를 다루는 것과 유사하다. )  **2)** 프로세스는 환경을 관장하고, 쓰레드는 실행을 관장한다. **3)** 프로세스는 프로세스마다 각각의 독립된 메모리를 가지고 있지만, 쓰레드는 하나의 프로세스속에서 자원을 공유한다. **4)** 프로세스는 독립적이기 때문에 안정하지만, 쓰레드는 독립적이지 않기 때문에 안정성을 확보하기 위해서는 주의깊은 컨트롤을 해줘야한다. **5)** 



<br>

## 2. 안드로이드에서의 쓰레드

기본적으로 java에서 사용되는 쓰레드와 안드로이드에서 쓰레드는 크게 다르지 않다. 하지만 안드로이드는 쓰레드를 사용할 때에는 **핸들러(Handler)**와 함께 사용한다.  

안드로이드에서는 **핸들러**를 통해서 멀티 쓰레드의 task들의 스케쥴링을 하고,  UI에 대한 접근을 위해 메인 쓰레드에 메시지를 보내는데에도 사용된다. (UI에 대한 접근은 메인쓰레드에서만 가능하기 때문이다.)

### 2.1 안드로이드에서 쓰레드를 사용하는 방법 

1. 쓰레드와 핸들러를 정의하고, `MessageQueue`를 이용하여 쓰레드와 핸들러가 메시지를 주고받으면서 여러 쓰레드에서도 UI에 접근하게 하는 방식 

**MainActivity.class**

```java
TextView result;
Button actionButton;
ValueHandler handler

 @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
 		
 		actionButton = findViewById(R.id.btAction);
 		result = findViewById(R.id.tvValue);
 		handler = new ValueHandler();
 		
        actionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                PlusThread thread = new PlusThread();
                thread.start();

            }
        });
 }
 
class PlusThread extends Thread {

        boolean running = false;

        @Override
        public void run() {
            running = true;

            while (running) {
                value += 1;

                Message message = handler.obtainMessage();      //  핸들러에게 보낼 메시지 정의
                Bundle bundle = new Bundle();                   //  정보를 담을 bundle 정의
                bundle.putInt("value", value);                  //  bundle에 key값과 int값을 저장
                message.setData(bundle);                        //  메시지에 보낼 bundle을 설정
                handler.sendMessage(message);                   //  핸들러에 메시지를 전달

                try {
                    sleep(1000);
                } catch (InterruptedException e) {
                    Log.d(TAG, "sleep 도중 에러가 발생하였습니다. ");
                    e.printStackTrace();
                }
            }
        }
    }

class ValueHandler extends Handler {
	@Override
        public void handleMessage(@NonNull Message msg) {

            Bundle bundle = msg.getData();
            int value = bundle.getInt("value");

            String curString = "현재 값 : " + value;
            result.setText(curString);
        }
    }    
}

```



2. 쓰레드를 만들고, `MessageQueue`를 이용하지 않고, 핸들러의 post() 메소드를 이용하여 바로 핸들러에서 실행할 코드를 작성하는 방법

**MainActivity.class**

```java
Handler handler;
~~
actionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                new Thread(new Runnable() {
                    boolean running = false;

                    @Override
                    public void run() {
                        running = true;
                        while (running) {
                            value += 1;

                            handler.post(new Runnable() {
                                @Override
                                public void run() {
                                    String curString = "현재 값 : " + value;
                                    result.setText(curString);
                                }
                            });


                            try {
                                sleep(1000);
                            } catch (InterruptedException e) {
                                Log.d(TAG, "sleep 도중 에러가 발생하였습니다. ");
                                e.printStackTrace();
                            }

                        }
                    }
                }).start();
            }
        });
```

<br>

3. `AsyncTask`를 통해 UI에 접근 하는 방법

**MainActivity.class**

```java
TextView result;
Button actionButton;
Handler handler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        result = findViewById(R.id.tvResult);
        actionButton = findViewById(R.id.btAction);
        handler = new Handler();

        actionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                PlusTask plusTask = new PlusTask();
                plusTask.execute("시작");

            }
        });
    }

    class PlusTask extends AsyncTask<String, Integer, Integer> {
        int value = 0;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
        }

        @Override
        protected Integer doInBackground(String... strings) {

            boolean running = true;
            while (running) {
                value += 1;
                publishProgress(value);

                try {
                    sleep(1000);
                } catch (InterruptedException e) {
                    Log.d(TAG, "sleep 도중 에러가 발생하였습니다. ");
                    e.printStackTrace();
                }
            }
            return value;
        }

        @Override
        protected void onProgressUpdate(Integer... values) {

            super.onProgressUpdate(values);

            String curString = "현재 값 : " + value;
            result.setText(curString);
        }


        @Override
        protected void onPostExecute(Integer integer) {
            super.onPostExecute(integer);
        }
    }
```

### 2.2  `AsyncTaks` vs `Handler`

우리는 멀티쓰레드에서 UI를 접근하기 위해 `AsyncTaks` 와`핸들러`를 사용하는 방식을 공부하였다. 그렇다면 과연 효율적인 면에서는 무엇이 우위를 가질 것인가? 

**1) AsyncTask** 

`AsyncTask`는 백그라운드 작업을 처리를 쉽게 하기 위하여 제작되었다고 한다. 그러나 **low-level details** (threads, message, loops 등) 에 대한 고려는 크게 되지 않아있다고 한다. 반면 

**2)Handler**

 `Handler`는 반복적인 작업이나 대용량의 작업을 하는 것에 주로 사용된다고 한다. (ex. 여러 개의 이미지 다운로드 등) 

> 참고 링크 
>
> <https://stackoverflow.com/questions/2523459/handler-vs-asynctask>



## 3. 효율적으로 쓰레드 사용하기!

위에서 알 수 있듯이 UI에 대한 접근을 하기 위해서는 메인 쓰레드에서 그 task를 수행해야 한다. 하지만 그렇다고 메인 쓰레드가 곧 UI쓰레드인 것은 아니다. 메인 쓰레드가 UI 조작을 담고 있을 뿐이다. 

### 3.1  부드러운 UI개발을 위해 무엇을 해야 하는가? 

앱개발을 하다보면 메인 쓰레드에서 16ms 이상 걸리는 작업을 하면 안된다고들 한다. 메인 쓰레드에서 16ms 이상 걸리는 작업들이 생기면 UI의 프레임에 문제를 일으킨다. 이런 문제를 **Jark**라고 한다. 그렇기 때문에 우리는 메인 쓰레드가 16ms 이상 걸리는 작업을 하게 해서는 안되는 것이다. 

그것을 가능하게 하는 것이 **멀티 쓰레드를 이용해서 메인 쓰레드의 부담을 줄여주는 것**이다.

### 3.2 워커쓰레드 사용하기 

**워커쓰레드**, 위에서 얘기하듯  메인쓰레드의 부담을 줄여주기 위하여 새롭게 만든 것들을 가리키는 쓰레드이다. 


<br>

> **효율적으로 쓰레드 사용하기** 
>
> <http://anitoy.pe.kr/android-process-thread-concept/>
