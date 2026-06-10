# 登录功能规格书

## 1. 功能描述

登录功能允许用户通过用户名密码登录 Bilibili 账号，支持验证码验证、扫码登录等方式。

## 2. 用户流程

```
用户进入登录页面
    │
    ├── 选择登录方式
    │   ├── 密码登录
    │   │   ├── 输入用户名
    │   │   ├── 输入密码
    │   │   ├── 输入验证码
    │   │   └── 点击登录
    │   │
    │   └── 扫码登录（可选）
    │       ├── 展示二维码
    │       └── 扫描确认
    │
    ├── 登录成功
    │   ├── 保存登录状态
    │   ├── 保存用户信息
    │   └── 跳转到首页
    │
    └── 登录失败
        ├── 显示错误信息
        └── 重新输入
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 登录页 | `/loginPage` | `lib/pages/login/view.dart` | 登录主页面 |

## 4. Controller 职责

### 4.1 LoginController

文件：`lib/pages/login/controller.dart`

职责：
- 管理登录状态
- 处理验证码
- 执行登录操作

```dart
class LoginController extends GetxController {
  RxString username = ''.obs;
  RxString password = ''.obs;
  RxString captchaToken = ''.obs;
  RxString captchaChallenge = ''.obs;
  RxString captchaValidate = ''.obs;
  RxBool isLoading = false.obs;
  RxString errorMsg = ''.obs;
  
  Future<void> queryCaptcha() async;
  Future<void> login() async;
  Future<void> logout() async;
}
```

## 5. 数据模型

### 5.1 验证码数据

文件：`lib/models/login/index.dart`

```dart
class CaptchaDataModel {
  String? token;
  String? challenge;
  String? gt;
  String? riskType;
}
```

### 5.2 登录响应

```dart
class LoginResponse {
  int? code;
  String? message;
  LoginData? data;
}

class LoginData {
  String? accessToken;
  String? refreshToken;
  int? expiresIn;
  UserInfoData? userInfo;
}
```

## 6. API 依赖

### 6.1 获取验证码

```
GET https://passport.bilibili.com/x/passport-login/captcha
```

响应：
```json
{
  "code": 0,
  "data": {
    "token": "...",
    "challenge": "...",
    "gt": "...",
    "risk_type": "..."
  }
}
```

### 6.2 密码登录

```
POST https://passport.bilibili.com/x/passport-login/web/login
```

参数：
- `username`：用户名
- `password`：密码（加密）
- `token`：验证码 Token
- `challenge`：验证码 Challenge
- `validate`：验证码 Validate
- `seccode`：验证码 SecCode

### 6.3 获取登录用户信息

```
GET https://api.bilibili.com/x/web-interface/nav
```

## 7. 状态管理

### 7.1 登录状态

```
[初始状态]
    │
    ├── queryCaptcha()
    │   ├── 请求 API
    │   └── 成功 → 显示验证码
    │
    ├── login()
    │   ├── isLoading = true
    │   ├── 请求 API
    │   ├── 成功 → 保存登录信息
    │   │   ├── userInfo.put('userInfoCache', data)
    │   ├── 触发登录事件
    │   │   ├── loginEvent.fire(true)
    │   └── 跳转到首页
    │
    └── logout()
        ├── 清除登录信息
        ├── userInfo.delete('userInfoCache')
        ├── 触发登出事件
        │   ├── loginEvent.fire(false)
        └── 跳转到登录页
```

## 8. 注意事项

- 登录信息存储在 Hive 的 `userInfo` Box 中
- 使用 Cookie 管理登录状态
- 验证码使用极验（Geetest）
- 登录失败需要重新获取验证码
- 支持自动登录（记住密码）
- 登录状态变更通过 EventBus 通知其他模块

## 9. 迁移状态

- [x] 旧代码功能完成
- [x] 三层架构迁移（LoginRepository + UseCases + LoginController）
- [x] API 端点修正（loginInByWebPwd、qrCodeApi、loginInByQrcode）
- [ ] 登录页面 UI（LoginPage 未创建）
- [ ] SMS 登录 / 扫码登录 UseCase
- [ ] Token 持久化（登录信息保存/清除）
- [ ] 路由注册
- [ ] 依赖注入注册
