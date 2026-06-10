# 测试模式与最佳实践

## 1. 概述

本文档定义 PiliPala 项目中使用的测试模式和最佳实践，帮助开发者编写高质量的测试代码。

## 2. 测试模式

### 2.1 AAA 模式

每个测试遵循 Arrange-Act-Assert 结构：

```dart
test('should return video list when API succeeds', () {
  // Arrange（准备）
  final mockDio = MockDio();
  when(mockDio.get(any)).thenAnswer(
    (_) async => Response(data: {'code': 0, 'data': [...]}),
  );
  
  // Act（执行）
  final result = await VideoHttp.hotVideoList(pn: 1, ps: 20);
  
  // Assert（断言）
  expect(result['status'], true);
  expect(result['data'], isNotEmpty);
});
```

### 2.2 Given-When-Then 模式

用于描述用户行为的 BDD 风格：

```dart
group('搜索功能', () {
  test('Given 用户输入关键词 When 执行搜索 Then 返回搜索结果', () async {
    // Given
    final controller = SearchController();
    controller.keyword.value = 'Flutter';
    
    // When
    await controller.querySearchResult();
    
    // Then
    expect(controller.resultList.isNotEmpty, true);
  });
});
```

### 2.3 表驱动测试

使用一组测试数据批量测试：

```dart
group('推荐过滤', () {
  final testCases = [
    {'duration': 30, 'minDuration': 60, 'expected': false},
    {'duration': 90, 'minDuration': 60, 'expected': true},
    {'duration': 120, 'minDuration': 60, 'expected': true},
  ];
  
  for (final testCase in testCases) {
    test('should filter video with duration ${testCase['duration']}', () {
      final video = Video(duration: testCase['duration'] as int);
      final result = filter.shouldKeep(video, minDuration: testCase['minDuration'] as int);
      expect(result, testCase['expected']);
    });
  }
});
```

## 3. 测试工具类

### 3.1 测试数据工厂

```dart
class TestDataFactory {
  // 创建测试视频
  static HotVideoItemModel createHotVideo({
    int? aid,
    String? bvid,
    String? title,
    int? duration,
    int? view,
    int? like,
  }) {
    return HotVideoItemModel()
      ..aid = aid ?? 12345
      ..bvid = bvid ?? 'BV1xx411c7mD'
      ..title = title ?? 'Test Video Title'
      ..duration = duration ?? 120
      ..stat = (Stat()
        ..view = view ?? 1000
        ..like = like ?? 100);
  }
  
  // 创建测试用户
  static UserInfoData createUser({
    int? mid,
    String? name,
    String? face,
    int? level,
  }) {
    return UserInfoData()
      ..mid = mid ?? 12345
      ..name = name ?? 'TestUser'
      ..face = face ?? 'https://example.com/face.jpg'
      ..level = level ?? 5;
  }
  
  // 创建 API 成功响应
  static Map<String, dynamic> createSuccessResponse(dynamic data) {
    return {
      'code': 0,
      'message': '0',
      'ttl': 1,
      'data': data,
    };
  }
  
  // 创建 API 错误响应
  static Map<String, dynamic> createErrorResponse({
    int code = -1,
    String message = 'Error',
  }) {
    return {
      'code': code,
      'message': message,
      'ttl': 1,
      'data': null,
    };
  }
}
```

### 3.2 Widget 测试辅助

```dart
class WidgetTestHelper {
  // 包装 Widget 以提供必要的依赖
  static Widget wrapWithMaterial(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }
  
  // 包装 Widget 以提供 GetX 依赖
  static Widget wrapWithGetX(Widget child) {
    return GetMaterialApp(
      home: Scaffold(body: child),
    );
  }
  
  // 等待异步操作完成
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  
  // 模拟屏幕尺寸
  static Future<void> setScreenSize(
    WidgetTester tester, {
    double width = 375,
    double height = 812,
  }) async {
    tester.binding.window.physicalSizeTestValue = Size(width, height);
    tester.binding.window.devicePixelRatioTestValue = 2.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });
  }
}
```

## 4. Mock 模式

### 4.1 Mock Dio

```dart
class MockDioAdapter extends HttpClientAdapter {
  final Map<String, Response> _responses = {};
  
  void onGet(String path, Response response) {
    _responses['GET:$path'] = response;
  }
  
  void onPost(String path, Response response) {
    _responses['POST:$path'] = response;
  }
  
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = '${options.method}:${options.path}';
    final response = _responses[key];
    
    if (response != null) {
      return ResponseBody.fromString(
        jsonEncode(response.data),
        response.statusCode ?? 200,
        headers: response.headers,
      );
    }
    
    throw DioException(
      requestOptions: options,
      error: 'No mock response for $key',
    );
  }
}
```

### 4.2 Mock Hive

```dart
class MockHiveBox extends Mock implements Box<dynamic> {
  final Map<String, dynamic> _data = {};
  
  @override
  Future<void> put(String key, dynamic value) async {
    _data[key] = value;
  }
  
  @override
  dynamic get(String key, {dynamic defaultValue}) {
    return _data.containsKey(key) ? _data[key] : defaultValue;
  }
  
  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
  
  @override
  Future<void> clear() async {
    _data.clear();
  }
  
  @override
  bool containsKey(String key) => _data.containsKey(key);
}
```

### 4.3 Mock GetX Controller

```dart
class MockController extends GetxController {
  final RxList<dynamic> items = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  void setMockData(List<dynamic> data) {
    items.value = data;
    isLoading.value = false;
    error.value = '';
  }
  
  void setMockError(String message) {
    items.clear();
    isLoading.value = false;
    error.value = message;
  }
}
```

## 5. 异步测试

### 5.1 等待异步操作

```dart
test('should load data asynchronously', () async {
  final controller = MyController();
  
  // 触发异步操作
  controller.loadData();
  
  // 等待异步完成
  await untilCalled(controller.loadData);
  
  // 或使用 pump
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
});
```

### 5.2 使用 FakeAsync

```dart
test('should debounce search input', () {
  FakeAsync().run((async) {
    final controller = SearchController();
    
    // 快速输入多次
    controller.keyword.value = 'F';
    async.elapse(const Duration(milliseconds: 100));
    controller.keyword.value = 'Fl';
    async.elapse(const Duration(milliseconds: 100));
    controller.keyword.value = 'Flu';
    async.elapse(const Duration(milliseconds: 100));
    controller.keyword.value = 'Flut';
    
    // 等待防抖时间
    async.elapse(const Duration(milliseconds: 500));
    
    // 验证只触发了一次搜索
    verify(controller.querySuggest('Flut')).called(1);
  });
});
```

## 6. 快照测试

### 6.1 使用 golden_toolkit

```dart
testGoldens('HotPage should match golden file', (tester) async {
  final builder = GoldenBuilder.column()
    ..addScenario('Default', const HotPage())
    ..addScenario('Loading', const HotPageLoading())
    ..addScenario('Error', const HotPageError());
  
  await tester.pumpWidgetBuilder(builder.build());
  await screenMatchesGolden(tester, 'hot_page');
});
```

## 7. 性能测试

### 7.1 列表性能

```dart
testWidgets('Video list should render efficiently', (tester) async {
  final stopwatch = Stopwatch()..start();
  
  await tester.pumpWidget(const MaterialApp(home: HotPage()));
  await tester.pumpAndSettle();
  
  stopwatch.stop();
  
  // 断言渲染时间小于 1 秒
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

## 8. 测试覆盖率

### 8.1 生成覆盖率报告

```bash
# 运行测试并生成覆盖率
flutter test --coverage

# 生成 HTML 报告
genhtml coverage/lcov.info -o coverage/html

# 打开报告
open coverage/html/index.html
```

### 8.2 覆盖率目标

| 模块 | 目标覆盖率 | 当前覆盖率 |
|------|----------|----------|
| HTTP 层 | 80% | 0% |
| 数据模型 | 90% | 0% |
| 工具函数 | 80% | 0% |
| Controller | 60% | 0% |
| Widget | 40% | 0% |

## 9. 常见问题

### 9.1 Widget 测试找不到元素

```dart
// 问题：find.text 找不到文本
// 解决：确保文本在 MaterialApp 内
await tester.pumpWidget(MaterialApp(home: MyPage()));
```

### 9.2 GetX Controller 未找到

```dart
// 问题：Get.find() 抛出异常
// 解决：在测试前注入 Controller
setUp(() {
  Get.put(MyController());
});

tearDown(() {
  Get.delete<MyController>();
});
```

### 9.3 异步操作超时

```dart
// 问题：pumpAndSettle 超时
// 解决：使用 pump 配合 Duration
await tester.pump();
await tester.pump(const Duration(seconds: 1));
```

### 9.4 Hive 未初始化

```dart
// 问题：Hive 操作报错
// 解决：在测试前初始化 Hive
setUp(() async {
  Hive.init('test_hive');
  await GStrorage.init();
});
```

## 10. 测试检查清单

在提交代码前，确保：

- [ ] 新增代码有对应的测试
- [ ] 所有测试通过 (`flutter test`)
- [ ] 代码覆盖率不低于模块目标
- [ ] 测试命名清晰描述测试意图
- [ ] 测试不依赖外部服务
- [ ] 测试数据使用工厂方法生成
- [ ] 测试后清理资源（tearDown）
