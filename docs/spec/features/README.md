# 功能需求规格书

## 概述

本文档按用户可见的功能模块组织，每个模块包含独立的功能需求规格书。

## 功能模块列表

| 模块 | Spec 路径 | 代码路径 | 页面 | 代码状态 | 优先级 |
|------|----------|----------|------|----------|--------|
| 首页推荐 | `features/home/spec.md` | `lib/features/home/` | HomePage, RcmdPage, HotPage | ✅ 已完成 (100%) | P0 |
| 视频详情 | `features/video/spec.md` | `lib/features/video/` | VideoDetailPage | ✅ 已完成 (100%) | P0 |
| 搜索 | `features/search/spec.md` | `lib/features/search/` | SearchPage | ✅ 已完成 (100%) | P0 |
| 用户中心 | `features/user/spec.md` | `lib/features/user/` | MemberPage, MinePage | ✅ 已完成 (100%) | P1 |
| 动态 | `features/dynamics/spec.md` | `lib/features/dynamics/` | DynamicsPage, DynamicDetailPage | ✅ 已完成 (100%) | P1 |
| 媒体库 | `features/media/spec.md` | `lib/features/media/` | MediaPage | ✅ 已完成 (100%) | P1 |
| 登录 | `features/login/spec.md` | `lib/features/login/` | LoginPage | ✅ 已完成 (95%) | P2 |
| 直播 | `features/live/spec.md` | `lib/features/live/` | LivePage, LiveRoomPage | ✅ 已完成 (100%) | P1 |
| 消息 | `features/message/spec.md` | `lib/features/message/` | Whisper, Reply, At, Like, System | ✅ 已完成 (100%) | P1 |
| 设置 | `features/setting/spec.md` | `lib/features/setting/` | SettingPage + 7 个子页面 | ✅ 已完成 (100%) | P2 |
| 热门排行 | `features/hot/spec.md` | `lib/features/home/` + `lib/features/rank/` | HotPage, RankPage | ✅ 已完成 (100%) | P0 |

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
