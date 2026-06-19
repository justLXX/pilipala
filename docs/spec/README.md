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

### 5. 设计规范 (Design)

位于 `docs/spec/design/`，定义 UI 样式和刷新计划。

包含：
- UI 样式规范
- Clean UI 刷新计划

## 阅读指南

### 如果你是新开发者
1. 先读 `architecture/01-overview.md` 了解系统架构
2. 再读你负责的 `features/<module>/spec.md` 了解功能需求
3. 参考 `architecture/` 中的技术规范进行开发

### 如果你要添加新功能
1. 在 `features/` 下创建新的功能模块 Spec
2. 如有新增 API，在 `api/` 下补充文档
3. 实现代码后更新相关 Spec

### 如果你要修改现有功能
1. 先找到对应的 `features/<module>/spec.md`
2. 修改 Spec 中的相关描述
3. 按 Spec 修改代码

## 模块状态

所有 19 个模块已完成迁移至 `lib/features/`，采用 data/domain/presentation 三层架构：

| 模块 | Spec 路径 | 代码路径 | 说明 |
|------|----------|----------|------|
| 首页推荐 | `features/home/` | `lib/features/home/` | 含推荐和热门 |
| 视频详情 | `features/video/` | `lib/features/video/` | 播放器、评论、相关推荐 |
| 搜索 | `features/search/` | `lib/features/search/` | 搜索、热搜、搜索建议 |
| 用户中心 | `features/user/` | `lib/features/user/` | 关注、粉丝、投稿 |
| 动态 | `features/dynamics/` | `lib/features/dynamics/` | 关注动态、转发 |
| 排行榜 | `features/rank/` | `lib/features/rank/` | 全站排行、分区排行 |
| 直播 | `features/live/` | `lib/features/live/` | 直播列表、直播间 |
| 消息 | `features/message/` | `lib/features/message/` | 私信、通知 |
| 设置 | `features/setting/` | `lib/features/setting/` | 应用设置 |
| 登录 | `features/login/` | `lib/features/login/` | 登录、注册 |
| App Shell | — | `lib/features/main/` | 主框架入口 |
| 媒体库 | `features/media/` | `lib/features/media/` | 收藏、历史、稍后再看 |
| 关于 | — | `lib/features/about/` | 应用信息 |
| 黑名单 | — | `lib/features/blacklist/` | 黑名单管理 |
| 番剧 | — | `lib/features/bangumi/` | 番剧列表 |
| HTML | — | `lib/features/html/` | HTML 页面 |
| Opus | — | `lib/features/opus/` | 专栏文章 |
| Read | — | `lib/features/read/` | 阅读页面 |
| WebView | — | `lib/features/webview/` | WebView 页面 |

## 维护规范

- **Spec 先行**：新增功能时先写 Spec，再写代码
- **同步更新**：修改代码时同步更新对应 Spec
- **Code Review**：PR 中需包含 Spec 变更说明
- **版本管理**：Spec 与代码版本保持一致

## 相关文档

- [架构概览](architecture/01-overview.md)
- [API 规范](api/README.md)
- [测试策略](testing/strategy.md)
- [UI 样式规范](design/ui-style-spec.md)
