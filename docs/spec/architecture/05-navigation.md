# 导航规范

## 1. 概述

PiliPala 使用 **GetX** 的路由系统，通过 `GetMaterialApp` 和命名路由实现页面导航。

## 2. 路由配置

### 2.1 路由定义

所有路由定义在 `lib/router/app_pages.dart` 中：

```dart
class Routes {
  static final List<GetPage<dynamic>> getPages = [
    CustomGetPage(name: '/', page: () => const HomePage()),
    CustomGetPage(name: '/hot', page: () => const HotPage()),
    CustomGetPage(name: '/video', page: () => const VideoDetailPage()),
    // ...
  ];
}
```

### 2.2 CustomGetPage

自定义的 GetPage 封装，统一配置过渡动画：

```dart
class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.transitionDuration,
  }) : super(
    curve: Curves.linear,
    transition: Transition.native,
    showCupertinoParallax: false,
    popGesture: false,
    fullscreenDialog: fullscreen != null && fullscreen,
  );
}
```

## 3. 路由命名规范

### 3.1 命名规则

| 规则 | 示例 | 说明 |
|------|------|------|
| 使用小写 | `/home`, `/video` | 避免大写 |
| 使用连字符 | `/video-detail` | 可选，当前项目未使用 |
| 层级结构 | `/member/archive` | 表示层级关系 |
| 动词后缀 | `/favEdit`, `/searchResult` | 当前项目的命名习惯 |

### 3.2 路由列表

| 路由 | 页面 | 说明 |
|------|------|------|
| `/` | HomePage | 首页（推荐） |
| `/hot` | HotPage | 热门 |
| `/video` | VideoDetailPage | 视频详情 |
| `/search` | SearchPage | 搜索 |
| `/searchResult` | SearchResultPage | 搜索结果 |
| `/dynamics` | DynamicsPage | 动态 |
| `/member` | MemberPage | 用户中心 |
| `/follow` | FollowPage | 关注列表 |
| `/fan` | FansPage | 粉丝列表 |
| `/liveRoom` | LiveRoomPage | 直播间 |
| `/setting` | SettingPage | 设置 |
| `/loginPage` | LoginPage | 登录 |
| ... | ... | ... |

## 4. 页面传参

### 4.1 URL 参数

```dart
// 跳转并传参
Get.toNamed('/member', parameters: {'mid': '12345', 'name': 'username'});

// 获取参数
final mid = Get.parameters['mid'];
final name = Get.parameters['name'];
```

### 4.2 参数类型转换

```dart
// 数值参数
int mid = int.parse(Get.parameters['mid']!);

// 可选参数
final name = Get.parameters['name'] ?? '默认名称';
```

### 4.3 复杂参数

对于复杂对象，使用 `arguments`：

```dart
// 跳转并传递对象
Get.toNamed('/video', arguments: {'videoData': videoData});

// 获取参数
final args = Get.arguments;
final videoData = args['videoData'];
```

## 5. 导航方法

### 5.1 常用导航

```dart
// 跳转到新页面
Get.toNamed('/video');

// 替换当前页面
Get.offNamed('/video');

// 清除所有页面并跳转
Get.offAllNamed('/');

// 返回上一页
Get.back();

// 返回并携带结果
Get.back(result: {'success': true});
```

### 5.2 防止重复跳转

```dart
// 防止重复跳转同一页面
Get.toNamed('/loginPage', preventDuplicates: false);
```

## 6. 路由守卫

### 6.1 登录检查

在需要登录的页面进行登录检查：

```dart
// Controller 中
void onLogin() async {
  if (!userLogin.value) {
    Get.toNamed('/loginPage', preventDuplicates: false);
  } else {
    // 已登录，执行操作
  }
}
```

### 6.2 路由观察者

使用 `RouteObserver` 监听路由变化：

```dart
GetMaterialApp(
  navigatorObservers: [
    VideoDetailPage.routeObserver,
    SearchPage.routeObserver,
  ],
);
```

## 7. 底部导航

### 7.1 Main Navigation

`lib/pages/main/view.dart` 定义了底部导航栏：

```dart
// 4 个主要 Tab
List defaultNavigationBars = [
  {'label': '首页', 'page': const HomePage()},
  {'label': '排行榜', 'page': const RankPage()},
  {'label': '动态', 'page': const DynamicsPage()},
  {'label': '媒体库', 'page': const MediaPage()},
];
```

### 7.2 Tab 排序配置

用户可自定义 Tab 顺序，配置存储在 Hive：

```dart
// 读取自定义排序
List navBarSort = setting.get(SettingBoxKey.navBarSort, defaultValue: [...]);
```

## 8. 路由与状态管理

### 8.1 页面级状态

每个页面有自己的 Controller，在页面创建时注入：

```dart
class HotPage extends StatefulWidget {
  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final HotController _hotController = Get.put(HotController());
  // ...
}
```

### 8.2 跨页面通信

使用 GetX 的依赖注入在页面间共享状态：

```dart
// 在页面 A 中注入
final controller = Get.put(MyController());

// 在页面 B 中获取
final controller = Get.find<MyController>();
```

## 9. 最佳实践

### 9.1 路由常量

将路由字符串提取为常量，避免硬编码：

```dart
// ❌ 避免
Get.toNamed('/video');

// ✅ 推荐
class AppRoutes {
  static const String video = '/video';
}
Get.toNamed(AppRoutes.video);
```

### 9.2 参数验证

在 Controller 的 `onInit` 中验证必要参数：

```dart
@override
void onInit() {
  super.onInit();
  mid = Get.parameters['mid'] != null
      ? int.parse(Get.parameters['mid']!)
      : userInfo.mid;
  
  if (mid == null) {
    // 参数错误，返回上一页
    Get.back();
    return;
  }
}
```

### 9.3 页面返回

使用 `then` 监听页面返回结果：

```dart
Get.toNamed('/loginPage')?.then((result) {
  if (result != null && result['success']) {
    // 登录成功，刷新页面
    refreshData();
  }
});
```

### 9.4 避免的问题

- ❌ 不要在 URL 中传递敏感信息
- ❌ 不要传递过大的对象（使用 ID 重新获取）
- ❌ 避免深层嵌套导航（最多 3 层）
- ✅ 使用 `preventDuplicates` 防止重复跳转
- ✅ 在 `onClose` 中清理资源
