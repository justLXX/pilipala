# 搜索功能规格书

## 1. 功能描述

搜索功能允许用户通过关键词搜索 Bilibili 上的视频、番剧、直播间、用户和专栏内容。支持热搜展示、搜索建议、历史记录和搜索结果展示。

## 2. 用户流程

```
用户进入搜索页面
    │
    ├── 查看热搜
    │   ├── 展示热搜列表
    │   └── 点击热搜直接搜索
    │
    ├── 输入关键词
    │   ├── 实时显示搜索建议
    │   └── 点击建议直接搜索
    │
    ├── 查看搜索历史
    │   ├── 展示历史搜索记录
    │   ├── 点击历史记录直接搜索
    │   └── 清空历史记录
    │
    └── 执行搜索
        ├── 选择搜索类型（视频/番剧/直播间/用户/专栏）
        ├── 展示搜索结果
        ├── 切换排序方式
        └── 点击结果进入详情
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 搜索页 | `/search` | `lib/pages/search/view.dart` | 搜索主页面（热搜、建议、历史） |
| 搜索结果页 | `/searchResult` | `lib/pages/search_result/view.dart` | 搜索结果展示 |
| 搜索面板 | - | `lib/pages/search_panel/view.dart` | 搜索输入面板 |

## 4. Controller 职责

### 4.1 SearchController

文件：`lib/pages/search/controller.dart`

职责：
- 管理搜索关键词
- 获取热搜列表
- 获取搜索建议
- 管理搜索历史

```dart
class SearchController extends GetxController {
  RxString keyword = ''.obs;
  RxList<HotSearchItem> hotSearchList = <HotSearchItem>[].obs;
  RxList<String> suggestList = <String>[].obs;
  RxList<String> historyList = <String>[].obs;
  
  Future<void> queryHotSearch() async;
  Future<void> querySuggest(String keyword) async;
  Future<void> addHistory(String keyword) async;
  Future<void> clearHistory() async;
}
```

### 4.2 SearchResultController

文件：`lib/pages/search_result/controller.dart`

职责：
- 管理搜索结果
- 处理搜索类型切换
- 处理排序方式切换
- 实现分页加载

```dart
class SearchResultController extends GetxController {
  RxString keyword = ''.obs;
  Rx<SearchType> searchType = SearchType.video.obs;
  RxList<dynamic> resultList = <dynamic>[].obs;
  RxBool isLoading = false.obs;
  int currentPage = 1;
  
  Future<void> querySearchResult() async;
  Future<void> onLoad() async;
  void changeSearchType(SearchType type);
  void changeSortType(String sort);
}
```

## 5. 数据模型

### 5.1 热搜项

文件：`lib/models/search/hot.dart`

```dart
class HotSearchModel {
  List<HotSearchItem>? list;
}

class HotSearchItem {
  String? keyword;
  int? showName;
  int? icon;
  int? rank;
}
```

### 5.2 搜索类型

文件：`lib/models/common/search_type.dart`

```dart
enum SearchType {
  video,
  media_bangumi,
  live_room,
  bili_user,
  article,
}
```

### 5.3 搜索结果

文件：`lib/models/search/result.dart`

```dart
class SearchResultModel {
  int? numResults;
  int? numPages;
  List<SearchResultItem>? result;
}
```

## 6. API 依赖

### 6.1 获取热搜列表

```
GET /x/web-interface/search/square
```

### 6.2 获取搜索建议

```
GET https://s.search.bilibili.com/main/suggest
```

参数：
- `term`：搜索关键词

### 6.3 搜索结果

```
GET /x/web-interface/wbi/search/all/v2
```

参数：
- `keyword`：搜索关键词
- `page`：页码
- `pagesize`：每页数量
- `search_type`：搜索类型
- `order`：排序方式

## 7. 状态管理

### 7.1 搜索流程状态

```
[初始状态]
    │
    ├── 显示热搜 + 历史记录
    │
    ├── 输入关键词
    │   ├── 触发 querySuggest(keyword)
    │   └── 显示建议列表
    │
    ├── 点击热搜/建议/历史
    │   └── 跳转到搜索结果页
    │       ├── keyword = 关键词
    │       ├── querySearchResult()
    │       └── 显示结果
    │
    └── 切换搜索类型
        ├── searchType = 新类型
        ├── currentPage = 1
        └── querySearchResult()
```

## 8. 注意事项

- 搜索历史存储在 Hive 的 `historyWord` Box 中
- 热搜列表每次进入搜索页刷新
- 搜索建议需要防抖处理（避免频繁请求）
- 支持按搜索类型过滤结果
- 支持按排序方式排序（综合/播放多/新发布/弹幕多/收藏多）
- 搜索结果支持分页加载

## 9. 迁移状态

- ✅ 旧代码功能完成
- ✅ 三层架构迁移（SearchRepository + UseCases + PiliSearchController）
- ✅ SearchPage + widgets 迁移到 `lib/features/search/presentation/`
- ✅ 路由注册（`/search`）
- ✅ 类名重命名为 `PiliSearchController`（避免与 Flutter 内置冲突）
- ✅ 搜索结果 UI 展示（SearchResultsWidget）
- ⬜ 搜索分类（视频/番剧/用户等）
- ⬜ 依赖注入注册
- ⬜ 单元测试
