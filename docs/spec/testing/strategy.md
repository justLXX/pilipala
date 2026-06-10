# 测试策略

## 1. 概述

PiliPala 项目目前仅有 1 个默认的 widget_test.dart，测试覆盖几乎为零。本测试策略旨在建立完整的测试体系，确保代码质量和功能稳定性。

## 2. 测试目标

| 层级 | 目标覆盖率 | 说明 |
|------|-----------|------|
| 单元测试 | 60%+ | 业务逻辑、数据转换、工具函数 |
| Widget 测试 | 40%+ | 页面渲染、交互响应 |
| 集成测试 | 20%+ | 关键用户流程 |

## 3. 测试类型

### 3.1 单元测试

测试独立的业务逻辑、数据转换和工具函数。

**范围**：
- HTTP 层的请求/响应处理
- 数据模型的序列化/反序列化
- 工具函数（时间格式化、URL 处理等）
- 业务逻辑（推荐过滤、排序等）

**示例**：

```dart
void main() {
  group('RecommendFilter', () {
    test('should filter videos by duration', () {
      final filter = RecommendFilter();
      final videos = [
        Video(duration: 30),
        Video(duration: 60),
        Video(duration: 120),
      ];
      
      final result = filter.filterByDuration(videos, minDuration: 60);
      
      expect(result.length, 2);
      expect(result.every((v) => v.duration >= 60), true);
    });
  });
}
```

### 3.2 Widget 测试

测试 Widget 的渲染和交互。

**范围**：
- 页面布局渲染
- 用户交互响应（点击、滑动等）
- 状态变化后的 UI 更新
- 错误状态展示

**示例**：

```dart
void main() {
  testWidgets('HotPage displays video list', (WidgetTester tester) async {
    // 构建页面
    await tester.pumpWidget(const MaterialApp(home: HotPage()));
    
    // 等待加载完成
    await tester.pumpAndSettle();
    
    // 验证页面标题
    expect(find.text('热门'), findsOneWidget);
    
    // 验证视频列表存在
    expect(find.byType(VideoCardH), findsWidgets);
  });
}
```

### 3.3 集成测试

测试完整的用户流程。

**范围**：
- 登录流程
- 视频播放流程
- 搜索流程
- 收藏流程

**示例**：

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User can search and play video', (WidgetTester tester) async {
    // 启动应用
    app.main();
    await tester.pumpAndSettle();
    
    // 点击搜索按钮
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    
    // 输入搜索关键词
    await tester.enterText(find.byType(TextField), 'Flutter');
    await tester.pumpAndSettle();
    
    // 点击搜索结果
    await tester.tap(find.byType(VideoCardH).first);
    await tester.pumpAndSettle();
    
    // 验证进入视频详情页
    expect(find.byType(VideoDetailPage), findsOneWidget);
  });
}
```

## 4. 测试目录结构

```
test/
├── unit/                    # 单元测试
│   ├── http/               # HTTP 层测试
│   ├── models/             # 数据模型测试
│   ├── utils/              # 工具函数测试
│   └── services/           # 服务测试
├── widget/                  # Widget 测试
│   ├── pages/              # 页面测试
│   └── common/             # 通用组件测试
├── integration/             # 集成测试
│   ├── login_test.dart     # 登录流程
│   ├── video_test.dart     # 视频播放流程
│   └── search_test.dart    # 搜索流程
├── mocks/                   # Mock 数据
│   ├── api_responses/      # API 响应 Mock
│   └── fixtures/           # 测试数据
└── helpers/                 # 测试工具
    ├── mock_dio.dart       # Mock Dio
    ├── mock_hive.dart      # Mock Hive
    └── test_utils.dart     # 通用工具
```

## 5. 测试依赖

### 5.1 当前依赖

pubspec.yaml 中已有的测试依赖：

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

### 5.2 需要添加的依赖

```yaml
dev_dependencies:
  # 单元测试
  mockito: ^5.4.0
  build_runner: ^2.4.8
  
  # Widget 测试
  golden_toolkit: ^0.15.0
  
  # 集成测试
  integration_test:
    sdk: flutter
```

## 6. Mock 策略

### 6.1 Mock Dio

```dart
class MockDio extends Mock implements Dio {
  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return super.noSuchMethod(
      Invocation.method(#get, [path], {
        #queryParameters: queryParameters,
        #options: options,
      }),
      returnValue: Future.value(Response<T>(
        requestOptions: RequestOptions(path: path),
        data: {} as T,
      )),
    );
  }
}
```

### 6.2 Mock Hive

```dart
class MockBox extends Mock implements Box<dynamic> {
  final Map<String, dynamic> _data = {};

  @override
  Future<void> put(String key, dynamic value) async {
    _data[key] = value;
  }

  @override
  dynamic get(String key, {dynamic defaultValue}) {
    return _data[key] ?? defaultValue;
  }
}
```

### 6.3 Mock GetX Controller

```dart
class MockHotController extends Mock implements HotController {
  @override
  RxList<HotVideoItemModel> get videoList => RxList<HotVideoItemModel>([]);
}
```

## 7. 测试数据工厂

```dart
class VideoFactory {
  static HotVideoItemModel createVideo({
    int? aid,
    String? title,
    String? bvid,
    int? duration,
  }) {
    return HotVideoItemModel()
      ..aid = aid ?? 12345
      ..title = title ?? 'Test Video'
      ..bvid = bvid ?? 'BV1xx411c7mD'
      ..duration = duration ?? 120;
  }
}

class ApiResponseFactory {
  static Map<String, dynamic> success<T>(T data) {
    return {
      'code': 0,
      'message': '0',
      'data': data,
    };
  }

  static Map<String, dynamic> error({
    int code = -1,
    String message = 'Error',
  }) {
    return {
      'code': code,
      'message': message,
      'data': [],
    };
  }
}
```

## 8. CI/CD 集成

### 8.1 GitHub Actions

在 `.github/workflows/` 中添加测试步骤：

```yaml
- name: Run tests
  run: flutter test

- name: Run integration tests
  run: flutter test integration_test/
```

### 8.2 测试报告

配置测试报告生成：

```yaml
- name: Generate test report
  run: |
    flutter test --coverage
    genhtml coverage/lcov.info -o coverage/html
```

## 9. 测试最佳实践

### 9.1 命名规范

- 测试文件：`{name}_test.dart`
- 测试组：`group('FeatureName', () { ... })`
- 测试用例：`test('should ... when ...', () { ... })`

### 9.2 测试结构

```dart
void main() {
  group('FeatureName', () {
    late FeatureController controller;
    
    setUp(() {
      controller = FeatureController();
    });
    
    tearDown(() {
      controller.dispose();
    });
    
    test('should do something when condition', () {
      // Arrange
      final input = 'test';
      
      // Act
      final result = controller.doSomething(input);
      
      // Assert
      expect(result, equals('expected'));
    });
  });
}
```

### 9.3 避免的问题

- ❌ 不要测试 Flutter 框架本身
- ❌ 不要测试第三方库
- ❌ 不要依赖外部服务（使用 Mock）
- ❌ 不要写过于复杂的测试
- ✅ 测试业务逻辑而非实现细节
- ✅ 每个测试只验证一个概念
- ✅ 使用描述性的测试名称

## 10. 测试计划

### Phase 1: 基础设施

- [ ] 配置测试依赖
- [ ] 创建测试目录结构
- [ ] 实现 Mock 工具类
- [ ] 实现测试数据工厂

### Phase 2: 单元测试

- [ ] HTTP 层测试
- [ ] 数据模型测试
- [ ] 工具函数测试
- [ ] 业务逻辑测试

### Phase 3: Widget 测试

- [ ] 核心页面测试
- [ ] 通用组件测试
- [ ] 交互响应测试

### Phase 4: 集成测试

- [ ] 登录流程测试
- [ ] 视频播放流程测试
- [ ] 搜索流程测试
