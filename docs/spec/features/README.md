# 功能需求规格书

## 概述

本文档按用户可见的功能模块组织，每个模块包含独立的功能需求规格书。

## 功能模块列表

| 模块 | Spec 路径 | 代码路径 | 页面 | 代码状态 | 优先级 |
|------|----------|----------|------|----------|--------|
| 首页推荐 | `features/home/` | `lib/features/home/` | HomePage, RcmdPage | ✅ 已迁移 (100%) | P0 |
| 热门排行 | `features/hot/` | `lib/features/home/` + `lib/features/rank/` | HotPage, RankPage | ✅ 已迁移 (热门在home, 排行榜独立) | P0 |
| 视频详情 | `features/video/` | `lib/features/video/` | VideoDetailPage | ✅ 已迁移 (100%) | P0 |
| 搜索 | `features/search/` | `lib/features/search/` | SearchPage | ✅ 已迁移 (100%) | P0 |
| 动态 | `features/dynamics/` | `lib/features/dynamics/` | DynamicsPage, DynamicDetailPage | ✅ 已迁移 (95%) | P1 |
| 用户中心 | `features/user/` | `lib/features/user/` | MemberPage | ✅ 已迁移 (100%) | P1 |
| 媒体库 | `features/media/` | `lib/features/media/` | MediaPage | ✅ 已迁移 (~65%) | P1 |
| 消息 | `features/message/` | `lib/pages/message/` | Message 相关页面 | ❌ 未迁移（有 spec） | P1 |
| 直播 | `features/live/` | `lib/pages/live/` | LivePage, LiveRoomPage | ❌ 未迁移（有 spec） | P1 |
| 设置 | `features/setting/` | `lib/pages/setting/` | SettingPage 及子页面 | ❌ 未迁移（有 spec） | P2 |
| 登录 | `features/login/` | `lib/features/login/` | LoginPage | ✅ 已迁移 (~45%) | P2 |
| App Shell | — | `lib/features/main/` | MainApp | ✅ 已迁移 (90%) | P0 |

## 模块依赖关系

```
首页推荐 ──┬── 视频详情 ──┬── 评论
           │              ├── 用户中心
           │              └── 相关推荐
           │
热门排行 ──┘

搜索 ──────┬── 搜索结果 ── 视频详情
           └── 热搜

动态 ────── 视频详情 / 用户中心

用户中心 ──┬── 关注列表
           ├── 粉丝列表
           ├── 用户投稿
           └── 用户动态

媒体库 ────┬── 稍后再看
           ├── 历史记录
           └── 收藏夹

消息 ──────┬── 回复我的
           ├── @我的
           ├── 收到的赞
           └── 系统通知

直播 ────── 直播间
```

## Spec 模板

每个功能模块的 Spec 应包含以下部分：

```markdown
# <模块名称> 功能规格书

## 1. 功能描述

## 2. 用户流程

## 3. 页面清单

## 4. Controller 职责

## 5. 数据模型

## 6. API 依赖

## 7. 状态管理

## 8. 注意事项
```

## 阅读指南

- **P0 模块**：核心功能，必须优先实现和维护
- **P1 模块**：重要功能，影响用户体验
- **P2 模块**：辅助功能，可后续完善
