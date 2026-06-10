# PiliPala 架构设计文档

## 1. 系统概览

### 1.1 项目简介

PiliPala 是一个基于 Flutter 的第三方 Bilibili 客户端，采用 GetX 状态管理框架，使用 Dio 进行 HTTP 通信，Hive 进行本地数据持久化。

### 1.2 技术栈

| 层级 | 技术选型 | 说明 |
|------|---------|------|
| UI 框架 | Flutter 3.19.6 | 跨平台移动应用框架 |
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
├── features/        # 新功能模块（data/domain/presentation 三层架构）
│   ├── home/        #   首页推荐 + 热门
│   ├── login/       #   登录
│   ├── media/       #   媒体库
│   ├── search/      #   搜索
│   ├── user/        #   用户中心
│   └── video/       #   视频详情
├── http/            # HTTP 层（API、请求初始化、拦截器）
├── models/          # 数据模型（按业务域分组）
├── pages/           # 旧页面（待迁移到 features/）
├── plugin/          # 可复用插件（播放器、画廊等）
├── router/          # 路由配置
├── scripts/         # 脚本
├── services/        # 服务（音频、电池优化等）
├── shared/          # 共享组件
└── utils/           # 工具类
```

> **迁移说明**：项目正在从 `lib/pages/`（扁平结构）迁移到 `lib/features/`（三层架构）。
> 当前 6 个模块已迁移，48 个目录待迁移。详见 [Spec README](../README.md) 的迁移状态表。

### 2.2 features 目录规范（新架构）

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

### 2.3 pages 目录规范（旧架构，待迁移）

```
pages/<feature>/
  index.dart      # 导出文件（export controller + view）
  controller.dart # GetxController，业务逻辑
  view.dart       # StatelessWidget/StatefulWidget，UI 渲染
  widgets/        # 页面级子组件
```

### 2.4 模型目录规范

```
models/
  common/         # 通用枚举、配置（主题、类型等）
  <domain>/       # 按业务域分组
    <entity>.dart # 数据实体
```

### 2.5 HTTP 目录规范

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

- **Flutter**: 3.19.6 (stable)
- **Dart SDK**: >=3.0.0 <4.0.0
- **App Version**: 1.0.28+1028

## 7. 迁移进度

### 7.1 整体状态

| 层级 | 旧架构 (`pages/`) | 新架构 (`features/`) | 状态 |
|------|-------------------|---------------------|------|
| 路由层 | `app_pages.dart` 引用旧页面 | 已切换到 features 页面 | ✅ 已切换 |
| 底部导航 | `nav_bar_config.dart` 引用旧页面 | 未切换 | ❌ 未切换 |
| 启动注册 | `main/view.dart` 注册旧 Controller | 未切换 | ❌ 未切换 |
| 依赖注入 | `dependency_injection.dart` 只注册核心服务 | 未注册 feature 层 | ❌ 未连接 |

### 7.2 模块迁移状态

**已迁移模块（6个）**：

| 模块 | 路径 | 完成度 | 文件数 | 路由接入 | 状态 |
|------|------|--------|--------|----------|------|
| 首页推荐 | `features/home/` | ✅ 100% | 7 | ✅ `/` `/hot` | ✅ CSRF已修复，HotPage/RcmdPage共用HomeController |
| 视频详情 | `features/video/` | ✅ 100% | 7 | ✅ `/video` | ✅ CSRF已修复，点赞/收藏API已调用，播放器widget待集成 |
| 搜索 | `features/search/` | ✅ 100% | 8 | ✅ `/search` | ✅ Controller命名已修复，搜索结果UI已添加 |
| 用户中心 | `features/user/` | ✅ 100% | 9 | ✅ `/member` | ✅ coins/likes/seasons widgets已集成 |
| 媒体库 | `features/media/` | ~65% | 5 | ❌ 未注册 | 收藏 tab 空实现；子路由未注册 |
| 登录 | `features/login/` | ~45% | 4 | ❌ 未注册 | 无 UI；SMS/QR 登录 UseCase 缺失；token 持久化 TODO |

**待迁移模块（49个）**：

- **有 Spec（5个）**：热门排行、动态、直播、消息、设置
- **无 Spec（44个）**：详见 [Spec README](../README.md) 的功能模块列表

### 7.3 迁移策略

1. **优先级排序**：
   - P0：热门排行（归入 `features/home/`）
   - P1：动态、直播、消息
   - P2：设置、媒体库子模块

2. **迁移步骤**：
   - 创建 `features/<module>/` 三层结构
   - 迁移 Controller 逻辑到 UseCase/Repository
   - 迁移 View 到 presentation 层
   - 注册路由和依赖注入
   - 清理旧 `pages/` 代码

3. **注意事项**：
   - 保持向后兼容，旧代码暂时保留
   - 优先修复 CSRF token 问题
   - 确保新旧代码共存期间不破坏现有功能
