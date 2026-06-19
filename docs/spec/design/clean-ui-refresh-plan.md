# Clean UI Refresh Plan

## 背景

本轮 UI 改造目标是将 PiliPala 调整为更整洁、清爽、内容优先的视觉方向。当前 Web 示意稿位于：

- `docs/spec/design/clean-ui-prototype/index.html`

该示意稿用于明确视觉方向，不要求逐像素还原。Flutter 实现应遵循 Material 3、现有数据结构和现有交互约定。

## 目标

1. 底部导航只保留三个一级 tab：`首页`、`动态`、`我的`。
2. 首页改为清爽内容流：轻搜索、频道 tab、双列视频卡片、低干扰底栏。
3. 视频详情页改为清晰阅读层级：播放器优先、标题/数据紧凑、UP 主信息明确、互动区轻量、评论和推荐有稳定分隔。
4. 抽取可复用 UI token 和基础组件，避免每页重复写样式。
5. 不改变核心业务能力、路由能力和登录/收藏/稍后再看等数据行为。

## 非目标

1. 不重写播放器内核。
2. 不替换 GetX、路由、存储、网络层。
3. 不在本轮清理所有 legacy `lib/pages/`。
4. 不一次性改完整个 App 的所有页面。
5. 不引入大型 UI 框架或额外设计系统依赖。

## 设计原则

### 视觉

- 页面背景使用浅色 `surface`，避免大面积渐变和强装饰。
- 主色使用低饱和绿色，只用于选中态、主按钮、链接、轻 badge。
- 视频封面和标题是第一主角，容器尽量克制。
- 列表项不使用厚重阴影；必要时只使用轻边线或留白分隔。
- 圆角统一：小组件 8-10，封面 12-16，底栏选中胶囊 999。

### 信息密度

- 首页保持双列信息流。
- 视频标题最多 2 行，元信息弱化。
- 详情页标题可 2-3 行，数据和日期放在标题下方一行。
- 评论与推荐区保持可扫读，不使用嵌套卡片。

### 交互

- 原有点击行为保持不变。
- 首页搜索仍跳转 `/search`。
- 首页频道 tab 继续承载现有推荐/热门，后续可扩展直播/番剧。
- 底栏 tab 保持 44px 以上点击目标。
- 视频详情页互动按钮保留现有点赞、投币、收藏、分享、评论能力。

## 导航改造

### 底部导航

`lib/models/common/nav_bar_config.dart`

保留：

| id | label | page |
| --- | --- | --- |
| 0 | 首页 | `HomePage` |
| 2 | 动态 | `DynamicsPage` |
| 3 | 我的 | `MinePage` |

移除一级 tab：

- `排行榜`
- 独立 `媒体库`

媒体库功能已经集成进 `我的`，后续保持在“我的”页内作为内容区或入口组。

### 设置兼容

涉及 `navBarSort` 和 `defaultHomePage` 的设置页必须兼容旧存储：

- 如果旧配置包含 id `1`，启动时过滤掉。
- 如果旧默认页是 id `1`，回退到 `0`。
- 如果旧配置缺少 `2` 或 `3`，不强行恢复，除非用户重置设置。

## 首页改造

### 文件范围

- `lib/features/home/presentation/home_page.dart`
- `lib/features/home/presentation/rcmd_page.dart`
- `lib/features/home/presentation/hot_page.dart`
- 可新增：`lib/features/home/presentation/widgets/`

### 页面结构

```text
HomePage
├── SafeArea / NestedScrollView
├── 清爽顶部区
│   ├── 搜索胶囊
│   ├── 用户头像入口
│   └── 频道 tabs
└── TabBarView
    ├── 推荐双列视频流
    └── 热门双列视频流
```

### 组件要求

#### 搜索胶囊

- 高度 42-44。
- 背景使用 `surfaceContainerHighest` 或自定义浅绿色透明层。
- 左侧 search icon，文案 `搜索视频、UP 主或番剧`。
- 点击跳转 `/search`。

#### 频道 tabs

- 使用圆角胶囊样式，而不是强下划线。
- 选中态：浅绿色背景 + primary 文本。
- 未选中态：透明背景 + outline 文本。

#### 视频卡片

建议抽取 `CleanVideoCard`：

- 封面比例 16:10。
- 圆角 12-16。
- 右下角时长 badge。
- 标题最多 2 行。
- 元信息一行：UP 主 / 播放量 / 时间。
- 已关注、番剧等语义 badge 使用浅主色，不大面积填色。

### 空态与错误态

- 加载中保留现有 skeleton 或简洁占位。
- 错误态保留重试按钮，但视觉轻量化。
- 空态文案短句即可，不添加大插画。

## 动态页改造

### 本轮范围

动态页本轮只作为底部 tab 保留，不做完整视觉重构。

### 后续要求

后续改造动态页时应延续同一套 token：

- 顶部筛选使用轻胶囊。
- 动态卡片减少边框和阴影。
- 图片网格圆角统一。
- 操作栏弱化，只在互动后使用 primary。

## 我的页改造

### 文件范围

- `lib/features/user/presentation/mine/mine_page.dart`
- `lib/features/media/presentation/media_page.dart`
- 可新增：`lib/features/user/presentation/mine/widgets/`

### 结构

```text
MinePage
├── 顶部个人信息
│   ├── 头像
│   ├── 昵称 / 登录入口
│   ├── 关注 / 粉丝 / 动态
│   └── 设置、主题切换
├── 媒体库入口组
│   ├── 离线缓存
│   ├── 观看记录
│   ├── 我的收藏
│   ├── 我的订阅
│   └── 稍后再看
└── 收藏夹预览
```

### 要求

- “我的”作为最后一个 tab。
- 媒体库功能不再作为一级 tab，但功能入口保留。
- 页面整体可滚动，避免原来不可滚动导致内容截断。
- 登录状态变化后同步刷新用户信息和收藏夹。

## 视频详情页改造

### 文件范围

- `lib/features/video/presentation/video_detail_page.dart`
- `lib/features/video/presentation/video_detail_controller.dart`（只在必要时调整 UI 状态，不做业务重写）
- 可新增：`lib/features/video/presentation/widgets/`

### 页面结构

```text
VideoDetailPage
├── 播放器区域
├── 标题与数据
├── UP 主信息行
├── 互动操作行
├── 简介 / 评论 tabs 或直接评论预览
├── 评论列表
└── 相关推荐
```

### 播放器

- 保持播放器能力和手势不变。
- 视觉上减少播放器下方的强分割。
- 横屏、竖屏逻辑不在本轮重写。

### 标题与元信息

- 标题使用 `titleMedium` 或 `titleLarge`，最多 2-3 行。
- 播放量、弹幕数、发布时间弱化为一行。
- 展开简介使用轻量文字按钮。

### UP 主信息

- 头像 40-44。
- 昵称加粗。
- 粉丝/签名弱化。
- 关注按钮使用 primary 胶囊。

### 互动区

- 点赞、投币、收藏、分享、评论横向均分。
- 图标线性化。
- 数字使用 `labelMedium`。
- 已选中态使用 primary，不使用大面积背景。

### 评论和推荐

- 区块标题左侧标题，右侧可选入口。
- 评论项不使用卡片，使用头像 + 名称 + 正文。
- 推荐视频使用横向列表项：左封面，右标题和元信息。

## 公共组件与 Token

### 建议新增/整理

- `lib/common/widgets/clean_search_bar.dart`
- `lib/common/widgets/clean_section_header.dart`
- `lib/common/widgets/clean_video_card.dart`
- `lib/common/widgets/clean_video_list_tile.dart`

### 样式来源

优先使用：

- `Theme.of(context).colorScheme`
- `Theme.of(context).textTheme`
- `StyleString` 中已有间距和圆角

必要时补充：

- `cleanRadiusSm = 10`
- `cleanRadiusMd = 14`
- `cleanRadiusLg = 18`
- `cleanHorizontalPadding = 14`

## 实施阶段

### Phase 1：导航收敛

1. 修改 `defaultNavigationBars` 为三 tab。
2. 调整旧 `navBarSort` / `defaultHomePage` 兼容逻辑。
3. 确认底栏设置页不再展示排行榜。
4. 验证：首页、动态、我的可切换，动态未读 badge 正常。

### Phase 2：首页清爽化

1. 抽取搜索胶囊和频道 tab 样式。
2. 抽取 `CleanVideoCard`。
3. 改造 `RcmdPage` 和 `HotPage` 的 grid item。
4. 保留刷新、加载更多、错误重试。
5. 验证横竖屏、窄屏、文本缩放。

### Phase 3：我的页整理

1. 整理 MinePage 顶部布局。
2. 保留并清爽化媒体库入口组。
3. 清爽化收藏夹预览。
4. 验证登录、退出登录、收藏夹刷新。

### Phase 4：视频详情页清爽化

1. 梳理 `VideoDetailPage` 现有 widget 边界。
2. 抽取标题信息区、UP 主区、互动区。
3. 调整评论和推荐区样式。
4. 确认播放器、评论、点赞投币收藏等行为不回归。

### Phase 5：QA 与收尾

1. `dart format`。
2. `flutter analyze`。
3. `flutter test`，至少跑现有单测。
4. 真机或模拟器检查首页、动态、我的、视频详情。
5. 更新截图或录屏作为视觉验收资料。

## 验收标准

### 功能

- 底部只显示：首页、动态、我的。
- 首页推荐/热门可刷新、加载更多、进入视频详情。
- 动态 tab 可进入并清未读。
- 我的页登录态、设置入口、媒体库入口、收藏夹预览可用。
- 视频详情页播放、互动、评论、相关推荐入口不回归。

### 视觉

- 浅色模式下页面清爽，没有大面积高饱和色块。
- 暗色模式下背景层级清楚，文字对比足够。
- 视频封面、标题、元信息层级清晰。
- 不出现文字重叠、溢出、底栏遮挡。
- 点击目标不小于 44px。

### 工程

- 不新增 analyzer error。
- 不引入未使用依赖。
- 不改动无关业务逻辑。
- 新组件命名清晰，可在其他页面复用。

## 风险与处理

| 风险 | 处理 |
| --- | --- |
| 旧用户 `navBarSort` 保存了排行榜 id | 启动时过滤无效 id |
| 默认启动页指向被移除 tab | 回退首页 |
| 视频详情页文件较大，容易误改业务 | 先抽 UI widget，再逐块替换 |
| 首页列表卡片高度变化导致瀑布不齐 | 固定封面比例和标题最大行数 |
| 暗色模式对比不足 | 使用 `ColorScheme`，避免硬编码浅色 |

## 待确认

1. 首页频道是否只保留 `推荐 / 热门`，还是先显示 `推荐 / 热门 / 直播 / 番剧` 但后两者暂不接入？
2. “排行榜”是否完全从一级入口移除，还是放到首页某个频道或搜索页入口？
3. 视频详情页是否保留当前 `简介 / 评论` tab 结构，还是改成标题区下直接显示评论预览？
