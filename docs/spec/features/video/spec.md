# 视频详情功能规格书

## 1. 功能描述

视频详情页是用户观看视频的核心页面，包含视频播放、视频信息展示、评论列表、相关推荐等功能。

## 2. 用户流程

```
用户点击视频
    │
    ├── 加载视频详情
    │   ├── 显示骨架屏
    │   ├── 请求视频详情 API
    │   ├── 请求视频播放地址 API
    │   └── 渲染页面
    │
    ├── 视频播放
    │   ├── 点击播放/暂停
    │   ├── 双击快进/快退
    │   ├── 调节音量/亮度
    │   ├── 切换清晰度
    │   ├── 切换倍速
    │   └── 全屏播放
    │
    ├── 查看评论
    │   ├── 向上滑动查看评论
    │   ├── 发表评论
    │   ├── 点赞评论
    │   └── 回复评论
    │
    ├── 查看相关推荐
    │   └── 向上滑动查看推荐视频
    │
    └── 操作菜单
        ├── 点赞视频
        ├── 投币
        ├── 收藏
        ├── 分享
        ├── 稍后再看
        └── 下载封面
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 视频详情 | `/video` | `lib/pages/video/detail/view.dart` | 视频详情主页面 |
| 评论回复 | `/replyReply` | `lib/pages/video/detail/reply_reply/view.dart` | 二级评论页面 |

## 4. Controller 职责

### 4.1 VideoDetailController

文件：`lib/pages/video/detail/controller.dart`

职责：
- 管理视频播放状态
- 获取视频详情和播放地址
- 管理评论列表
- 处理用户操作（点赞、投币、收藏等）

```dart
class VideoDetailController extends GetxController {
  // 视频信息
  Rx<VideoDetailData> videoDetail = VideoDetailData().obs;
  Rx<PlayUrlModel> playUrl = PlayUrlModel().obs;
  
  // 播放状态
  RxBool isPlaying = false.obs;
  RxBool isFullScreen = false.obs;
  
  // 评论
  RxList<ReplyItem> replyList = <ReplyItem>[].obs;
  RxBool isReplyLoading = false.obs;
  
  // 操作状态
  RxBool isLiked = false.obs;
  RxBool isCollected = false.obs;
  
  Future<void> queryVideoDetail(String bvid) async;
  Future<void> queryPlayUrl(int cid) async;
  Future<void> queryReplyList(int oid) async;
  Future<void> likeVideo() async;
  Future<void> coinVideo() async;
  Future<void> collectVideo() async;
}
```

## 5. 数据模型

### 5.1 视频详情

文件：`lib/models/video_detail_res.dart`

```dart
class VideoDetailResponse {
  int? code;
  String? message;
  int? ttl;
  VideoDetailData? data;
}

class VideoDetailData {
  String? bvid;
  int? aid;
  int? cid;
  String? title;
  String? desc;
  Owner? owner;
  Stat? stat;
  List<VideoPage>? pages;
  // ...
}
```

### 5.2 播放地址

文件：`lib/models/video/play/url.dart`

```dart
class PlayUrlModel {
  int? code;
  String? message;
  PlayUrlData? data;
}

class PlayUrlData {
  List<Dash>? dash;
  List<Flv>? durl;
  // ...
}
```

## 6. API 依赖

### 6.1 获取视频详情

```
GET /x/web-interface/view
```

参数：
- `bvid` 或 `aid`：视频 ID

### 6.2 获取视频播放地址

```
GET /x/player/wbi/playurl
```

参数：
- `avid`：视频 AV 号
- `cid`：视频 CID
- `qn`：视频质量
- `fnval`：视频格式

### 6.3 获取评论列表

```
GET /x/v2/reply
```

参数：
- `oid`：对象 ID
- `type`：对象类型（1=视频）
- `pn`：页码
- `sort`：排序方式

### 6.4 点赞视频

```
POST /x/web-interface/archive/like
```

参数：
- `aid` 或 `bvid`：视频 ID
- `like`：1=点赞，2=取消
- `csrf`：CSRF Token

## 7. 状态管理

### 7.1 视频播放状态

```
[初始状态]
    │
    ├── queryVideoDetail(bvid)
    │   ├── 成功 → videoDetail = data
    │   └── 请求 playUrl
    │       ├── 成功 → playUrl = data
    │       └── 开始播放
    │
    ├── 播放/暂停
    │   ├── 点击 → isPlaying = !isPlaying
    │   └── 更新 UI
    │
    ├── 全屏切换
    │   ├── 点击 → isFullScreen = !isFullScreen
    │   └── 更新 UI
    │
    └── 操作
        ├── likeVideo() → isLiked = !isLiked
        ├── coinVideo()
        └── collectVideo() → isCollected = !isCollected
```

## 8. 注意事项

- 视频播放器使用 media_kit 库
- 支持多种视频格式（MP4、FLV、DASH）
- 支持多种清晰度切换
- 支持后台播放（通过 audio_service）
- 评论列表支持按时间/热度排序
- 支持弹幕显示（通过 ns_danmaku）
- 视频详情页支持手势操作（滑动调节音量/亮度）

## 9. 迁移状态

- ✅ 旧代码功能完成
- ✅ 三层架构迁移（VideoDetailRepository + UseCases + VideoDetailController）
- ✅ VideoDetailPage 迁移到 `lib/features/video/presentation/`
- ✅ 路由注册（`/video`）
- ✅ 模型类型修正（PlayUrlModel、Api.favVideo）
- ✅ CSRF token 实现（统一使用 Request.getCsrf()）
- ✅ 点赞/收藏 API 调用（LikeVideoUseCase、CollectVideoUseCase）
- ⬜ 视频播放器集成（media_kit）
- ⬜ 评论列表 UI 展示
- ⬜ 依赖注入注册
- ⬜ 单元测试
