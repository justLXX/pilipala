# 媒体库功能规格书

## 1. 功能描述

媒体库页面展示用户的个人媒体内容，包括稍后再看、历史记录、收藏夹等。方便用户管理和回顾自己的媒体内容。

## 2. 用户流程

```
用户进入媒体库页面
    │
    ├── 查看媒体库列表
    │   ├── 稍后再看
    │   ├── 历史记录
    │   └── 收藏夹
    │
    ├── 管理稍后再看
    │   ├── 查看列表
    │   ├── 播放视频
    │   └── 删除视频
    │
    ├── 管理历史记录
    │   ├── 查看历史
    │   ├── 搜索历史
    │   └── 删除记录
    │
    └── 管理收藏夹
        ├── 查看收藏夹列表
        ├── 查看收藏夹内容
        ├── 创建收藏夹
        ├── 编辑收藏夹
        └── 删除收藏夹
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 媒体库 | `/media` | `lib/pages/media/view.dart` | 媒体库主页面（Tab） |
| 稍后再看 | `/later` | `lib/pages/later/view.dart` | 稍后再看列表 |
| 历史记录 | `/history` | `lib/pages/history/view.dart` | 历史记录列表 |
| 历史搜索 | `/historySearch` | `lib/pages/history_search/view.dart` | 历史记录搜索 |
| 收藏 | `/fav` | `lib/pages/fav/view.dart` | 收藏夹列表 |
| 收藏详情 | `/favDetail` | `lib/pages/fav_detail/view.dart` | 收藏夹详情 |
| 收藏搜索 | `/favSearch` | `lib/pages/fav_search/view.dart` | 收藏夹搜索 |
| 收藏编辑 | `/favEdit` | `lib/pages/fav_edit/view.dart` | 编辑收藏夹 |

## 4. Controller 职责

### 4.1 LaterController

文件：`lib/pages/later/controller.dart`

职责：
- 管理稍后再看列表
- 实现删除功能

```dart
class LaterController extends GetxController {
  RxList<HotVideoItemModel> laterList = <HotVideoItemModel>[].obs;
  RxBool isLoading = false.obs;
  int count = 0;
  
  Future<void> queryLaterList() async;
  Future<void> deleteLaterItem(int aid) async;
}
```

### 4.2 HistoryController

文件：`lib/pages/history/controller.dart`

职责：
- 管理历史记录列表
- 实现搜索功能

```dart
class HistoryController extends GetxController {
  RxList<HistoryItem> historyList = <HistoryItem>[].obs;
  RxBool isLoading = false.obs;
  
  Future<void> queryHistoryList() async;
  Future<void> searchHistory(String keyword) async;
  Future<void> deleteHistory(int aid) async;
}
```

### 4.3 FavController

文件：`lib/pages/fav/controller.dart`

职责：
- 管理收藏夹列表
- 管理收藏夹内容

```dart
class FavController extends GetxController {
  RxList<FavFolder> favList = <FavFolder>[].obs;
  RxList<VideoItem> favDetailList = <VideoItem>[].obs;
  
  Future<void> queryFavList() async;
  Future<void> queryFavDetail(int mediaId) async;
  Future<void> createFavFolder(String title, String intro) async;
  Future<void> editFavFolder(String mediaId, String title, String intro) async;
  Future<void> deleteFavFolder(String mediaId) async;
}
```

## 5. 数据模型

### 5.1 稍后再看项

文件：`lib/models/video/later.dart`

```dart
class MediaVideoItemModel {
  int? id;
  int? aid;
  String? title;
  String? cover;
  int? duration;
  Owner? upper;
  String? bvid;
}
```

### 5.2 历史记录项

文件：`lib/models/user/history.dart`

```dart
class HistoryItem {
  int? aid;
  String? title;
  String? cover;
  int? progress;
  int? duration;
  int? viewAt;
  Owner? owner;
}
```

### 5.3 收藏夹

文件：`lib/models/user/fav_folder.dart`

```dart
class FavFolder {
  int? id;
  int? mediaId;
  String? title;
  String? intro;
  int? mediaCount;
  String? cover;
}
```

## 6. API 依赖

### 6.1 获取稍后再看

```
GET /x/v2/history/toview
```

### 6.2 获取历史记录

```
GET /x/v2/history
```

参数：
- `max`：最大 ID
- `view_at`：查看时间
- `business`：业务类型

### 6.3 获取收藏夹列表

```
GET /x/v3/fav/folder/list
```

参数：
- `up_mid`：用户 ID
- `pn`：页码
- `ps`：每页数量

### 6.4 获取收藏夹内容

```
GET /x/v3/fav/resource/list
```

参数：
- `media_id`：收藏夹 ID
- `pn`：页码
- `ps`：每页数量

## 7. 状态管理

### 7.1 媒体库状态

```
[初始状态]
    │
    ├── queryLaterList()
    │   ├── isLoading = true
    │   ├── 请求 API
    │   └── 成功 → laterList = data
    │       └── count = data.length
    │
    ├── queryHistoryList()
    │   ├── 请求 API
    │   └── 成功 → historyList = data
    │
    └── queryFavList()
        ├── 请求 API
        └── 成功 → favList = data
```

## 8. 注意事项

- 稍后再看和历史记录需要登录状态
- 收藏夹支持多级目录（文件夹）
- 历史记录支持搜索功能
- 收藏夹支持创建、编辑、删除
- 删除操作需要确认对话框

## 9. 迁移状态

- [x] 旧代码功能完成
- [x] 三层架构迁移（MediaRepository + UseCases + MediaController + MediaPage）
- [x] 模型类型修正（HisListItem、FavFolderItemData、FavDetailItemData）
- [x] API 端点修正（seeYouLater、toViewLater、toViewDel、userFavFolderDetail）
- [ ] 收藏 tab 实现（当前空实现）
- [ ] 子路由注册（稍后再看/历史/收藏页面）
- [ ] 底部导航栏切换
- [ ] 依赖注入注册
- [ ] CSRF token 实现
