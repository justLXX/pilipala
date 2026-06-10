# 直播功能规格书

## 1. 功能描述

直播页面展示 Bilibili 上的直播列表，支持查看正在直播的 UP 主，进入直播间观看直播。

## 2. 用户流程

```
用户进入直播页面
    │
    ├── 加载直播列表
    │   ├── 显示骨架屏
    │   ├── 请求 API 获取直播数据
    │   └── 渲染直播卡片列表
    │
    ├── 浏览直播
    │   ├── 上下滑动浏览
    │   └── 上拉加载更多
    │
    └── 点击直播
        └── 跳转到直播间
            ├── 加载直播流
            ├── 显示弹幕
            ├── 发送弹幕
            └── 关注主播
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 直播页 | `/` (Tab) | `lib/pages/live/view.dart` | 直播列表页面 |
| 直播间 | `/liveRoom` | `lib/pages/live_room/view.dart` | 直播间详情页面 |

## 4. Controller 职责

### 4.1 LiveController

文件：`lib/pages/live/controller.dart`

职责：
- 管理直播列表
- 实现分页加载

```dart
class LiveController extends GetxController {
  RxList<LiveItemModel> liveList = <LiveItemModel>[].obs;
  RxBool isLoading = false.obs;
  int currentPage = 1;
  
  Future<void> queryLiveList() async;
  Future<void> onLoad() async;
}
```

### 4.2 LiveRoomController

文件：`lib/pages/live_room/controller.dart`

职责：
- 管理直播间信息
- 管理直播流
- 管理弹幕

```dart
class LiveRoomController extends GetxController {
  Rx<LiveRoomInfo> roomInfo = LiveRoomInfo().obs;
  RxString playUrl = ''.obs;
  RxList<DanmakuItem> danmakuList = <DanmakuItem>[].obs;
  RxBool isFollowed = false.obs;
  
  Future<void> queryRoomInfo(int roomId) async;
  Future<void> queryPlayUrl(int roomId, int qn) async;
  Future<void> sendDanmaku(String msg) async;
  Future<void> followAnchor() async;
}
```

## 5. 数据模型

### 5.1 直播项

文件：`lib/models/live/item.dart`

```dart
class LiveItemModel {
  int? roomid;
  int? uid;
  String? title;
  String? uname;
  String? face;
  int? online;
  String? cover;
  int? areaId;
  String? areaName;
}
```

### 5.2 直播间信息

文件：`lib/models/live/room_info.dart`

```dart
class LiveRoomInfo {
  int? roomId;
  int? uid;
  String? title;
  String? uname;
  String? face;
  int? online;
  String? description;
  int? areaId;
  String? areaName;
  int? parentAreaId;
  String? parentAreaName;
}
```

## 6. API 依赖

### 6.1 获取直播列表

```
GET https://api.live.bilibili.com/room/v1/Area/getList
```

参数：
- `page`：页码
- `page_size`：每页数量
- `platform`：平台

### 6.2 获取直播间信息

```
GET https://api.live.bilibili.com/xlive/web-room/v1/index/getInfoByRoom
```

参数：
- `room_id`：房间 ID

### 6.3 获取直播流地址

```
GET https://api.live.bilibili.com/xlive/web-room/v1/playUrl/playUrl
```

参数：
- `cid`：房间 ID
- `qn`：清晰度
- `platform`：平台

## 7. 状态管理

### 7.1 直播状态

```
[初始状态]
    │
    ├── queryLiveList()
    │   ├── isLoading = true
    │   ├── 请求 API
    │   └── 成功 → liveList = data
    │       └── isLoading = false
    │
    ├── onLoad()
    │   ├── currentPage++
    │   ├── 请求 API
    │   └── 成功 → liveList.addAll(data)
    │
    └── 点击直播
        ├── queryRoomInfo(roomId)
        ├── queryPlayUrl(roomId, qn)
        └── 进入直播间
```

## 8. 注意事项

- 直播列表支持分页加载
- 直播间支持多种清晰度切换
- 弹幕使用 WebSocket 连接
- 直播流使用 HLS 或 FLV 格式
- 支持后台播放（音频模式）
