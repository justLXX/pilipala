# 动态功能规格书

## 1. 功能描述

动态页面展示用户关注的 UP 主的最新动态，包括视频投稿、专栏、转发等。支持按类型筛选（全部、投稿、番剧、专栏）。

## 2. 用户流程

```
用户进入动态页面
    │
    ├── 加载关注动态
    │   ├── 显示骨架屏
    │   ├── 请求 API 获取动态数据
    │   └── 渲染动态卡片列表
    │
    ├── 浏览动态
    │   ├── 上下滑动浏览
    │   ├── 上拉加载更多
    │   └── 下拉刷新
    │
    ├── 切换动态类型（可选）
    │   ├── 全部 / 投稿 / 番剧 / 专栏
    │   └── 重新加载对应类型数据
    │
    ├── 点击动态
    │   ├── 视频动态 → 视频详情
    │   ├── 专栏动态 → 专栏详情
    │   └── 转发动态 → 原动态详情
    │
    └── 点击用户头像
        └── 跳转到用户中心
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 动态页 | `/dynamics` | `lib/pages/dynamics/view.dart` | 动态列表主页面 |
| 动态详情 | `/dynamicDetail` | `lib/pages/dynamics/detail/view.dart` | 动态详情页面 |

## 4. Controller 职责

### 4.1 DynamicsController

文件：`lib/pages/dynamics/controller.dart`

职责：
- 管理动态列表
- 处理动态类型切换
- 实现下拉刷新和上拉加载

```dart
class DynamicsController extends GetxController {
  RxList<DynamicItemModel> dynamicList = <DynamicItemModel>[].obs;
  Rx<DynamicsType> currentType = DynamicsType.all.obs;
  String? offset;
  bool isLoadingMore = false;
  
  Future<void> queryDynamicList() async;
  Future<void> onRefresh() async;
  Future<void> onLoad() async;
  void changeType(DynamicsType type);
}
```

## 5. 数据模型

### 5.1 动态数据

文件：`lib/models/dynamics/result.dart`

```dart
class DynamicsDataModel {
  bool? hasMore;
  List<DynamicItemModel>? items;
  String? offset;
}

class DynamicItemModel {
  DynamicBasic? basic;
  String? idStr;
  DynamicModules? modules;
  DynamicItemModel? orig; // 转发原动态
}
```

### 5.2 动态类型

文件：`lib/models/common/dynamics_type.dart`

```dart
enum DynamicsType {
  all,      // 全部
  video,    // 投稿
  pgc,      // 番剧
  article,  // 专栏
}
```

## 6. API 依赖

### 6.1 获取关注动态

```
GET https://api.vc.bilibili.com/dynamic_svr/v1/dynamic_svr/dynamic_new
```

参数：
- `type`：动态类型（all/video/pgc/article）
- `page`：页码
- `offset`：偏移量

### 6.2 获取未读动态数

```
GET /x/dynamic/feed/attach_card/list
```

## 7. 状态管理

### 7.1 动态列表状态

```
[初始状态]
    │
    ├── queryDynamicList()
    │   ├── isLoadingMore = true
    │   ├── 请求 API
    │   └── 成功 → dynamicList = data.items
    │       └── isLoadingMore = false
    │
    ├── onRefresh()
    │   ├── offset = null
    │   ├── 请求 API
    │   └── 成功 → dynamicList = data.items
    │
    └── onLoad()
        ├── offset = data.offset
        ├── 请求 API
        └── 成功 → dynamicList.addAll(data.items)
```

## 8. 注意事项

- 动态列表使用 offset 分页（非页码）
- 支持转发动态展示（展示原动态信息）
- 不同类型的动态展示方式不同
- 动态卡片支持长按操作
- 关注用户头像支持点击进入用户中心
