# 状态管理规范

## 1. 概述

PiliPala 使用 **GetX** 作为统一的状态管理框架，同时负责路由管理和依赖注入。

## 2. GetX 核心概念

### 2.1 响应式状态

使用 `.obs` 将普通变量转换为响应式变量：

```dart
// Controller 中定义
class MyController extends GetxController {
  RxInt count = 0.obs;           // 响应式 int
  RxString title = ''.obs;       // 响应式 String
  RxList<Item> items = <Item>[].obs;  // 响应式 List
  RxBool isLoading = false.obs;  // 响应式 bool
  Rx<UserInfoData> userInfo = UserInfoData().obs;  // 响应式对象
}
```

### 2.2 状态监听

在 View 中使用 `Obx` 包裹需要自动更新的 Widget：

```dart
class MyPage extends StatelessWidget {
  final MyController controller = Get.put(MyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // 当 controller.items 变化时，自动重建
        return ListView.builder(
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(controller.items[index].title));
          },
        );
      }),
    );
  }
}
```

### 2.3 状态更新方式

| 方式 | 用法 | 场景 |
|------|------|------|
| `.value = ...` | `count.value = 5` | 更新单个值 |
| `.add()` / `.remove()` | `items.add(newItem)` | 修改 List |
| `.refresh()` | `items.refresh()` | 触发重建（内部值未变但引用未变） |
| `update()` | `update()` | 手动触发 GetBuilder 更新 |

## 3. Controller 规范

### 3.1 Controller 生命周期

```dart
class MyController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // 初始化逻辑：加载数据、设置监听器
  }

  @override
  void onReady() {
    super.onReady();
    // 首次渲染完成后执行
  }

  @override
  void onClose() {
    // 清理资源：取消订阅、关闭 Stream、释放控制器
    super.onClose();
  }
}
```

### 3.2 Controller 职责

一个 Controller 应该：
- ✅ 管理页面状态（加载中、错误、空数据、有数据）
- ✅ 处理用户交互（点击、下拉刷新、上拉加载）
- ✅ 调用 HTTP 层获取数据
- ✅ 数据转换和格式化
- ❌ 不直接操作 UI（通过响应式状态驱动）
- ❌ 不包含布局逻辑（在 View 中处理）
- ❌ 不包含过多业务逻辑（复杂逻辑提取到 Service/Utils）

### 3.3 Controller 命名

- 页面 Controller：`{Feature}Controller`，如 `HomeController`、`VideoDetailController`
- 避免使用下划线前缀的私有 Controller

### 3.4 Controller 示例

```dart
class HotController extends GetxController {
  // 状态变量
  final ScrollController scrollController = ScrollController();
  final int _count = 20;
  int _currentPage = 1;
  RxList<HotVideoItemModel> videoList = <HotVideoItemModel>[].obs;
  bool isLoadingMore = false;
  bool flag = false;
  OverlayEntry? popupDialog;

  // 数据获取
  Future queryHotFeed(type) async {
    var res = await VideoHttp.hotVideoList(
      pn: _currentPage,
      ps: _count,
    );
    if (res['status']) {
      if (type == 'init') {
        videoList.value = res['data'];
      } else if (type == 'onRefresh') {
        videoList.insertAll(0, res['data']);
      } else if (type == 'onLoad') {
        videoList.addAll(res['data']);
      }
      _currentPage += 1;
    }
    isLoadingMore = false;
    return res;
  }

  // 用户交互
  Future onRefresh() async {
    queryHotFeed('onRefresh');
  }

  Future onLoad() async {
    queryHotFeed('onLoad');
  }
}
```

## 4. 依赖注入规范

### 4.1 注册方式

| 方式 | 用法 | 场景 |
|------|------|------|
| `Get.put()` | `Get.put(MyController())` | 立即创建并注册 |
| `Get.lazyPut()` | `Get.lazyPut(() => MyController())` | 首次使用时创建 |
| `Get.create()` | `Get.create(() => MyController())` | 每次获取创建新实例 |

### 4.2 注入位置

Controller 应在 View 的 `build` 方法或 `initState` 中注入：

```dart
class HotPage extends StatefulWidget {
  const HotPage({Key? key}) : super(key: key);

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final HotController _hotController = Get.put(HotController());
  // ...
}
```

### 4.3 Tag 隔离

当多个页面使用相同类型的 Controller 时，使用 tag 区分：

```dart
// 注入
final controller = Get.put(FansController(), tag: mid);

// 获取
final controller = Get.find<FansController>(tag: mid);
```

## 5. 路由状态管理

### 5.1 路由传参

```dart
// 跳转并传参
Get.toNamed('/member', parameters: {'mid': '12345', 'name': 'user'});

// 获取参数
final mid = Get.parameters['mid'];
final name = Get.parameters['name'];
```

### 5.2 路由参数类型转换

```dart
// 数值参数
mid = int.parse(Get.parameters['mid']!);

// 可选参数
final name = Get.parameters['name'] ?? '默认名称';
```

## 6. 全局状态

### 6.1 全局数据缓存

使用 `GlobalDataCache` 管理全局状态：

```dart
// 初始化
await GlobalDataCache().initialize();

// 使用
final cache = GlobalDataCache();
```

### 6.2 事件总线

使用 `EventBus` 进行跨组件通信：

```dart
// 发送事件
loginEvent.fire(true);

// 监听事件
loginEvent.listen((event) {
  // 处理事件
});
```

## 7. 最佳实践

### 7.1 状态初始化

- 在 `onInit` 中初始化状态
- 在 `onReady` 中执行首次数据加载
- 在 `onClose` 中释放资源

### 7.2 错误处理

```dart
Future<void> loadData() async {
  isLoading.value = true;
  error.value = null;
  
  try {
    final result = await api.fetchData();
    data.value = result;
  } catch (e) {
    error.value = e.toString();
  } finally {
    isLoading.value = false;
  }
}
```

### 7.3 列表状态

```dart
class ListController extends GetxController {
  RxList<Item> items = <Item>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  RxString? error;

  Future<void> refresh() async {
    // 重置状态并重新加载
  }

  Future<void> loadMore() async {
    // 加载更多数据
  }
}
```

## 8. 常见问题

### 8.1 Obx 不更新

- 确保变量是 `.obs` 类型
- 确保在 Obx 的 builder 中使用了响应式变量
- 如果修改 List/Map 内部元素，需要调用 `.refresh()`

### 8.2 Controller 重复创建

- 使用 `Get.put()` 时确保只调用一次
- 考虑使用 `Get.lazyPut()` 或 Bindings
- 使用 tag 区分不同实例

### 8.3 内存泄漏

- 在 `onClose` 中释放 ScrollController、StreamSubscription 等
- 取消未完成的 HTTP 请求
- 移除事件监听器
