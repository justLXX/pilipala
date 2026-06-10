# HTTP 层规范

## 1. 概述

PiliPala 使用 **Dio** 作为 HTTP 客户端，通过单例模式封装为 `Request` 类，统一处理请求、响应、错误和认证。

## 2. 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                        HTTP Layer                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ Request  │ │ApiInterceptor│ │ Cookie  │ │ WBI Sign│       │
│  │(Dio     │ │(Error/Auth)│ │  (Jar)  │ │(Sign)   │       │
│  │ Singleton)│ │          │ │         │ │         │       │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘       │
│       │            │            │            │              │
│       └────────────┴────────────┴────────────┘              │
│                         │                                   │
│       ┌─────────────────┼─────────────────┐               │
│       ▼                 ▼                 ▼               │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐          │
│  │ VideoHttp│      │ UserHttp │      │ ...      │          │
│  │(Video   │      │(User    │      │(Other   │          │
│  │  APIs)   │      │  APIs)   │      │  APIs)   │          │
│  └──────────┘      └──────────┘      └──────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## 3. Request 单例

### 3.1 核心实现

`lib/http/init.dart` 中的 `Request` 类是 Dio 的封装单例：

```dart
class Request {
  static final Request _instance = Request._internal();
  static late CookieManager cookieManager;
  static late final Dio dio;
  
  factory Request() => _instance;
  
  Request._internal() {
    // 初始化 Dio
    dio = Dio();
    // 配置 Base URL、超时、拦截器等
  }
}
```

### 3.2 关键配置

```dart
// Base URL 配置（lib/http/constants.dart）
class HttpString {
  static const String baseUrl = 'https://www.bilibili.com';
  static const String apiBaseUrl = 'https://api.bilibili.com';
  static const String appBaseUrl = 'https://app.bilibili.com';
  static const String liveBaseUrl = 'https://api.live.bilibili.com';
  static const String passBaseUrl = 'https://passport.bilibili.com';
  // ...
}

// Dio 配置
Dio(BaseOptions(
  baseUrl: HttpString.apiBaseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  validateStatus: (status) => true, // 自定义状态码验证
));
```

## 4. API 端点规范

### 4.1 端点定义

所有 API 端点定义在 `lib/http/api.dart` 中：

```dart
class Api {
  // 推荐视频
  static const String recommendListApp =
      '${HttpString.appBaseUrl}/x/v2/feed/index';
  
  // 热门视频
  static const String hotList = '/x/web-interface/popular';
  
  // 视频详情
  static const String videoIntro = '/x/web-interface/view';
  
  // 视频播放地址
  static const String videoUrl = '/x/player/wbi/playurl';
  
  // 评论列表
  static const String replyList = '/x/v2/reply';
  
  // ...
}
```

### 4.2 端点命名规范

- 使用驼峰命名法
- 按模块分组（推荐、视频、用户、搜索等）
- 包含完整 URL 或相对路径
- 注释说明接口用途和文档链接

## 5. 响应格式规范

### 5.1 标准响应格式

所有 HTTP 方法返回统一的 Map 格式：

```dart
// 成功响应
{
  'status': true,
  'data': <实际数据>,
  'code': 200,
}

// 失败响应
{
  'status': false,
  'data': [],
  'msg': '错误信息',
  'code': -1,
}
```

### 5.2 HTTP 模块实现示例

```dart
class VideoHttp {
  static Future<dynamic> hotVideoList({int? pn, int? ps}) async {
    var res = await Request().get(Api.hotList, data: {
      'pn': pn,
      'ps': ps,
    });
    
    if (res.data['code'] == 0) {
      return {
        'status': true,
        'data': (res.data['data']['list'] as List)
            .map((e) => HotVideoItemModel.fromJson(e))
            .toList(),
        'code': 200,
      };
    } else {
      return {
        'status': false,
        'data': [],
        'msg': res.data['message'],
        'code': res.data['code'],
      };
    }
  }
}
```

## 6. 请求方法规范

### 6.1 GET 请求

```dart
// 带参数的 GET 请求
var res = await Request().get(Api.hotList, data: {
  'pn': pageNumber,
  'ps': pageSize,
});
```

### 6.2 POST 请求

```dart
// 带表单数据的 POST 请求
var res = await Request().post(Api.likeVideo, data: {
  'aid': aid,
  'like': 1,
  'csrf': await Request.getCsrf(),
});
```

### 6.3 特殊请求

```dart
// 自定义 Header
var res = await Request().get(url, extra: {'ua': 'pc'});

// 二进制响应（弹幕）
var res = await Request().get(
  Api.webDanmaku,
  data: params,
  extra: {'resType': ResponseType.bytes},
);
```

## 7. 拦截器规范

### 7.1 ApiInterceptor

`lib/http/interceptor.dart` 中的拦截器处理：

- **请求拦截**：添加认证信息、User-Agent
- **响应拦截**：处理 302 重定向、提取 access_key
- **错误处理**：网络错误提示、状态码处理

### 7.2 拦截器实现

```dart
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 在请求之前添加头部或认证信息
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 处理 302 重定向
    if (response.statusCode == 302) {
      final List<String> locations = response.headers['location']!;
      // 提取 access_key
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 错误处理
    super.onError(err, handler);
  }
}
```

## 8. Cookie 管理

### 8.1 Cookie Jar

使用 `dio_cookie_manager` 管理 Cookie：

```dart
// 初始化
static late CookieManager cookieManager;

// 设置
var cookieJar = PersistCookieJar();
cookieManager = CookieManager(cookieJar);
dio.interceptors.add(cookieManager);
```

### 8.2 CSRF Token

从 Cookie 中提取 CSRF Token 用于 POST 请求：

```dart
static Future<String> getCsrf() async {
  // 从 Cookie 中提取 bili_jct
  return csrfToken;
}
```

## 9. WBI 签名

### 9.1 签名机制

部分 API 需要 WBI 签名（`w_rid` 和 `wts` 参数）：

```dart
class WbiSign {
  Future<Map<String, dynamic>> makSign(Map<String, dynamic> params) async {
    // 1. 获取 WBI keys（缓存）
    // 2. 对参数排序并拼接
    // 3. 计算 MD5 签名
    // 4. 返回带签名的参数
  }
}
```

### 9.2 使用方式

```dart
Map params = await WbiSign().makSign({
  'mid': mid,
  'platform': 'web',
});
var res = await Request().get(Api.someEndpoint, data: params);
```

## 10. 错误处理规范

### 10.1 HTTP 错误码处理

| 状态码 | 处理方式 |
|--------|---------|
| 200 | 正常处理 |
| 302 | 重定向，提取 access_key |
| 400-499 | 客户端错误，显示错误信息 |
| 500-599 | 服务器错误，提示用户重试 |

### 10.2 业务错误码

Bilibili API 返回的业务错误码：

```dart
if (res.data['code'] == 0) {
  // 业务成功
} else if (res.data['code'] == -101) {
  // 未登录
} else {
  // 其他业务错误
}
```

## 11. 最佳实践

### 11.1 模块划分

按业务模块划分 HTTP 类：

```
http/
  video.dart    # 视频相关 API
  user.dart     # 用户相关 API
  search.dart   # 搜索相关 API
  live.dart     # 直播相关 API
  dynamics.dart # 动态相关 API
  ...
```

### 11.2 参数命名

- 使用命名参数提高可读性
- 可选参数使用 `?` 标记
- 默认值在方法内设置

### 11.3 响应处理

- 统一返回 `{'status': bool, 'data': ...}` 格式
- 在 HTTP 层完成数据解析（`fromJson`）
- 错误信息包含在响应中

### 11.4 避免的问题

- ❌ 不要在 HTTP 层直接显示 Toast/Dialog
- ❌ 不要在 HTTP 层处理导航
- ❌ 不要在 HTTP 层修改全局状态
- ✅ 所有副作用在 Controller 层处理
