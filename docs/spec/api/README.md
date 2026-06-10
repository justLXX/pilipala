# API 接口规范

## 1. 概述

PiliPala 通过调用 Bilibili 的 Web API 和 App API 获取数据。所有 API 端点定义在 `lib/http/api.dart` 中，按模块分组管理。

## 2. API 规范总则

### 2.1 请求规范

- **Base URL**：根据模块使用不同的 Base URL
  - Web API：`https://api.bilibili.com`
  - App API：`https://app.bilibili.com`
  - Live API：`https://api.live.bilibili.com`
  - Passport：`https://passport.bilibili.com`

- **请求方法**：
  - `GET`：获取数据
  - `POST`：提交数据（需要 CSRF Token）

- **请求参数**：
  - 使用命名参数传递
  - 可选参数使用 `?` 标记
  - 数组参数使用逗号分隔

### 2.2 响应规范

Bilibili API 的标准响应格式：

```json
{
  "code": 0,        // 状态码，0 表示成功
  "message": "0",   // 状态信息
  "ttl": 1,         // TTL
  "data": { }       // 实际数据
}
```

HTTP 层的统一封装格式：

```dart
{
  'status': true,   // 业务状态
  'data': <data>,   // 解析后的数据
  'code': 200,      // HTTP 状态码
  'msg': 'message'  // 错误信息（失败时）
}
```

### 2.3 错误处理

| 错误码 | 说明 | 处理方式 |
|--------|------|---------|
| 0 | 成功 | 正常处理 |
| -101 | 账号未登录 | 跳转登录页面 |
| -404 | 数据不存在 | 显示空数据提示 |
| -509 | 请求过于频繁 | 提示用户稍后再试 |
| -612 | 操作频繁 | 提示用户稍后再试 |
| -500 | 服务器错误 | 提示用户重试 |

## 3. 认证机制

### 3.1 Cookie 认证

使用 `dio_cookie_manager` 管理 Cookie，自动携带认证信息：

```dart
var cookieJar = PersistCookieJar();
cookieManager = CookieManager(cookieJar);
dio.interceptors.add(cookieManager);
```

### 3.2 CSRF Token

POST 请求需要携带 CSRF Token（从 Cookie 中提取）：

```dart
static Future<String> getCsrf() async {
  // 从 Cookie 中提取 bili_jct
}
```

### 3.3 WBI 签名

部分 API 需要 WBI 签名参数：

```dart
Map params = await WbiSign().makSign({
  'mid': mid,
  'platform': 'web',
});
```

## 4. API 模块列表

| 模块 | 文件 | 说明 |
|------|------|------|
| 视频 | `lib/http/video.dart` | 推荐、热门、视频详情、播放地址 |
| 用户 | `lib/http/user.dart` | 用户信息、稍后再看、历史记录 |
| 搜索 | `lib/http/search.dart` | 搜索、热搜、搜索建议 |
| 直播 | `lib/http/live.dart` | 直播列表、直播间信息 |
| 动态 | `lib/http/dynamics.dart` | 关注动态 |
| 消息 | `lib/http/msg.dart` | 私信、通知 |
| 评论 | `lib/http/reply.dart` | 评论列表、发表评论 |
| 登录 | `lib/http/login.dart` | 登录、验证码 |
| 会员 | `lib/http/member.dart` | 用户信息、投稿 |
| 关注 | `lib/http/follow.dart` | 关注列表 |
| 粉丝 | `lib/http/fan.dart` | 粉丝列表 |
| 收藏 | `lib/http/fav.dart` | 收藏夹管理 |
| 番剧 | `lib/http/bangumi.dart` | 番剧列表 |
| 黑名单 | `lib/http/black.dart` | 黑名单管理 |
| 通用 | `lib/http/common.dart` | 未读动态数等 |

## 5. 关键 API 详情

### 5.1 视频模块

#### 获取推荐视频（App）

```
GET https://app.bilibili.com/x/v2/feed/index
```

参数：
- `idx`：上次返回的 idx
- `flush`：是否刷新
- `column`：列数
- `device`：设备类型
- `device_name`：设备名称
- `pull`：拉取方式

#### 获取热门视频

```
GET https://api.bilibili.com/x/web-interface/popular
```

参数：
- `pn`：页码
- `ps`：每页数量

#### 获取视频详情

```
GET https://api.bilibili.com/x/web-interface/view
```

参数：
- `aid`：视频 AV 号
- `bvid`：视频 BV 号

#### 获取视频播放地址

```
GET https://api.bilibili.com/x/player/wbi/playurl
```

参数：
- `avid`：视频 AV 号
- `cid`：视频 CID
- `qn`：视频质量
- `fnval`：视频格式

### 5.2 用户模块

#### 获取用户信息

```
GET https://api.bilibili.com/x/space/acc/info
```

参数：
- `mid`：用户 ID

#### 获取用户状态

```
GET https://api.bilibili.com/x/relation/stat
```

参数：
- `vmid`：用户 ID

#### 获取稍后再看列表

```
GET https://api.bilibili.com/x/v2/history/toview
```

#### 获取历史记录

```
GET https://api.bilibili.com/x/v2/history
```

参数：
- `max`：最大 ID
- `view_at`：查看时间
- `business`：业务类型

### 5.3 搜索模块

#### 获取热搜列表

```
GET https://api.bilibili.com/x/web-interface/search/square
```

#### 搜索建议

```
GET https://s.search.bilibili.com/main/suggest
```

参数：
- `term`：搜索关键词

#### 搜索结果

```
GET https://api.bilibili.com/x/web-interface/wbi/search/all/v2
```

参数：
- `keyword`：搜索关键词
- `page`：页码
- `pagesize`：每页数量
- `search_type`：搜索类型

### 5.4 评论模块

#### 获取评论列表

```
GET https://api.bilibili.com/x/v2/reply
```

参数：
- `oid`：对象 ID
- `type`：对象类型（1=视频）
- `pn`：页码
- `ps`：每页数量
- `sort`：排序方式（0=时间，1=热度）

#### 发表评论

```
POST https://api.bilibili.com/x/v2/reply/add
```

参数：
- `oid`：对象 ID
- `type`：对象类型
- `message`：评论内容
- `plat`：平台（1=Web）
- `csrf`：CSRF Token

### 5.5 登录模块

#### 获取验证码

```
GET https://passport.bilibili.com/x/passport-login/captcha
```

#### 登录

```
POST https://passport.bilibili.com/x/passport-login/web/login
```

参数：
- `username`：用户名
- `password`：密码
- `token`：验证码 Token
- `challenge`：验证码 Challenge
- `validate`：验证码 Validate
- `seccode`：验证码 SecCode

## 6. API 文档参考

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect) — 社区维护的 Bilibili API 文档

## 7. 最佳实践

### 7.1 请求封装

每个模块创建独立的 HTTP 类：

```dart
class VideoHttp {
  static Future<dynamic> hotVideoList({int? pn, int? ps}) async {
    var res = await Request().get(Api.hotList, data: {
      'pn': pn,
      'ps': ps,
    });
    // 处理响应...
  }
}
```

### 7.2 响应处理

统一处理响应格式：

```dart
if (res.data['code'] == 0) {
  return {
    'status': true,
    'data': parsedData,
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
```

### 7.3 错误处理

在 Controller 层处理错误：

```dart
Future<void> loadData() async {
  isLoading.value = true;
  
  var res = await VideoHttp.hotVideoList(pn: 1, ps: 20);
  
  if (res['status']) {
    videoList.value = res['data'];
  } else {
    errorMsg.value = res['msg'] ?? '加载失败';
  }
  
  isLoading.value = false;
}
```

## 8. 注意事项

- API 可能会随时变更，需要关注社区文档更新
- 部分 API 需要登录后才能访问
- 频繁请求可能会触发限流，需要合理控制请求频率
- 敏感操作（点赞、收藏等）需要 CSRF Token
