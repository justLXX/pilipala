# 存储规范

## 1. 概述

PiliPala 使用 **Hive** 作为本地数据持久化方案，通过 `GStrorage` 单例统一管理所有 Hive Box。

## 2. Hive Box 定义

### 2.1 Box 列表

| Box 名称 | 用途 | 关键 Key | 类型 |
|----------|------|---------|------|
| `userInfo` | 登录用户信息 | `userInfoCache` | `UserInfoData` |
| `localCache` | 本地缓存 | `accessKey`, `wbiKeys`, `danmakuSettings` | 混合 |
| `setting` | 应用设置 | `themeMode`, `customColor`, `playerSettings` | 混合 |
| `historyWord` | 搜索历史 | - | `String` 列表 |
| `video` | 视频播放偏好 | `videoFit`, `videoSpeed` | 混合 |

### 2.2 Box 初始化

```dart
class GStrorage {
  static late final Box<dynamic> userInfo;
  static late final Box<dynamic> historyword;
  static late final Box<dynamic> localCache;
  static late final Box<dynamic> setting;
  static late final Box<dynamic> video;

  static Future<void> init() async {
    final Directory dir = await getApplicationSupportDirectory();
    final String path = dir.path;
    await Hive.initFlutter('$path/hive');
    regAdapter();
    
    userInfo = await Hive.openBox('userInfo');
    localCache = await Hive.openBox('localCache');
    setting = await Hive.openBox('setting');
    historyword = await Hive.openBox('historyWord');
    video = await Hive.openBox('video');
  }
}
```

## 3. 设置键值规范

### 3.1 SettingBoxKey

所有应用设置键定义在 `lib/utils/storage.dart` 的 `SettingBoxKey` 类中：

```dart
class SettingBoxKey {
  // 播放器设置
  static const String btmProgressBehavior = 'btmProgressBehavior';
  static const String defaultVideoSpeed = 'defaultVideoSpeed';
  static const String autoPlayEnable = 'autoPlayEnable';
  static const String danmakuEnable = 'danmakuEnable';
  
  // 外观设置
  static const String themeMode = 'themeMode';
  static const String customColor = 'customColor';
  static const String dynamicColor = 'dynamicColor';
  static const String defaultTextScale = 'textScale';
  
  // 推荐设置
  static const String enableRcmdDynamic = 'enableRcmdDynamic';
  static const String minDurationForRcmd = 'minDurationForRcmd';
  
  // 隐私设置
  static const String blackMidsList = 'blackMidsList';
  
  // 其他设置
  static const String autoUpdate = 'autoUpdate';
  static const String replySortType = 'replySortType';
}
```

### 3.2 LocalCacheKey

本地缓存键定义：

```dart
class LocalCacheKey {
  // 认证
  static const String accessKey = 'accessKey';
  
  // WBI 签名
  static const String wbiKeys = 'wbiKeys';
  static const String timeStamp = 'timeStamp';
  
  // 弹幕设置
  static const String danmakuBlockType = 'danmakuBlockType';
  static const String danmakuShowArea = 'danmakuShowArea';
  static const String danmakuOpacity = 'danmakuOpacity';
  
  // 代理
  static const String systemProxyHost = 'systemProxyHost';
  static const String systemProxyPort = 'systemProxyPort';
}
```

### 3.3 VideoBoxKey

视频播放偏好键定义：

```dart
class VideoBoxKey {
  static const String videoFit = 'videoFit';
  static const String videoBrightness = 'videoBrightness';
  static const String videoSpeed = 'videoSpeed';
  static const String playRepeat = 'playRepeat';
  static const String customSpeedsList = 'customSpeedsList';
}
```

## 4. 数据读写规范

### 4.1 读取数据

```dart
// 带默认值的读取
Box setting = GStrorage.setting;
bool isDynamicColor = setting.get(
  SettingBoxKey.dynamicColor, 
  defaultValue: true,
);

// 枚举类型读取
ThemeType currentTheme = ThemeType.values[
  setting.get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code)
];
```

### 4.2 写入数据

```dart
// 直接写入
setting.put(SettingBoxKey.themeMode, ThemeType.dark.code);

// 写入对象（需注册 Adapter）
userInfo.put('userInfoCache', userInfoData);
```

### 4.3 删除数据

```dart
// 删除单个键
setting.delete(SettingBoxKey.themeMode);

// 清空 Box
setting.clear();
```

## 5. Hive Adapter 规范

### 5.1 注册 Adapter

```dart
static void regAdapter() {
  Hive.registerAdapter(UserInfoDataAdapter());
  Hive.registerAdapter(LevelInfoAdapter());
  // 新增 Adapter 在此注册
}
```

### 5.2 生成 Adapter

使用 `hive_generator` 自动生成 Adapter：

```dart
// 1. 在模型类上添加注解
@HiveType(typeId: 0)
class UserInfoData {
  @HiveField(0)
  int? mid;
  
  @HiveField(1)
  String? name;
  
  // ...
}

// 2. 运行代码生成
// flutter packages pub run build_runner build
```

### 5.3 Type ID 管理

| Type ID | 类型 |
|---------|------|
| 0 | `UserInfoData` |
| 1 | `LevelInfo` |
| ... | 新增类型需递增 |

## 6. 存储访问规范

### 6.1 直接访问（当前方式）

```dart
// 在 Controller 或 Widget 中直接访问
Box setting = GStrorage.setting;
var value = setting.get(SettingBoxKey.themeMode);
```

### 6.2 推荐方式（未来重构）

使用 Repository 模式封装存储访问：

```dart
class SettingsRepository {
  final Box _settingBox = GStrorage.setting;
  
  ThemeType getThemeMode() {
    return ThemeType.values[
      _settingBox.get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code)
    ];
  }
  
  Future<void> setThemeMode(ThemeType mode) async {
    await _settingBox.put(SettingBoxKey.themeMode, mode.code);
  }
}
```

## 7. 数据迁移

### 7.1 版本兼容

当修改数据模型时，需要处理旧版本数据：

```dart
// 检查版本并迁移
if (setting.get('version') == null) {
  // 首次安装，无需迁移
} else if (setting.get('version') == '1.0.0') {
  // 从 1.0.0 迁移到 1.0.1
  _migrateFrom100();
}
```

### 7.2 默认值处理

读取时始终提供默认值，避免 null 值导致的问题：

```dart
// ✅ 好的做法
bool value = box.get(key, defaultValue: false);

// ❌ 避免的做法
bool? value = box.get(key); // 可能返回 null
```

## 8. 最佳实践

### 8.1 键命名规范

- 使用 camelCase 命名
- 键名应具有描述性
- 避免使用魔法字符串，统一使用常量

### 8.2 数据类型规范

| 存储类型 | Hive 类型 | 注意事项 |
|---------|----------|---------|
| 字符串 | `String` | 直接存储 |
| 整数 | `int` | 枚举存储为 int code |
| 布尔 | `bool` | 直接存储 |
| 列表 | `List` | 简单类型可直接存储 |
| 对象 | 自定义类型 | 需要注册 Adapter |
| 复杂对象 | JSON 字符串 | 可序列化为 String 存储 |

### 8.3 性能优化

- 批量写入时使用事务
- 定期压缩 Box（设置 `compactionStrategy`）
- 避免频繁读写
- 大数据量考虑分页存储

### 8.4 安全注意事项

- 敏感数据（Token、Cookie）存储在 `localCache` Box
- 避免在日志中打印敏感数据
- 考虑使用加密存储（未来改进）
