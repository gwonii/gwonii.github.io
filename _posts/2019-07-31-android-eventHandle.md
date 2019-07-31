---
layout: article
title: (Andorid) - 여러가지 방법으로 이벤트 처리하기 
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
  
---

---
# Event Handle

## 1.이벤트 처리하기

안드로이드에서는 특정 이벤트를 처리하기 위해 리스너(Listener)를 사용한다. 이 리스너는 어떤 이벤트에 발생에 대하여 항상 주의를 갖고 해당하는 이벤트가 발생시 반응한다. 

버튼에서 발생할 수 있는 클릭 이벤트들은 모두 View클래스에 인터페이스로 정의되어 있다. 

그래서 앞으로 자주 쓰게 될 코드에 대해서 간단히 구분하려고 한다.

**1) 클릭 이벤트 리스너 객체에 대한 참조 **

```java
protected OnclickListener mOnClickListener;
```

**2) 클릭 이벤트 리스너**

```java
public interface OnClickListener {
    void onClick(View v);
}
```

**3) 클릭 이벤트 리스너를 지정하는 함수 **

```java
public void setOnClickListener(OnClickListener I){
    if(!isClickable()){
        setClickable(true);
    }
    mOnClickListener = I;
}
```

**4) 터치에 의한 클릭 이벤트 발생 시, 이벤트 리스너의 onClick() 함수 호출**

```java
public boolean performClick() {
    
        notifyAutofillManagerOnClick();

        final boolean result;
        final ListenerInfo li = mListenerInfo;
        if (li != null && li.mOnClickListener != null) {
            playSoundEffect(SoundEffectConstants.CLICK);
            li.mOnClickListener.onClick(this);	// mOnClickListner의 onClick을 활성화 시켜준다. 
            result = true;
        } else {
            result = false;
        }

        sendAccessibilityEvent(AccessibilityEvent.TYPE_VIEW_CLICKED);

        notifyEnterOrExitForAutoFillIfNeeded(true);

        return result;
    }
```

### 1.1 익명클래스를 생성하여 이벤트 리스너로 사용하기 

기본적으로 사용되는 방식으로 리스너로 익명클래스를 사용하여 필요한 순간에 함수를 정의하여 사용한다.  

```java
/* MainActiviy */ 

Button button;

protected void onCreate(Bundle savedInstanceState){
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);
    
    button = findViewById(R.id.btMain);
    
    button.setOnclickListener(new View.OnclickListener() {
        @override
        public void onClick(View v){
            Toast.makeText(this, "Main 버튼입니다.", Toast.LENGTH_LONG).show();
        }
    });
}
```

> 1. `new View.OnclickListener(){ ~~ } ` View의 상속을 받는 익명 클래스 OnclickListener를 정의하여 사용한다. 
> 2. OnClickListen의 경우 기본적으로 `onClick`을 기본 메소드로 갖고 있기 때문에 새로 정의한 후 사용한다. 

**리스너(Listener)** 

- 리스너는 특정 이벤트를 처리하는 인터페이스이다. 
- 이벤트가 발생하면 연결된 리스너(핸들러)들에게 이벤트를 전달한다. (n개)

> ex) onClick 추상메소드를 받아 함수 내용을 재정의하고 사용한다. 

### 1.2  콜백함수를 재정의하여 이벤트 처리하기 

필요한 이벤트에 대한 콜백함수를 재정의하여 이벤트를 처리하는 방식이다. 

```java
protected class MyButton extends View {
    ~~
    @override
    public boolean onTouchEvent(MotinEvent event){
        super.onTouchEvent(event);
        int action = event.getAction();
        
                        float curX = event.getX();
                float curY = event.getY();

                if(action == MotionEvent.ACTION_DOWN){
                    println("포인트가 눌렸음" +"x좌표 : "+ curX + " , y좌표 : " + curY );
                } else if ( action == MotionEvent.ACTION_MOVE){
                    println("포인트가 움직임" +"x좌표 : "+ curX + " , y좌표 : " + curY );
                } else if ( action == MotionEvent.ACTION_UP){
                    println("포인트가 떼어짐" +"x좌표 : "+ curX + " , y좌표 : " + curY );
                }
    }
    
}
```

> 위 코드는 MyButton이 클릭될 경우 작동하는 코드를 작성하였다. 
>
> MyButton은 View의 상속을 받고 있다. 그렇기 때문에 onTouch() 메소드를 내가 원하는대로  오버라이딩 하여 사용할 수 있다. 

**콜백 함수 **

- 이벤트가 발생하면 특정 메소드를 호출해 알려준다. (1개)
- caller가 callee를 부르는 것이 아닌, callee가 caller를 부르는 것이다. 

> 보통 on으로 시작하는 함수들이 callback 함수이다. 



만약 콜백함수만을 재정의하여 사용하는 것이 아닌 **1.1** 처럼 익명 클래스를 사용하여 구한 한다면, 

```java
view1.setOnTouchListener(new View.OnTouchListener() {
      @Override
      public boolean onTouch(View v, MotionEvent event) {
           int action = event.getAction();         

           float curX = event.getX();
           float curY = event.getY();

           if(action == MotionEvent.ACTION_DOWN){
                println("포인트가 눌렸음" +"x좌표 : "+ curX + " , y좌표 : " + curY );
           } else if ( action == MotionEvent.ACTION_MOVE){
                println("포인트가 움직임" +"x좌표 : "+ curX + " , y좌표 : " + curY );
           } else if ( action == MotionEvent.ACTION_UP){
                println("포인트가 떼어짐" +"x좌표 : "+ curX + " , y좌표 : " + curY );
           }
            return true;
      }
});
```

> 이렇게 View.OnTouchListener() 익명클래스를 이용하여 코드를 구성할 수 있다. 



> 참조 링크 
>
> **1. 버튼 클릭 이벤트를 처리하는 몇 가지 방법** : <https://recipes4dev.tistory.com/55>
>
> **2. 안드로이드 버튼 기본 사용법** : [https://recipes4dev.tistory.com/54#23-button-%ED%81%B4%EB%A6%AD%EC%97%90-%EB%8C%80%ED%95%9C-%EC%9D%B4%EB%B2%A4%ED%8A%B8-%EC%B2%98%EB%A6%AC](https://recipes4dev.tistory.com/54#23-button-클릭에-대한-이벤트-처리)
>
> **3. EVENT 처리 방법 (LISTENER)** : <https://sdw8001.tistory.com/61>  
>
> **4. android devloper - View.OnClickListener** : <https://developer.android.com/reference/android/view/View.OnClickListener>

