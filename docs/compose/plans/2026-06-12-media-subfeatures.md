# Media 子功能完善计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 fav/history/later 子页面从 pages/ 迁移到 features/media/presentation/

**Architecture:** 采用 data/domain/presentation 三层架构，复用现有 MediaRepository 和 UseCases

**Tech Stack:** Flutter, GetX, Hive

---

## 当前状态

| 组件 | 状态 | 说明 |
|------|------|------|
| media_repository.dart | ✅ 完整 | 支持 watchLater/history/fav |
| media_use_cases.dart | ✅ 完整 | 6个UseCase已实现 |
| media_controller.dart | ✅ 完整 | 支持所有操作 |
| media_page.dart | ⚠️ 部分 | 主页面存在，子页面路由指向 pages/ |

## 待迁移子页面

| 页面 | 旧路径 | 新路径 | 复杂度 |
|------|--------|--------|--------|
| 收藏列表 | `pages/fav/` | `features/media/presentation/fav/` | 中 |
| 观看历史 | `pages/history/` | `features/media/presentation/history/` | 中 |
| 稍后再看 | `pages/later/` | `features/media/presentation/later/` | 小 |

---

## Task 1: 迁移收藏列表页面

**Covers:** fav 子功能

**Files:**
- Create: `lib/features/media/presentation/fav/fav_page.dart`
- Create: `lib/features/media/presentation/fav/fav_controller.dart`
- Create: `lib/features/media/presentation/fav/widgets/fav_item.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 FavController**

```dart
// lib/features/media/presentation/fav/fav_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/utils/storage.dart';

class FavController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  RxList<FavFolderItemData> favFolderList = <FavFolderItemData>[].obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;
  int currentPage = 1;
  int pageSize = 60;
  RxBool hasMore = true.obs;
  late int mid;
  late int ownerMid;
  RxBool isOwner = false.obs;

  late final GetFavFoldersUseCase _getFavFolders;

  FavController({GetFavFoldersUseCase? getFavFolders})
      : _getFavFolders = getFavFolders ?? GetFavFoldersUseCase();

  @override
  void onInit() {
    mid = int.parse(Get.parameters['mid'] ?? '-1');
    userInfo = userInfoCache.get('userInfoCache');
    ownerMid = userInfo != null ? userInfo!.mid! : -1;
    isOwner.value = mid == -1 || mid == ownerMid;
    super.onInit();
  }

  Future<dynamic> queryFavFolder({type = 'init'}) async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    if (!hasMore.value) {
      return;
    }
    
    final userId = isOwner.value ? ownerMid : mid;
    try {
      final list = await _getFavFolders.execute(
        mid: userId,
        page: currentPage,
        pageSize: pageSize,
      );
      
      if (type == 'init') {
        favFolderData.value = FavFolderData(list: list, count: list.length);
        favFolderList.value = list;
      } else {
        if (list.isNotEmpty) {
          favFolderList.addAll(list);
          favFolderData.update((val) {});
        }
      }
      hasMore.value = list.length == pageSize;
      currentPage++;
      return {'status': true, 'data': favFolderData.value, 'msg': ''};
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future onLoad() async {
    queryFavFolder(type: 'onload');
  }

  removeFavFolder({required int mediaIds}) async {
    for (var i in favFolderList) {
      if (i.id == mediaIds) {
        favFolderList.remove(i);
        break;
      }
    }
  }
}
```

- [ ] **Step 2: 创建 FavItem widget**

从 `pages/fav/widgets/item.dart` 复制并适配。

- [ ] **Step 3: 创建 FavPage**

从 `pages/fav/view.dart` 复制并适配 imports。

- [ ] **Step 4: 更新路由**

在 `app_pages.dart` 中将 `/fav` 指向新的 features 页面。

---

## Task 2: 迁移观看历史页面

**Covers:** history 子功能

**Files:**
- Create: `lib/features/media/presentation/history/history_page.dart`
- Create: `lib/features/media/presentation/history/history_controller.dart`
- Create: `lib/features/media/presentation/history/widgets/history_item.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 HistoryController**

需要补充以下 UseCase 到 `media_use_cases.dart`:
- `PauseHistoryUseCase`
- `ClearHistoryUseCase`
- `DeleteHistoryUseCase`
- `GetHistoryStatusUseCase`

- [ ] **Step 2: 创建 HistoryItem widget**

从 `pages/history/widgets/` 复制并适配。

- [ ] **Step 3: 创建 HistoryPage**

从 `pages/history/view.dart` 复制并适配 imports。

- [ ] **Step 4: 更新路由**

在 `app_pages.dart` 中将 `/history` 指向新的 features 页面。

---

## Task 3: 迁移稍后再看页面

**Covers:** later 子功能

**Files:**
- Create: `lib/features/media/presentation/later/later_page.dart`
- Create: `lib/features/media/presentation/later/later_controller.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 LaterController**

复用现有 `MediaController` 的 `loadWatchLater()` 和 `removeFromWatchLater()` 方法。

- [ ] **Step 2: 创建 LaterPage**

从 `pages/later/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/later` 指向新的 features 页面。

---

## Task 4: 补充缺失的 UseCase

**Covers:** history 操作

**Files:**
- Modify: `lib/features/media/domain/media_use_cases.dart`
- Modify: `lib/features/media/data/media_repository.dart`

- [ ] **Step 1: 添加 History 相关 API 到 MediaRepository**

```dart
/// Pause/resume history.
Future<ApiResponse<void>> pauseHistory({required bool pause}) async {
  final response = await _apiClient.post<Map<String, dynamic>>(
    Api.pauseHistory,
    data: {
      'pause': pause,
      'csrf': await _getCsrf(),
    },
  );
  return response;
}

/// Get history pause status.
Future<ApiResponse<bool>> getHistoryStatus() async {
  final response = await _apiClient.get<Map<String, dynamic>>(
    Api.historyStatus,
  );
  if (response.isSuccess && response.data != null) {
    return ApiResponse.success(response.data!['data'] as bool);
  }
  return ApiResponse.error(msg: response.msg);
}

/// Clear all history.
Future<ApiResponse<void>> clearHistory() async {
  final response = await _apiClient.post<Map<String, dynamic>>(
    Api.clearHistory,
    data: {
      'csrf': await _getCsrf(),
    },
  );
  return response;
}

/// Delete single history item.
Future<ApiResponse<void>> deleteHistory({required String kid}) async {
  final response = await _apiClient.post<Map<String, dynamic>>(
    Api.delHistory,
    data: {
      'kid': kid,
      'csrf': await _getCsrf(),
    },
  );
  return response;
}
```

- [ ] **Step 2: 添加对应的 UseCase**

---

## Task 5: 验证和测试

**Covers:** 完整性验证

- [ ] **Step 1: 运行 flutter analyze**

```bash
cd /Users/liyuan/workspace/pilipala && flutter analyze lib/features/media
```

- [ ] **Step 2: 验证路由注册**

确认 `/fav`, `/history`, `/later` 路由指向新页面。

- [ ] **Step 3: 验证 DI 绑定**

确认 MediaBinding 包含所有新增的 UseCase。

---

## 完成标准

- [ ] 所有子页面已迁移到 features/media/presentation/
- [ ] 路由已更新
- [ ] DI 绑定已更新
- [ ] flutter analyze 无 errors
