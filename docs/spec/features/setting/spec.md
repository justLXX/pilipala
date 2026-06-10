# 设置功能规格书

## 1. 功能描述

设置页面允许用户自定义应用的各种选项，包括播放器设置、外观设置、推荐设置、隐私设置等。

## 2. 用户流程

```
用户进入设置页面
    │
    ├── 播放器设置
    │   ├── 默认清晰度
    │   ├── 默认倍速
    │   ├── 自动播放
    │   ├── 弹幕设置
    │   └── 手势设置
    │
    ├── 外观设置
    │   ├── 主题模式
    │   ├── 主题色
    │   ├── 动态取色
    │   └── 字体大小
    │
    ├── 推荐设置
    │   ├── 推荐类型（Web/App）
    │   ├── 最小时长过滤
    │   └── 点赞率过滤
    │
    ├── 隐私设置
    │   └── 黑名单管理
    │
    └── 其他设置
        ├── 检查更新
        ├── 清除缓存
        └── 关于
```

## 3. 页面清单

| 页面 | 路由 | 文件 | 说明 |
|------|------|------|------|
| 设置主页 | `/setting` | `lib/pages/setting/view.dart` | 设置主页面 |
| 推荐设置 | `/recommendSetting` | `lib/pages/setting/recommend_setting.dart` | 推荐过滤设置 |
| 播放设置 | `/playSetting` | `lib/pages/setting/play_setting.dart` | 播放器设置 |
| 外观设置 | `/styleSetting` | `lib/pages/setting/style_setting.dart` | 外观设置 |
| 隐私设置 | `/privacySetting` | `lib/pages/setting/privacy_setting.dart` | 隐私设置 |
| 其他设置 | `/extraSetting` | `lib/pages/setting/extra_setting.dart` | 其他设置 |
| 主题色 | `/colorSetting` | `lib/pages/setting/pages/color_select.dart` | 选择主题色 |
| 字体大小 | `/fontSizeSetting` | `lib/pages/setting/pages/font_size_select.dart` | 选择字体大小 |
| 屏幕帧率 | `/displayModeSetting` | `lib/pages/setting/pages/display_mode.dart` | 设置屏幕帧率 |
| 首页 Tab | `/tabbarSetting` | `lib/pages/setting/pages/home_tabbar_set.dart` | 首页 Tab 排序 |
| 导航栏 | `/navbarSetting` | `lib/pages/setting/pages/navigation_bar_set.dart` | 导航栏排序 |
| 播放速度 | `/playSpeedSet` | `lib/pages/setting/pages/play_speed_set.dart` | 播放速度设置 |
| 操作菜单 | `/actionMenuSet` | `lib/pages/setting/pages/action_menu_set.dart` | 操作菜单排序 |

## 4. Controller 职责

### 4.1 SettingController

文件：`lib/pages/setting/controller.dart`

职责：
- 管理设置项的读取和写入
- 处理设置变更

```dart
class SettingController extends GetxController {
  Box setting = GStrorage.setting;
  
  T getSetting<T>(String key, T defaultValue) {
    return setting.get(key, defaultValue: defaultValue) as T;
  }
  
  Future<void> setSetting<T>(String key, T value) async {
    await setting.put(key, value);
  }
}
```

## 5. 设置项定义

### 5.1 播放器设置

文件：`lib/utils/storage.dart`

```dart
class SettingBoxKey {
  static const String defaultVideoQa = 'defaultVideoQa';      // 默认清晰度
  static const String defaultVideoSpeed = 'defaultVideoSpeed'; // 默认倍速
  static const String autoPlayEnable = 'autoPlayEnable';       // 自动播放
  static const String danmakuEnable = 'danmakuEnable';         // 弹幕开关
  static const String fullScreenMode = 'fullScreenMode';       // 全屏模式
  static const String defaultDecode = 'defaultDecode';         // 默认解码
  static const String enableAutoBrightness = 'enableAutoBrightness'; // 自动亮度
  static const String enableAutoEnter = 'enableAutoEnter';     // 自动进入全屏
  static const String enableAutoExit = 'enableAutoExit';       // 自动退出全屏
  static const String enableQuickDouble = 'enableQuickDouble'; // 双击快进
  static const String fullScreenGestureMode = 'fullScreenGestureMode'; // 手势模式
}
```

### 5.2 外观设置

```dart
class SettingBoxKey {
  static const String themeMode = 'themeMode';                 // 主题模式
  static const String customColor = 'customColor';             // 自定义主题色
  static const String dynamicColor = 'dynamicColor';           // 动态取色
  static const String defaultTextScale = 'textScale';          // 字体缩放
  static const String enableSingleRow = 'enableSingleRow';     // 首页单列
  static const String customRows = 'customRows';               // 自定义列数
  static const String enableGradientBg = 'enableGradientBg';   // 渐变背景
}
```

### 5.3 推荐设置

```dart
class SettingBoxKey {
  static const String enableRcmdDynamic = 'enableRcmdDynamic';     // 推荐动态
  static const String defaultRcmdType = 'defaultRcmdType';         // 默认推荐类型
  static const String minDurationForRcmd = 'minDurationForRcmd';   // 最小时长
  static const String minLikeRatioForRecommend = 'minLikeRatioForRecommend'; // 最小点赞率
  static const String exemptFilterForFollowed = 'exemptFilterForFollowed';   // 关注用户豁免
  static const String applyFilterToRelatedVideos = 'applyFilterToRelatedVideos'; // 相关视频过滤
}
```

### 5.4 隐私设置

```dart
class SettingBoxKey {
  static const String blackMidsList = 'blackMidsList'; // 黑名单用户 ID 列表
}
```

## 6. 设置存储

### 6.1 读取设置

```dart
// 读取主题模式
ThemeType currentTheme = ThemeType.values[
  setting.get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code)
];

// 读取默认倍速
double speed = setting.get(SettingBoxKey.defaultVideoSpeed, defaultValue: 1.0);
```

### 6.2 写入设置

```dart
// 设置主题模式
await setting.put(SettingBoxKey.themeMode, ThemeType.dark.code);

// 设置默认倍速
await setting.put(SettingBoxKey.defaultVideoSpeed, 1.5);
```

## 7. 状态管理

### 7.1 设置变更流程

```
[用户操作]
    │
    ├── 点击设置项
    │   ├── 弹出选择器/开关
    │   └── 用户选择新值
    │
    ├── 保存设置
    │   ├── setting.put(key, value)
    │   └── 触发响应式更新
    │
    └── 应用新设置
        ├── 更新 UI
        └── 通知相关模块
```

## 8. 注意事项

- 所有设置存储在 Hive 的 `setting` Box 中
- 设置变更后需要实时生效
- 部分设置需要重启应用才能生效
- 设置项应提供默认值
- 复杂设置（如排序）使用 JSON 字符串存储
