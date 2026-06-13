# User 子页面迁移计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 user 子页面从 pages/ 迁移到 features/user/presentation/

**Architecture:** 采用 data/domain/presentation 三层架构，复用现有 UserUseCases

**Tech Stack:** Flutter, GetX, Hive

---

## 已完成

| 子页面 | 状态 | 文件 |
|--------|------|------|
| fan | ✅ 已迁移 | fan_controller.dart, fan_page.dart |
| follow | ✅ 已迁移 | follow_controller.dart, follow_page.dart |

## 待迁移

| 子页面 | 旧路径 | 新路径 | 优先级 |
|--------|--------|--------|--------|
| follow_search | `pages/follow_search/` | `features/user/presentation/follow_search/` | P1 |
| member_archive | `pages/member_archive/` | `features/user/presentation/member_archive/` | P1 |
| member_article | `pages/member_article/` | `features/user/presentation/member_article/` | P1 |
| member_coin | `pages/member_coin/` | `features/user/presentation/member_coin/` | P1 |
| member_dynamics | `pages/member_dynamics/` | `features/user/presentation/member_dynamics/` | P1 |
| member_like | `pages/member_like/` | `features/user/presentation/member_like/` | P1 |
| member_search | `pages/member_search/` | `features/user/presentation/member_search/` | P1 |
| member_seasons | `pages/member_seasons/` | `features/user/presentation/member_seasons/` | P1 |
| mine | `pages/mine/` | `features/user/presentation/mine/` | P2 |

---

## Task 1: 迁移 follow_search 页面

**Covers:** follow_search 子功能

**Files:**
- Create: `lib/features/user/presentation/follow_search/follow_search_controller.dart`
- Create: `lib/features/user/presentation/follow_search/follow_search_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 FollowSearchController**

从 `pages/follow_search/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 FollowSearchPage**

从 `pages/follow_search/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/followSearch` 指向新的 features 页面。

---

## Task 2: 迁移 member_archive 页面

**Covers:** member_archive 子功能

**Files:**
- Create: `lib/features/user/presentation/member_archive/member_archive_controller.dart`
- Create: `lib/features/user/presentation/member_archive/member_archive_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberArchiveController**

从 `pages/member_archive/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberArchivePage**

从 `pages/member_archive/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberArchive` 指向新的 features 页面。

---

## Task 3: 迁移 member_article 页面

**Covers:** member_article 子功能

**Files:**
- Create: `lib/features/user/presentation/member_article/member_article_controller.dart`
- Create: `lib/features/user/presentation/member_article/member_article_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberArticleController**

从 `pages/member_article/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberArticlePage**

从 `pages/member_article/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberArticle` 指向新的 features 页面。

---

## Task 4: 迁移 member_coin 页面

**Covers:** member_coin 子功能

**Files:**
- Create: `lib/features/user/presentation/member_coin/member_coin_controller.dart`
- Create: `lib/features/user/presentation/member_coin/member_coin_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberCoinController**

从 `pages/member_coin/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberCoinPage**

从 `pages/member_coin/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberCoin` 指向新的 features 页面。

---

## Task 5: 迁移 member_dynamics 页面

**Covers:** member_dynamics 子功能

**Files:**
- Create: `lib/features/user/presentation/member_dynamics/member_dynamics_controller.dart`
- Create: `lib/features/user/presentation/member_dynamics/member_dynamics_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberDynamicsController**

从 `pages/member_dynamics/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberDynamicsPage**

从 `pages/member_dynamics/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberDynamics` 指向新的 features 页面。

---

## Task 6: 迁移 member_like 页面

**Covers:** member_like 子功能

**Files:**
- Create: `lib/features/user/presentation/member_like/member_like_controller.dart`
- Create: `lib/features/user/presentation/member_like/member_like_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberLikeController**

从 `pages/member_like/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberLikePage**

从 `pages/member_like/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberLike` 指向新的 features 页面。

---

## Task 7: 迁移 member_search 页面

**Covers:** member_search 子功能

**Files:**
- Create: `lib/features/user/presentation/member_search/member_search_controller.dart`
- Create: `lib/features/user/presentation/member_search/member_search_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberSearchController**

从 `pages/member_search/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberSearchPage**

从 `pages/member_search/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberSearch` 指向新的 features 页面。

---

## Task 8: 迁移 member_seasons 页面

**Covers:** member_seasons 子功能

**Files:**
- Create: `lib/features/user/presentation/member_seasons/member_seasons_controller.dart`
- Create: `lib/features/user/presentation/member_seasons/member_seasons_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MemberSeasonsController**

从 `pages/member_seasons/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MemberSeasonsPage**

从 `pages/member_seasons/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/memberSeasons` 指向新的 features 页面。

---

## Task 9: 迁移 mine 页面

**Covers:** mine 子功能

**Files:**
- Create: `lib/features/user/presentation/mine/mine_controller.dart`
- Create: `lib/features/user/presentation/mine/mine_page.dart`
- Modify: `lib/router/app_pages.dart` (更新路由)

- [ ] **Step 1: 创建 MineController**

从 `pages/mine/controller.dart` 复制并适配 imports。

- [ ] **Step 2: 创建 MinePage**

从 `pages/mine/view.dart` 复制并适配 imports。

- [ ] **Step 3: 更新路由**

在 `app_pages.dart` 中将 `/mine` 指向新的 features 页面。

---

## Task 10: 更新路由和绑定

**Covers:** 路由和依赖注入

**Files:**
- Modify: `lib/router/app_pages.dart` (更新所有路由)
- Modify: `lib/router/bindings.dart` (更新绑定)

- [ ] **Step 1: 更新 app_pages.dart imports**

添加所有新的 features 页面 imports。

- [ ] **Step 2: 更新路由定义**

将所有 `/fan`, `/follow`, `/followSearch`, `/memberArchive`, `/memberArticle`, `/memberCoin`, `/memberDynamics`, `/memberLike`, `/memberSearch`, `/memberSeasons`, `/mine` 路由指向新的 features 页面。

- [ ] **Step 3: 更新文档**

更新 README.md, AGENTS.md, docs/spec/README.md 反映迁移完成。

---

## 完成标准

- [ ] 所有子页面已迁移到 features/user/presentation/
- [ ] 路由已更新
- [ ] flutter analyze 无 errors
- [ ] 文档已更新
