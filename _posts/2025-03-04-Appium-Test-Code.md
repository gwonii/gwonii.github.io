---
layout: article
title: '[Appium] Appium 테스트 코드 작성하기 (2편)'
key: 2025030408
tags:
- iOS
- 'CI/CD'
article_header:
  type: overlay
  theme: dark
  background_color: '#123'
  background_image: false
---

Appium 을 이용하여 테스트 코드를 작성하고 통합 테스트를 수행해본다. 

<!--more-->

# 1. 목표
- Python 코드를 이용하여 Appium 에서 실행가능한 테스트 코드를 작성한다. 

# 2. 이유
- 가장 쉽고 대중적인 언어인 python 으로 테스트 코드를 작성하는 것이 유지보수를 할 때에도 가장 편할 것 같다. 

# 3. 실행

## 1. UI Component 확인하기

코드로 테스트 코드를 작성하기 위해서는 테스트 하고자 하는 화면의 Component 들의 id 값을 확인해야 합니다.
코드에 접근할 수 없는 외부팀의 경우 Appium Inspector 를 이용하여 Component ID 를 확인할 수 있습니다.

앱 진입 후 테스트 해야 하는 화면까지 이동합니다. ( ex. 로그인 화면을 테스트 하기 위함이라면 앱 실행 후 로그인 화면까지 이동합니다. )

### 1. Appium Inspector 를 실행합니다.
### 2. appium server 에 접근을 위한 값을 설정합니다.

**iOS**
```json
{
  "platformName": "ios",
  "appium:deviceName": "iPhoneX",
  "appium:platformVersion": "15.2.1",
  "appium:automationName": "xcuitest",
  "appium:udid": "{UDID}",
  "appium:bundleId": "{실행할 앱의 Bundle ID}",
  "appium:xcodeOrgId": "{애플 개발자 계정에서 식별해둔 Team ID}",
  "appium:xcodeSigningId": "iPhone Developer"
}
```
** Android**
```json
{
  "platformName": "Android",
  "appium:deviceName": "device_name",
  "appium:automationName": "UiAutomator2"
}
```

<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-03-Appium-Settings-Image/appium_2.png?raw=true" alt="01" style="zoom: 80%;" />
- json 파일을 입력하고 저장하면, 자동으로 값이 맵핑 됩니다.
- 맵핑이 완료되었다면, Start Session 버튼 클릭

### 3. Appium Inspector UI Tree 에서 테스트 해야 할 Component ID 를 확인합니다.
<img src="https://github.com/gwonii/gwonii.github.io/blob/master/img/2025-03-03-Appium-Settings-Image/appium_3.png?raw=true" alt="01" style="zoom: 80%;" />

## 2. 테스트 코드 작성
### 1. 필요한 라이브러리를 추가합니다. 
**iOS**
```python
import unittest
from appium import webdriver
from appium.options.ios import XCUITestOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.remote.webelement import WebElement
```

**Android**
```python
import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.remote.webelement import WebElement
```

### 2. Appium Server 접속 정보를 작성합니다.
**iOS**
```python
team_id = "F5NU2PA3PK"

options = {
    "platformName": "iOS",
    "platformVersion": "15.7.3",  # 디바이스의 iOS 버전 조정
    "automationName": "XCUITest",
    "deviceName": "iPhone",  # 사용하는 디바이스 이름에 맞춰 조정
    "udid": "{UUID}",  # 디바이스의 UDID 기입
    "bundleId": "{BUNDLE_ID}",
    "xcodeOrgId": f"{team_id}",  # 애플 개발자 Team ID 기입
    "xcodeSigningId": "iPhone Developer",
}

server_url = "http://127.0.0.1:xxxx"
```

**Android**
```python
options = {
    "platformName": "Android",
    "deviceName": "{DEVICE_NAME}",
    "automationName": "UiAutomator2",
    "appPackage": "{APP_PACKAGE}",
    "appActivity": "{APP_ACTIVITY}",
}

server_url = "http://127.0.0.1:xxxx"
```
- Appium inspector 때와 달리 “appPackage” 와 “appActivity” 를 선언해줘야 합니다.

### 3. 테스트 코드 수행시 서버 접속한 driver 설정
```python
class LoginTenantInputTests(unittest.TestCase):
    def setUp(self) -> None:
        # iOS
        self.driver = webdriver.Remote(
            server_url, options=XCUITestOptions().load_capabilities(options)
        )

        # Android
        self.driver = webdriver.Remote(
            server_url, options=UiAutomator2Options().load_capabilities(options)
        )
        print("setup called")

    def tearDown(self) -> None:
        if self.driver:
            self.driver.quit()
        print("tearDown called")
```

### 4. 테스트 해야 할 Component 정의
```python
class LoginTenantInputTests(unittest.TestCase):
    @property
    def input_description_label(self) -> WebElement:
        self.driver.find_element(
            by=AppiumBy.ACCESSIBILITY_ID, value="LoginTenantInput_InputDescriptionLabel"
        )

    @property
    def input_text_field(self) -> WebElement:
        self.driver.find_element(
            by=AppiumBy.ACCESSIBILITY_ID, value="LoginTenantInput_InputTextField"
        )

    @property
    def next_button(self) -> WebElement:
        self.driver.find_element(
            by=AppiumBy.ACCESSIBILITY_ID, value="LoginTenantInput_NextButton"
        )
```
- Component 접근을 위해 AppiumBy.ACCESSIBILITY_ID 를 사용하였습니다.

### 5. 테스트 코드 작성
```python
class LoginTenantInputTests(unittest.TestCase):
    @property
    def input_description_label(self) -> WebElement:
        self.driver.find_element(
            by=AppiumBy.ACCESSIBILITY_ID, value="LoginTenantInput_InputDescriptionLabel"
        )

    @property
    def input_text_field(self) -> WebElement:
        self.driver.find_element(
            by=AppiumBy.ACCESSIBILITY_ID, value="LoginTenantInput_InputTextField"
        )

    @property
    def next_button(self) -> WebElement:
        self.driver.find_element(
            by=AppiumBy.ACCESSIBILITY_ID, value="LoginTenantInput_NextButton"
        )

    def setUp(self) -> None:
        self.driver = webdriver.Remote(
            server_url, options=XCUITestOptions().load_capabilities(options)
        )
        print("setup called")

    def tearDown(self) -> None:
        if self.driver:
            self.driver.quit()

        print("tearDown called")

    # LoginTenantInput 초기 화면을 테스트 합니다.
    # - InputDescriptionLabel
    # - InputTextField
    # - NextButton
    def test_initial_view(self) -> None:
        ## given
        self.driver.implicitly_wait(10)

        expected_input_description_label_text = "조직 도메인을 입력해 주세요."
        expected_input_description_label_is_displayed = True

        expected_input_text_field_text = ""
        expected_input_text_field_is_displayed = True

        expected_next_button_text = "다음"
        expected_next_button_is_enabled = False

        ## when
        actual_input_description_label_text = self.input_description_label.text
        actual_input_description_label_is_displayed = (
            self.input_description_label.is_displayed()
        )

        actual_input_text_field_text = self.input_text_field.text
        actual_input_text_field_is_displayed = input_text_field.is_displayed()

        actual_next_button_text = self.next_button.text222
        actual_next_button_is_enabled = self.next_button.is_enabled()

        ## then
        self.assertEqual(
            actual_input_description_label_text,
            expected_input_description_label_text,
            f"Expected description label text: {expected_input_description_label_text}, but got: {actual_input_description_label_text}",
        )
        self.assertEqual(
            actual_input_description_label_is_displayed,
            expected_input_description_label_is_displayed,
            f"Expected description label visibility: {expected_input_description_label_is_displayed}, but got: {actual_input_description_label_is_displayed}",
        )

        self.assertEqual(
            actual_input_text_field_text,
            expected_input_text_field_text,
            f"Expected text field text: {expected_input_text_field_text}, but got: {actual_input_text_field_text}",
        )
        self.assertEqual(
            actual_input_text_field_is_displayed,
            expected_input_text_field_is_displayed,
            f"Expected text field visibility: {expected_input_text_field_is_displayed}, but got: {actual_input_text_field_is_displayed}",
        )

        self.assertEqual(
            actual_next_button_text,
            expected_next_button_text,
            f"Expected next button text: {expected_next_button_text}, but got: {actual_next_button_text}",
        )
        self.assertEqual(
            actual_next_button_is_enabled,
            expected_next_button_is_enabled,
            f"Expected next button enabled state: {expected_next_button_is_enabled}, but got: {actual_next_button_is_enabled}",
        )

    def test_next_button_if_enabled(self) -> None:
        ## given
        self.driver.implicitly_wait(10)
        expected_button_text = "다음"
        expected_button_enabled = True

        ## when
        self.tenant_text_field.send_keys("doorayqa")

        actual_button_text = self.next_button.text
        actual_button_enabled = self.next_button.is_enabled()

        ## then
        self.assertEqual(expected_button_text, actual_button_text)
        self.assertEqual(expected_button_enabled, actual_button_enabled)

    def test_next_button_action(self):
        ## given
        self.driver.implicitly_wait(10)
        expected_home_button_text = "로그인 첫 화면"

        ## when
        self.tenant_text_field.send_keys("tenant")
        self.next_button.click()

        home_button = WebDriverWait(self.driver, 10).until(
            EC.visibility_of_element_located(
                (AppiumBy.ACCESSIBILITY_ID, "LoginWebView_HomeButton")
            )
        )
        actual_home_button_text = home_button.text

        ## then
        self.assertEqual(actual_home_button_text, expected_home_button_text)

    def test_next_button_action_with_failure(self):
        ## given
        self.driver.implicitly_wait(10)
        expected_alert_messages = [
            "존재하지 않는 도메인입니다. 다시 입력해 주세요.",
            "서비스 오류가 발생하였습니다. 해당 오류는 서비스 운영자에게 자동으로 보고됩니다.",
        ]

        ## when

        self.input_text_field.send_keys("tenanttttt")
        self.next_button.click()

        alert = WebDriverWait(self.driver, 10).until(EC.alert_is_present())
        actual_alert_message = alert.text

        ## then
        ### 존재하지 않는 도메인 입력시 두 오류가 발생될 수 있음
        ### - "존재하지 않는 도메인입니다. 다시 입력해 주세요."
        ### - "서비스 오류가 발생하였습니다. 해당 오류는 서비스 운영자에게 자동으로 보고됩니다."
        ### : 둘 중 하나라도 일치하면 테스트 통과하도록 작성하였습니다.
        self.assertIn(actual_alert_message, expected_alert_messages)
        alert.accept

if __name__ == "__main__":
    unittest.main()
```

# 4. 결과
- 오랜만에 python 코드를 작성해서 낯선 부분이 있었지만, 자주 사용되는 메소드를 기억해두면 쉽게 테스트 코드를 작성할 수 있을 것 같다.
- iOS, Android 를 하나의 코드로 통합 테스트를 수행시킬 수 있는 것은 큰 장점인 것 같다. 