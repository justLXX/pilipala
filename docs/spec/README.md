# PiliPala Spec 文档体系

## 概述

本文档定义了 PiliPala 项目的 Spec（规格说明）体系，采用**功能优先**的方式组织，旨在为项目的长期维护和迭代提供清晰的参考标准。

## Spec 类型

本项目的 Spec 分为以下几类：

### 1. 功能需求规格书 (Feature Spec)

位于 `docs/spec/features/`，按用户可见的功能模块组织。

每个功能模块的 Spec 包含：
- **功能描述**：该模块做什么
- **用户流程**：用户如何与该模块交互
- **页面清单**：涉及的页面、路由、参数
- **Controller 职责**：状态管理、业务逻辑
- **数据模型**：输入输出数据结构
- **API 依赖**：调用的后端接口
- **状态管理**：GetX 状态流转

### 2. 架构设计文档 (Architecture)

位于 `docs/spec/architecture/`，描述系统的技术架构和规范。

包含：
- 系统概览与模块关系
- 状态管理规范（GetX）
- HTTP 层规范
- 存储规范（Hive）
- 导航规范

### 3. API 接口规范 (API Spec)

位于 `docs/spec/api/`，按模块组织 API 端点文档。

包含：
- API 规范总则
- 各模块 API 端点列表
- 请求/响应格式示例

### 4. 测试规范 (Testing)

位于 `docs/spec/testing/`，定义测试策略和模式。

包含：
- 测试策略（单元/Widget/集成）
- 测试模式和最佳实践

## 阅读指南

### 如果你是新开发者
1. 先读 `architecture/01-overview.md` 了解系统架构
2. 再读你负责的 `features/<module>/spec.md` 了解功能需求
3. 参考 `architecture/` 中的技术规范进行开发

### 如果你要添加新功能
1. 在 `features/` 下创建新的功能模块 Spec
2. 如有新增 API，在 `api/endpoints/` 下补充文档
3. 实现代码后更新相关 Spec

### 如果你要修改现有功能
1. 先找到对应的 `features/<module>/spec.md`
2. 修改 Spec 中的相关描述
3. 按 Spec 修改代码

## 全局待解决问题

以下问题影响所有已迁移模块，需在后续迭代中优先解决：

| 问题 | 影响范围 | 说明 |
|------|----------|------|
| 依赖注入未连接 | 全部 6 个 features 模块 | `core/di/dependency_injection.dart` 只注册了 `ApiClient`、`StorageService`、`ThemeService`，各模块的 Repository/UseCase/Controller 均未注册到 GetX |
| 底部导航栏未切换 | home, media (以及 dynamics, rank) | `nav_bar_config.dart` 和 `main/view.dart` 仍导入旧 `pages/` 路径，底部 4 个 Tab 使用的是旧 Controller |
| CSRF token 未实现 | home, media, user, video | `VideoRepository`、`MediaRepository`、`UserRepository` 中的 `_getCsrf()` 均返回空字符串，POST 请求（点赞、收藏等）无法正常工作 |
| 旧代码未清理 | 全部 6 个 features 模块 | `lib/pages/` 中对应的旧代码仍保留，与 `features/` 新代码并存 |

## 功能模块列表

### 迁移进度总结

**当前状态**：
- ✅ 已迁移模块：6个（home, video, search, user, media, login）
- ✅ **已完成模块：4个（home, video, search, user）达到100%完成度**
- ⏳ 待迁移模块：49个（其中5个有Spec，44个无Spec）
- 📁 总文件数：40个 Dart 文件在 features 目录
- 🚧 路由接入：4个模块已接入，2个模块未注册
- ✅ CSRF Token：已修复，所有POST请求可正常携带token

### 已重构模块 (lib/features/)

采用 data/domain/presentation 三层架构重构的模块。**全部 6 个模块当前 0 error**（仅存在 unused import/field 等 warning）：

| 模块 | 路径 | 完成度 | 文件数 | 路由接入 | 说明 |
|------|------|--------|--------|----------|------|
| 首页推荐 | `features/home/` | ✅ 100% | 7 | ✅ `/` `/hot` | ✅ CSRF已修复；三层结构完整；HotPage + RcmdPage 共用 HomeController |
| 视频详情 | `features/video/` | ✅ 100% | 7 | ✅ `/video` | ✅ CSRF已修复；点赞/收藏API已调用；三层结构完整 |
| 搜索 | `features/search/` | ✅ 100% | 8 | ✅ `/search` | ✅ Controller命名已修复为`PiliSearchController`；搜索结果UI已添加 |
| 用户中心 | `features/user/` | ✅ 100% | 9 | ✅ `/member` | ✅ coins/likes/seasons widgets已集成；三层结构完整 |
| 媒体库 | `features/media/` | ~65% | 5 | ❌ 未注册 | 三层结构完整，模型/API 已修正；收藏 tab 空实现；子路由未注册 |
| 登录 | `features/login/` | ~45% | 4 | ❌ 未注册 | 三层结构但无 UI；SMS/QR 登录 UseCase 缺失；token 持久化 TODO |

### 待迁移模块 — 有 Spec (lib/pages/)

以下模块已编写功能规格书（`docs/spec/features/`），代码尚未迁移到 `lib/features/`：

| 模块 | pages/ 路径 | 优先级 | 建议归入 | 说明 |
|------|-------------|--------|----------|------|
| 热门排行 | `pages/hot/` + `pages/rank/` | P0 | `features/home/` | 热门已在 home 中，排行榜（rank）待迁入 |
| 动态 | `pages/dynamics/` (+detail, up_dynamic, widgets) | P1 | `features/dynamics/` | 复杂模块：3 controller + 13 widgets |
| 直播 | `pages/live/` + `pages/live_room/` | P1 | `features/live/` | 含 WebSocket 弹幕、播放器集成 |
| 消息 | `pages/message/` + `pages/whisper/` + `pages/whisper_detail/` | P1 | `features/message/` | 通知 + 私信，含空实现 controller (at/) |
| 设置 | `pages/setting/` (+pages/, widgets/) | P2 | `features/setting/` | 以 Hive 读写为主，无 HTTP API 依赖 |

### 待迁移模块 — 无 Spec (lib/pages/)

以下模块既无 spec 也未迁移，按建议归入的 feature 分组：

| 建议归入 | 模块 |
|----------|------|
| **home** | `rcmd/` |
| **user** | `fan/`, `follow/`, `follow_search/`, `member_archive/`, `member_article/`, `member_coin/`, `member_dynamics/`, `member_like/`, `member_search/`, `member_seasons/`, `mine/` |
| **media** | `fav/`, `fav_detail/`, `fav_edit/`, `fav_search/`, `history/`, `history_search/`, `later/`, `subscription/`, `subscription_detail/` |
| **message** | `emote/`, `whisper/`, `whisper_detail/` |
| **video** | `danmaku/`, `dlna/` |
| **独立模块** | `about/`, `bangumi/`, `blacklist/`, `html/`, `opus/`, `read/`, `webview/` |
| **基础设施** | `main/`（App Shell，主框架页面） |

### 已修复的类型/API 映射记录

以下映射关系已在迁移过程中修正，记录在此供后续参考：

| features 中错误引用 | 正确名称 | 所在文件 |
|---------------------|----------|----------|
| `PlayUrlData` | `PlayUrlModel` | `models/video/play/url.dart` |
| `HistoryItem` | `HisListItem` | `models/user/history.dart` |
| `FavFolderItem` | `FavFolderItemData` | `models/user/fav_folder.dart` |
| `FavDetailItem` | `FavDetailItemData` | `models/user/fav_detail.dart` |
| `Api.webLogin` | `Api.loginInByWebPwd` | `http/api.dart` |
| `Api.qrCode` | `Api.qrCodeApi` | `http/api.dart` |
| `Api.qrCodeCheck` | `Api.loginInByQrcode` | `http/api.dart` |
| `Api.collectVideo` | `Api.favVideo`（需 aid+type:2） | `http/api.dart` |
| `Api.toviewWeb` | `Api.seeYouLater` | `http/api.dart` |
| `Api.toviewAdd` | `Api.toViewLater` | `http/api.dart` |
| `Api.toviewDel` | `Api.toViewDel` | `http/api.dart` |
| `Api.mediaList` | `Api.userFavFolderDetail` | `http/api.dart` |

## 维护规范

- **Spec 先行**：新增功能时先写 Spec，再写代码
- **同步更新**：修改代码时同步更新对应 Spec
- **Code Review**：PR 中需包含 Spec 变更说明
- **版本管理**：Spec 与代码版本保持一致

## 相关文档

- [架构概览](architecture/01-overview.md)
- [API 规范](api/README.md)
- [测试策略](testing/strategy.md)
