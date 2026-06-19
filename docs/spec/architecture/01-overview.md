# PiliPala 架构设计文档

## 1. 系统概览

### 1.1 项目简介

PiliPala 是一个基于 Flutter 的第三方 Bilibili 客户端，采用 GetX 状态管理框架，使用 Dio 进行 HTTP 通信，Hive 进行本地数据持久化。

### 1.2 技术栈

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| UI 框架 | Flutter (stable) | 跨平台移动应用框架 |
| 状态管理 | GetX 4.6.5 | 响应式状态管理、路由、依赖注入 |
| 网络请求 | Dio 5.4.1 | HTTP 客户端 |
| 本地存储 | Hive 2.2.3 | 轻量级键值存储 |
| 视频播放 | media_kit 1.1.10 | 跨平台视频播放 |
| 后台音频 | audio_service 0.18.13 | 媒体通知和后台播放 |

### 1.3 系统架构图

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │  Pages   │ │ Widgets  │ │ Plugins  │ │  Router  │       │
│  │(Controller│ │(Common) │ │(Player) │ │(Routes)  │       │
│  │  + View) │ │          │ │          │ │          │       │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘       │
│       │            │            │            │              │
│       └────────────┴────────────┴────────────┘              │
│                         │                                   │
│                    GetX State Management                     │
└─────────────────────────┬─────────────────────────────────────┘
                          │
┌─────────────────────────┼─────────────────────────────────────┐
│                         ▼                                     │
│                        Domain Layer                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │  Models  │ │  Utils   │ │ Services │                     │
│  │(Entities)│ │(Helpers) │ │(Business)│                     │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘                     │
│       │            │            │                            │
│       └────────────┴────────────┘                            │
│                         │                                     │
└─────────────────────────┬─────────────────────────────────────┘
                          │
┌─────────────────────────┼─────────────────────────────────────┐
│                         ▼                                     │
│                        Data Layer                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐       │
│  │ HTTP API │ │Interceptors│ │  Hive   │ │  Cookie  │       │
│  │(Dio)     │ │(Auth/Err) │ │(Storage)│ │  (Jar)   │       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘       │
│                                                               │
│  External: Bilibili API (Web/App API)                       │
└─────────────────────────────────────────────────────────────┘
```

### 1.4 模块关系

```
App Entry (main.dart)
    │
    ├── Services Initialization
    │   ├── MediaKit (Video)
    │   ├── Hive (Storage)
    │   ├── Dio (HTTP)
    │   └── Audio Service
    │
    ├── Global Data Cache
    │   └── Settings, User Info, Theme
    │
    └── GetMaterialApp
        ├── Routes (app_pages.dart)
        ├── Main Navigation (4 tabs)
        └── Pages (60+ routes)
```

### 1.5 核心设计原则

1. **功能优先**：按用户可见的功能模块组织代码
2. **GetX 统一**：状态管理、路由、依赖注入全部使用 GetX
3. **响应式编程**：使用 `.obs` 和 `Obx`/`GetX` 实现 UI 自动更新
4. **单层存储**：Hive 作为唯一本地存储，统一管理
5. **API 封装**：HTTP 请求统一封装，返回标准化响应格式

## 2. 目录结构规范

### 2.1 当前结构

```
lib/
├── common/          # 通用组件（骨架屏、Widgets、常量）
├── core/            # 核心层（ApiClient、DI、Storage、Theme）
│   ├── di/          #   依赖注入配置
│   ├── network/     #   ApiClient 抽象 + Dio 实现
│   ├── storage/     #   StorageService (Hive 封装)
│   └── theme/       #   ThemeService
├── features/        # 功能模块（data/domain/presentation 三层架构）
│   ├── about/       #   关于
│   ├── bangumi/     #   番剧
│   ├── blacklist/   #   黑名单
│   ├── dynamics/    #   动态
│   ├── home/        #   首页推荐 + 热门
│   ├── html/        #   HTML 页面
│   ├── live/        #   直播
│   ├── login/       #   登录
│   ├── main/        #   主框架入口
│   ├── media/       #   媒体库
│   ├── message/     #   消息
│   ├── opus/        #   专栏文章
│   ├── rank/        #   排行榜
│   ├── read/        #   阅读页面
│   ├── search/      #   搜索
│   ├── setting/     #   设置
│   ├── user/        #   用户中心
│   ├── video/       #   视频详情
│   └── webview/     #   WebView 页面
├── http/            # HTTP 层（API、请求初始化、拦截器）
├── models/          # 数据模型（按业务域分组）
├── plugin/          # 可复用插件（播放器、画廊等）
├── router/          # 路由配置
├── scripts/         # 脚本
├── services/        # 服务（音频、电池优化等）
├── shared/          # 共享组件
└── utils/           # 工具类
```

### 2.2 features 目录规范

每个 feature 模块遵循三层架构：

```
features/<module>/
  <module>.dart              # barrel 文件（导出各层公共接口）
  data/
    <module>_repository.dart # Repository（封装 ApiClient 调用，返回 ApiResponse<T>）
  domain/
    <module>_use_cases.dart  # UseCase（封装业务逻辑，调用 Repository）
  presentation/
    <module>_controller.dart # GetxController（注入 UseCase，管理响应式状态）
    <module>_page.dart       # StatelessWidget/StatefulWidget（UI 渲染）
    widgets/                 # 页面级子组件
```

### 2.3 模型目录规范

```
models/
  common/         # 通用枚举、配置（主题、类型等）
  <domain>/       # 按业务域分组
    <entity>.dart # 数据实体
```

### 2.4 HTTP 目录规范

```
http/
  api.dart        # API 端点常量
  init.dart       # Request 单例（Dio 配置）
  interceptor.dart # 拦截器（认证、错误处理）
  constants.dart  # HTTP 常量（Base URL 等）
  <module>.dart   # 按模块的 HTTP 方法（video.dart、user.dart 等）
```

## 3. 关键文件说明

| 文件 | 职责 | 重要性 |
|------|------|--------|
| `lib/main.dart` | 应用入口、初始化 | ⭐⭐⭐ |
| `lib/router/app_pages.dart` | 路由定义（60+ 路由） | ⭐⭐⭐ |
| `lib/http/init.dart` | Request 单例（Dio） | ⭐⭐⭐ |
| `lib/http/api.dart` | API 端点常量 | ⭐⭐⭐ |
| `lib/utils/storage.dart` | Hive 存储管理 | ⭐⭐⭐ |
| `lib/utils/wbi_sign.dart` | WBI 签名（API 鉴权） | ⭐⭐⭐ |
| `lib/plugin/pl_player/` | 视频播放器插件 | ⭐⭐⭐ |

## 4. 外部依赖

### 4.1 Bilibili API

项目使用 Bilibili 的 Web API 和 App API：
- **Web API**：`https://api.bilibili.com` — 主要业务接口
- **App API**：`https://app.bilibili.com` — 推荐流等
- **Live API**：`https://api.live.bilibili.com` — 直播相关
- **Passport**：`https://passport.bilibili.com` — 登录认证

### 4.2 API 文档参考

- [bilibili-API-collect](https://github.com/SocialSisterYi/bilibili-API-collect) — 社区维护的 API 文档

## 5. 构建与运行

```bash
# 安装依赖
flutter pub get

# 运行（调试）
flutter run

# 构建 Android APK
flutter build apk --release

# 代码生成（Hive adapters）
flutter packages pub run build_runner build

# 分析代码
flutter analyze

# 运行测试
flutter test
```

## 6. 版本信息

- **Flutter**: 3.41.9 (FVM)
- **Dart SDK**: >=3.0.0 <4.0.0
- **App Version**: 1.0.28+1028

## 7. 模块状态

所有 19 个模块已完成迁移至 `lib/features/`，采用 data/domain/presentation 三层架构：

| 模块 | 路径 | 说明 |
|------|------|------|
| 首页推荐 | `features/home/` | 含推荐和热门 |
| 视频详情 | `features/video/` | 播放器、评论、相关推荐 |
| 搜索 | `features/search/` | 搜索、热搜、搜索建议 |
| 用户中心 | `features/user/` | 关注、粉丝、投稿 |
| 动态 | `features/dynamics/` | 关注动态、转发 |
| 排行榜 | `features/rank/` | 全站排行、分区排行 |
| 直播 | `features/live/` | 直播列表、直播间 |
| 消息 | `features/message/` | 私信、通知 |
| 设置 | `features/setting/` | 应用设置 |
| 登录 | `features/login/` | 登录、注册 |
| App Shell | `features/main/` | 主框架入口 |
| 媒体库 | `features/media/` | 收藏、历史、稍后再看 |
| 关于 | `features/about/` | 应用信息 |
| 黑名单 | `features/blacklist/` | 黑名单管理 |
| 番剧 | `features/bangumi/` | 番剧列表 |
| HTML | `features/html/` | HTML 页面 |
| Opus | `features/opus/` | 专栏文章 |
| Read | `features/read/` | 阅读页面 |
| WebView | `features/webview/` | WebView 页面 |
