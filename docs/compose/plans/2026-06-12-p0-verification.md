# P0 模块完整性验证计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 验证 6 个 P0 模块（home, video, search, user, dynamics, rank）是否真正达到 100% 完成度，找出遗漏

**Architecture:** 逐模块检查 data/domain/presentation 三层结构、路由绑定、依赖注入、widgets 完整性、TODO/FIXME 标记

**Tech Stack:** Flutter, GetX, Hive

---

## 模块结构总览

| Module | data/ | domain/ | presentation/ | widgets | Route | DI Binding |
|--------|-------|---------|---------------|---------|-------|------------|
| home | ✅ | ✅ | ✅ 4文件 | ❌ 无widgets | ✅ | ✅ |
| video | ✅ | ✅ | ✅ 2文件+widgets | ✅ 7文件 | ✅ | ✅ |
| search | ✅ | ✅ | ✅ 2文件+widgets | ✅ 3文件 | ✅ | ✅ |
| user | ✅ | ✅ | ✅ 2文件+widgets | ✅ 4文件 | ✅ | ✅ |
| dynamics | ✅ | ✅ | ✅ 3文件+widgets | ✅ 13文件 | ✅ | ✅ |
| rank | ✅ | ✅ | ✅ 2文件+widgets | ✅ 1文件 | ✅ | ✅ |

---

## 发现的问题

### 问题 1：home 模块缺少 widgets/ 目录
- 其他 5 个 P0 模块都有 `presentation/widgets/`
- home 模块的 rcmd_page.dart 和 hot_page.dart 可能有内联 widget 需要抽取

### 问题 2：dynamics 模块有 2 个 TODO
- `rich_node_panel.dart:183` — `TODO 商品`（商品面板未实现）
- `additional_panel.dart:7` — `TODO 点击跳转`（附加面板点击跳转未实现）

### 问题 3：旧代码未清理
- `lib/pages/home/` 仍存在（含 controller.dart, index.dart, view.dart, widgets/）
- `lib/pages/video/` 仍存在（含 detail/ 子目录）
- `lib/pages/search/` 仍存在
- `lib/pages/member/` 仍存在
- `lib/pages/dynamics/` 仍存在
- `lib/pages/rank/` 仍存在

---

## 验证任务

### Task 1: 验证 home 模块 widgets 完整性

**Covers:** home 模块 presentation 层

**Files:**
- Read: `lib/features/home/presentation/home_page.dart`
- Read: `lib/features/home/presentation/hot_page.dart`
- Read: `lib/features/home/presentation/rcmd_page.dart`

- [ ] **Step 1: 检查 home_page.dart 是否有内联 widget**

读取文件，检查是否有匿名类或需要抽取的 widget。

- [ ] **Step 2: 检查 hot_page.dart 是否有内联 widget**

读取文件，检查是否有匿名类或需要抽取的 widget。

- [ ] **Step 3: 检查 rcmd_page.dart 是否有内联 widget**

读取文件，检查是否有匿名类或需要抽取的 widget。

- [ ] **Step 4: 记录发现**

如果发现内联 widget，记录文件和行号。

---

### Task 2: 评估 dynamics TODO 优先级

**Covers:** dynamics 模块待办事项

**Files:**
- Read: `lib/features/dynamics/presentation/widgets/rich_node_panel.dart:180-190`
- Read: `lib/features/dynamics/presentation/widgets/additional_panel.dart:1-15`

- [ ] **Step 1: 读取 rich_node_panel.dart 的 TODO 上下文**

```dart
// Line 183 附近
/// TODO 商品
```

判断：这是功能缺失还是仅注释？

- [ ] **Step 2: 读取 additional_panel.dart 的 TODO 上下文**

```dart
// Line 7 附近
/// TODO 点击跳转
```

判断：这是功能缺失还是仅注释？

- [ ] **Step 3: 评估是否需要在 P0 阶段修复**

如果 TODO 是功能缺失，需要评估是否影响核心流程。

---

### Task 3: 验证路由绑定完整性

**Covers:** 所有 P0 模块的路由和 DI

**Files:**
- Read: `lib/router/app_pages.dart`
- Read: `lib/router/bindings.dart`

- [ ] **Step 1: 确认 home 模块路由**

检查 `/home` 和 `/hot` 是否指向 features/home/ 的页面。

- [ ] **Step 2: 确认 video 模块路由**

检查 `/video` 是否指向 features/video/ 的页面。

- [ ] **Step 3: 确认 search 模块路由**

检查 `/search` 是否指向 features/search/ 的页面。

- [ ] **Step 4: 确认 user 模块路由**

检查 `/member` 是否指向 features/user/ 的页面。

- [ ] **Step 5: 确认 dynamics 模块路由**

检查 `/dynamics` 和 `/dynamicDetail` 是否指向 features/dynamics/ 的页面。

- [ ] **Step 6: 确认 rank 模块路由**

检查是否有 `/rank` 路由指向 features/rank/ 的页面。

- [ ] **Step 7: 确认所有 Binding 已注册**

检查 HomeBinding, VideoDetailBinding, SearchBinding, UserBinding, DynamicsBinding, RankBinding 是否存在且注册了正确的 Repository/UseCase/Controller。

---

### Task 4: 验证旧代码清理需求

**Covers:** 技术债务评估

**Files:**
- Read: `lib/pages/home/`
- Read: `lib/pages/video/`
- Read: `lib/pages/search/`
- Read: `lib/pages/member/`
- Read: `lib/pages/dynamics/`
- Read: `lib/pages/rank/`

- [ ] **Step 1: 检查 pages/home/ 是否仍被引用**

搜索 `import.*pages/home` 确认是否有代码仍引用旧模块。

- [ ] **Step 2: 检查 pages/video/ 是否仍被引用**

搜索 `import.*pages/video` 确认是否有代码仍引用旧模块。

- [ ] **Step 3: 检查 pages/search/ 是否仍被引用**

搜索 `import.*pages/search` 确认是否有代码仍引用旧模块。

- [ ] **Step 4: 检查 pages/member/ 是否仍被引用**

搜索 `import.*pages/member` 确认是否有代码仍引用旧模块。

- [ ] **Step 5: 检查 pages/dynamics/ 是否仍被引用**

搜索 `import.*pages/dynamics` 确认是否有代码仍引用旧模块。

- [ ] **Step 6: 检查 pages/rank/ 是否仍被引用**

搜索 `import.*pages/rank` 确认是否有代码仍引用旧模块。

- [ ] **Step 7: 生成清理建议**

列出可以安全删除的旧模块。

---

### Task 5: 运行静态分析验证

**Covers:** 代码质量验证

**Files:** 所有 P0 模块

- [ ] **Step 1: 运行 flutter analyze**

```bash
cd /Users/liyuan/workspace/pilipala && flutter analyze lib/features/home lib/features/video lib/features/search lib/features/user lib/features/dynamics lib/features/rank
```

预期：0 errors，可能有 warnings（unused import 等）

- [ ] **Step 2: 记录分析结果**

列出所有 errors 和关键 warnings。

---

## 验证完成标准

- [ ] 所有 6 个模块的三层结构完整
- [ ] 所有路由和 DI 绑定正确
- [ ] TODO/FIXME 已评估优先级
- [ ] 旧代码引用情况已确认
- [ ] flutter analyze 无 errors
