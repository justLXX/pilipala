# 首页推荐功能规格书

## 1. 功能描述

首页推荐是用户打开 App 后看到的第一个页面，展示基于用户兴趣的推荐视频流。支持 Web 端和 App 端两种推荐模式，以及未登录模式。

## 2. 用户流程

```
用户打开 App
    │
    ├── 加载推荐视频列表
    │   ├── 显示骨架屏
    │   ├── 请求 API 获取推荐数据
    │   └── 渲染视频卡片列表
    │
    ├── 浏览视频
    │   ├── 上下滑动浏览
    │   ├── 上拉加载更多
    │   └── 下拉刷新
    │
    ├── 点击视频
    │   └── 跳转到视频详情页
    │
    └── 切换推荐类型（可选）
        └── Web/App/游客模式
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 首页 | `/` | `lib/pages/home/view.dart` | 包含 Tab 切换的主页面 |
| 推荐页 | `/` (Tab) | `lib/pages/rcmd/view.dart` | 推荐视频流页面 |

## 4. Controller 职责

### 4.1 RcmdController

文件：`lib/pages/rcmd/controller.dart`

职责：
- 管理推荐视频列表状态
- 处理推荐类型切换（Web/App/未登录）
- 实现下拉刷新和上拉加载
- 应用推荐过滤规则（时长、点赞率）

```dart
class RcmdController extends GetxController {
  RxList<RecVideoItemModel> videoList = <RecVideoItemModel>[].obs;
  RxBool isLoading = false.obs;
  String currentRcmdType = 'web'; // 'web' | 'app' | 'notLogin'
  
  Future<void> queryRcmdFeed(String type) async;
  Future<void> onRefresh() async;
  Future<void> onLoad() async;
}
```

## 5. 数据模型

### 5.1 推荐视频项

文件：`lib/models/model_rec_video_item.dart`

```dart
class RecVideoItemModel {
  int? id;
  String? bvid;
  int? cid;
  String? goto;
  String? uri;
  String? pic;
  String? title;
  int? duration;
  int? pubdate;
  Owner? owner;
  Stat? stat;
  bool? isFollowed;
  String? rcmdReason;
}
```

### 5.2 推荐类型

文件：`lib/models/common/rcmd_type.dart`

```dart
enum RcmdType { web, app, notLogin }
```

## 6. API 依赖

### 6.1 获取推荐视频（Web）

```
GET /x/web-interface/index/top/feed/rcmd
```

响应：`List<RecVideoItemModel>`

### 6.2 获取推荐视频（App）

```
GET https://app.bilibili.com/x/v2/feed/index
```

响应：`List<RecVideoItemModel>`

## 7. 状态管理

### 7.1 状态流转

```
[初始状态]
    │
    ├── queryRcmdFeed('init')
    │   ├── isLoading = true
    │   ├── 请求 API
    │   └── 成功 → videoList = data
    │       └── isLoading = false
    │       └── 失败 → errorMsg = msg
    │
    ├── onRefresh()
    │   ├── 请求 API
    │   └── 成功 → videoList.insertAll(0, data)
    │
    └── onLoad()
        ├── 请求 API
        └── 成功 → videoList.addAll(data)
```

### 7.2 推荐过滤

文件：`lib/utils/recommend_filter.dart`

根据用户设置过滤推荐视频：
- 最小时长过滤
- 最小点赞率过滤
- 已关注用户豁免过滤

## 8. 注意事项

- 推荐视频列表需要支持单列/双列布局切换
- 首次加载显示骨架屏
- 支持无限滚动加载
- 切换推荐类型时清空列表并重新加载
- 过滤规则在加载时实时应用

## 9. 迁移状态

- ✅ 旧代码功能完成
- ✅ 三层架构迁移（VideoRepository + UseCases + HomeController）
- ✅ HotPage、RcmdPage、HomePage 迁移到 `lib/features/home/presentation/`
- ✅ 路由注册（`/` `/hot`）
- ✅ CSRF token 实现（统一使用 Request.getCsrf()）
- ⬜ 底部导航栏切换（nav_bar_config 仍引用旧 pages/home/）
- ⬜ 依赖注入注册（Repository/UseCase/Controller 未注册到 GetX）
- ⬜ 推荐过滤逻辑（黑名单、时长、点赞率）
- ⬜ 单元测试
