# 用户中心功能规格书

## 1. 功能描述

用户中心页面展示用户个人信息、关注/粉丝数、投稿视频、动态等。支持查看其他用户的信息。

## 2. 用户流程

```
用户进入用户中心
    │
    ├── 加载用户信息
    │   ├── 显示骨架屏
    │   ├── 请求 API 获取用户信息
    │   └── 渲染用户资料
    │
    ├── 查看用户投稿
    │   ├── 视频投稿
    │   ├── 专栏投稿
    │   └── 合集
    │
    ├── 查看用户动态
    │   └── 用户发布的动态列表
    │
    ├── 操作
    │   ├── 关注/取消关注
    │   ├── 发私信
    │   └── 加入黑名单
    │
    └── 查看关注/粉丝
        ├── 关注列表
        └── 粉丝列表
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 用户中心 | `/member` | `lib/pages/member/view.dart` | 用户信息主页面 |
| 我的 | `/media` | `lib/pages/mine/view.dart` | 当前登录用户中心 |
| 关注列表 | `/follow` | `lib/pages/follow/view.dart` | 关注用户列表 |
| 粉丝列表 | `/fan` | `lib/pages/fan/view.dart` | 粉丝列表 |
| 用户投稿 | `/memberArchive` | `lib/pages/member_archive/view.dart` | 用户投稿视频 |
| 用户专栏 | `/memberArticle` | `lib/pages/member_article/view.dart` | 用户专栏 |
| 用户动态 | `/memberDynamics` | `lib/pages/member_dynamics/view.dart` | 用户动态 |
| 用户投币 | `/memberCoin` | `lib/pages/member_coin/view.dart` | 用户最近投币 |
| 用户喜欢 | `/memberLike` | `lib/pages/member_like/view.dart` | 用户最近喜欢 |
| 用户合集 | `/memberSeasons` | `lib/pages/member_seasons/view.dart` | 用户合集 |

## 4. Controller 职责

### 4.1 MemberController

文件：`lib/pages/member/controller.dart`

职责：
- 管理用户信息
- 处理关注/取消关注
- 管理用户投稿列表

```dart
class MemberController extends GetxController {
  Rx<MemberInfoModel> memberInfo = MemberInfoModel().obs;
  RxBool isFollowed = false.obs;
  RxList<VideoItem> archiveList = <VideoItem>[].obs;
  int mid;
  
  Future<void> queryMemberInfo() async;
  Future<void> queryFollowStatus() async;
  Future<void> followUser() async;
  Future<void> queryArchiveList() async;
}
```

### 4.2 MineController

文件：`lib/pages/mine/controller.dart`

职责：
- 管理当前登录用户信息
- 处理登录状态

```dart
class MineController extends GetxController {
  Rx<UserInfoData> userInfo = UserInfoData().obs;
  Rx<UserStat> userStat = UserStat().obs;
  RxBool userLogin = false.obs;
  
  Future<void> queryUserInfo() async;
  void onLogin();
  void onLogout();
}
```

## 5. 数据模型

### 5.1 用户信息

文件：`lib/models/member/info.dart`

```dart
class MemberInfoModel {
  int? mid;
  String? name;
  String? face;
  String? sign;
  int? level;
  Official? official;
  Vip? vip;
  int? following;
  int? follower;
}
```

### 5.2 用户状态

文件：`lib/models/user/stat.dart`

```dart
class UserStat {
  int? following;
  int? follower;
  int? dynamicCount;
}
```

## 6. API 依赖

### 6.1 获取用户信息

```
GET /x/space/acc/info
```

参数：
- `mid`：用户 ID

### 6.2 获取用户状态

```
GET /x/relation/stat
```

参数：
- `vmid`：用户 ID

### 6.3 关注用户

```
POST /x/relation/modify
```

参数：
- `fid`：用户 ID
- `act`：1=关注，2=取消关注
- `csrf`：CSRF Token

### 6.4 获取用户投稿

```
GET /x/space/arc/search
```

参数：
- `mid`：用户 ID
- `pn`：页码
- `ps`：每页数量

## 7. 状态管理

### 7.1 用户中心状态

```
[初始状态]
    │
    ├── queryMemberInfo()
    │   ├── 请求 API
    │   └── 成功 → memberInfo = data
    │
    ├── queryFollowStatus()
    │   └── 成功 → isFollowed = data
    │
    ├── followUser()
    │   ├── act = isFollowed ? 2 : 1
    │   ├── 请求 API
    │   └── 成功 → isFollowed = !isFollowed
    │
    └── queryArchiveList()
        ├── 请求 API
        └── 成功 → archiveList = data
```

## 8. 注意事项

- 用户中心支持查看自己的信息（MinePage）和其他用户的信息（MemberPage）
- 关注/取消关注需要登录状态
- 用户投稿支持分页加载
- 支持查看用户的各种互动记录（投币、喜欢等）
- 用户头像支持点击进入大图

## 9. 迁移状态

- ✅ 旧代码功能完成
- ✅ 三层架构迁移（UserRepository + UseCases + UserController）
- ✅ MemberPage + 4 widgets 迁移到 `lib/features/user/presentation/`
- ✅ 路由注册（`/member`）
- ✅ 模型字段修正（owner/pic 等）
- ✅ coins/likes/seasons widget 接入 MemberPage
- ✅ CSRF token 实现（统一使用 Request.getCsrf()）
- ⬜ member 子页面迁移（投稿、专栏、动态、关注/粉丝等）
- ⬜ 依赖注入注册
- ⬜ 单元测试
