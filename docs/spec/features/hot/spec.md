# 热门排行功能规格书

## 1. 功能描述

热门排行页面展示 Bilibili 上的热门视频列表，支持按不同分区筛选（动画、音乐、游戏等），以及全站排行榜。

## 2. 用户流程

```
用户进入热门/排行页面
    │
    ├── 加载热门视频列表
    │   ├── 显示骨架屏
    │   ├── 请求 API 获取热门数据
    │   └── 渲染视频卡片列表
    │
    ├── 浏览视频
    │   ├── 上下滑动浏览
    │   ├── 上拉加载更多
    │   └── 下拉刷新
    │
    ├── 切换分区（可选）
    │   ├── 选择分区 Tab
    │   └── 重新加载对应分区数据
    │
    └── 点击视频
        └── 跳转到视频详情页
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 状态 | 说明 |
|------|------|------|------|------|
| 热门页 | `/hot` | `lib/features/home/presentation/hot_page.dart` | ✅ 已迁移 | 使用 HomeController |
| 排行榜页 | `/rank` | `lib/pages/rank/view.dart` | ❌ 未迁移 | 全站排行榜 |
| 分区排行 | `/rank` (Tab) | `lib/pages/rank/zone/view.dart` | ❌ 未迁移 | 分区排行榜 |

## 4. Controller 职责

### 4.1 HomeController（已迁移）

文件：`lib/features/home/presentation/home_controller.dart`

热门视频功能已合并到 HomeController 中，与推荐视频共用同一个 Controller。

```dart
class HomeController extends GetxController {
  // 热门相关方法
  Future<void> loadHotVideos() async;
  Future<void> refreshHotVideos() async;
  Future<void> loadMoreHot() async;
  
  // 热门相关状态
  List<HotVideoItemModel> get hotVideoList;
  bool get isHotLoading;
  bool get isHotLoadingMore;
  String get hotError;
}
```

> **旧代码**：`lib/pages/hot/controller.dart` 中的 `HotController` 仍存在但未使用。

### 4.2 RankController

文件：`lib/pages/rank/controller.dart`

职责：
- 管理排行榜数据
- 处理分区切换

```dart
class RankController extends GetxController {
  RxList<HotVideoItemModel> rankList = <HotVideoItemModel>[].obs;
  RxInt currentRid = 0.obs; // 0=全站
  
  Future<void> queryRankList() async;
  void changeRankType(int rid);
}
```

## 5. 数据模型

### 5.1 热门视频项

文件：`lib/models/model_hot_video_item.dart`

```dart
class HotVideoItemModel {
  int? aid;
  int? cid;
  String? bvid;
  String? title;
  String? pic;
  int? duration;
  Owner? owner;
  Stat? stat;
  String? rcmdReason;
}
```

### 5.2 排行榜类型

文件：`lib/models/common/rank_type.dart`

```dart
enum RandType {
  all,        // 全站
  animation,  // 动画
  music,      // 音乐
  dance,      // 舞蹈
  game,       // 游戏
  knowledge,  // 知识
  technology, // 科技
  sport,      // 运动
  car,        // 汽车
  food,       // 美食
  animal,     // 动物圈
  madness,    // 鬼畜
  fashion,    // 时尚
  entertainment, // 娱乐
  film,       // 影视
}
```

## 6. API 依赖

### 6.1 获取热门视频

```
GET /x/web-interface/popular
```

参数：
- `pn`：页码
- `ps`：每页数量

### 6.2 获取排行榜

```
GET /x/web-interface/ranking/v2
```

参数：
- `rid`：分区 ID（0=全站）
- `type`：排行类型（all=全站）

## 7. 状态管理

### 7.1 热门视频状态

```
[初始状态]
    │
    ├── queryHotFeed('init')
    │   ├── isLoadingMore = true
    │   ├── 请求 API
    │   └── 成功 → videoList = data
    │       └── isLoadingMore = false
    │
    ├── onRefresh()
    │   ├── 重置 _currentPage = 1
    │   ├── 请求 API
    │   └── 成功 → videoList.insertAll(0, data)
    │
    └── onLoad()
        ├── _currentPage++
        ├── 请求 API
        └── 成功 → videoList.addAll(data)
```

## 8. 注意事项

- 热门视频和排行榜使用相同的数据模型
- 排行榜分区 ID 对应不同的 rid 值
- 热门视频支持分页加载
- 排行榜通常只显示固定数量（如 100 条）
- 视频卡片支持横向和纵向两种布局

## 9. 开发状态

- [x] 功能开发完成（旧代码）
- [x] 热门页迁移到 features/home/（HotPage + HomeController）
- [ ] 排行榜迁移到 features/home/（RankPage + RankController + ZoneController）
- [ ] 依赖注入注册（VideoRepository、UseCase、Controller）
- [ ] 单元测试
