import 'package:easy_debounce/easy_throttle.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_reply.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/common/widgets/video_card_h.dart';
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_controller.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_input_dialog.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_item.dart';
import 'package:pilipala/features/video/presentation/widgets/reply_reply_panel.dart';
import 'package:pilipala/features/video/presentation/widgets/header_control.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/models/video/view_point.dart';
import 'package:pilipala/pages/danmaku/view.dart';
import 'package:pilipala/plugin/pl_player/index.dart';
import 'package:pilipala/plugin/pl_player/models/play_repeat.dart';
import 'package:pilipala/plugin/pl_player/utils/fullscreen.dart'
    as fullscreen;

/// VideoDetailPage displays the video detail page.
///
/// UI structure is aligned with the legacy VideoDetailPage (lib/pages/video/detail/view.dart).
class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({Key? key}) : super(key: key);

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin, RouteAware {
  late VideoDetailController _vdCtr;
  late String _heroTag;
  final ScrollController _extendNestCtr = ScrollController();
  // 保存离开页面时的播放进度，返回时恢复
  Duration _lastPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    // 使用 tag 隔离每个视频页面的 controller，避免同路由跳转时 controller 被替换
    final bvid = Get.parameters['bvid'] ?? '';
    final cid = Get.parameters['cid'] ?? '0';
    _heroTag = Get.arguments?['heroTag'] ?? '${bvid}_$cid';
    _vdCtr = Get.put(VideoDetailController(), tag: _heroTag);
    _vdCtr.playerController.addStatusLister(_playerStatusListener);
    _vdCtr.playerController.addPositionListener(_playerPositionListener);
    _vdCtr.loadVideoDetail(
      bvid: bvid,
      aid: Get.parameters['aid'] != null
          ? int.parse(Get.parameters['aid']!)
          : null,
    );
  }

    void _playerPositionListener(Duration position) {
    _vdCtr.updateCurrentChapter(position.inSeconds);
  }

  void _playerStatusListener(PlayerStatus status) {
    if (status == PlayerStatus.completed) {
      if (_vdCtr.playerController.isFullScreen.value) {
        _vdCtr.playerController.triggerFullScreen(status: false);
      }
      if (_vdCtr.playerController.playRepeat == PlayRepeat.singleCycle) {
        _vdCtr.playerController.seekTo(Duration.zero);
        _vdCtr.playerController.play();
      }
    }
  }

  @override
  void dispose() {
    VideoDetailPage.routeObserver.unsubscribe(this);
    _vdCtr.playerController.removeStatusLister(_playerStatusListener);
    _vdCtr.playerController.removePositionListener(_playerPositionListener);
    // playerController.dispose() 由 VideoDetailController.onClose() 统一管理，
    // 避免单例 PlPlayerController 的 _playerCount 被双重递减到 0，
    // 导致返回时 reinitPlayer 中 setDataSource 因 _playerCount==0 直接 return
    Get.delete<VideoDetailController>(tag: _heroTag);
    _extendNestCtr.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    VideoDetailPage.routeObserver
        .subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPushNext() {
    // 离开页面：保存进度，移除监听，暂停播放
    if (_vdCtr.playerController.videoPlayerController != null) {
      _lastPosition = _vdCtr.playerController.position.value;
      _vdCtr.playerController.removeStatusLister(_playerStatusListener);
      _vdCtr.playerController.pause();
    }
    super.didPushNext();
  }

  @override
  void didPopNext() {
    // 返回页面：重新初始化播放器，恢复进度
    if (_vdCtr.playerController.videoPlayerController != null &&
        _vdCtr.playUrl != null) {
      _vdCtr.reinitPlayer(seekTo: _lastPosition).then((_) {
        _vdCtr.playerController.addStatusLister(_playerStatusListener);
      });
    } else {
      _vdCtr.playerController.addStatusLister(_playerStatusListener);
    }
    super.didPopNext();
  }

  void _showCoinDialog() {
    Get.defaultDialog(
      title: '投币',
      content: Column(
        children: [
          const Text('选择投币数量'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _vdCtr.toggleCoin(multiply: 1);
                  Get.back();
                },
                child: const Text('1 枚'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  _vdCtr.toggleCoin(multiply: 2);
                  Get.back();
                },
                child: const Text('2 枚'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the player header control (back button overlay on player).
  PreferredSizeWidget _buildPlayerHeader() {
    // Scaffold 的零高度 appBar 已消费安全区，body 从安全区下方开始，
    // 因此此处无需额外添加 topPadding
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        primary: false,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 14,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              onPressed: () {
                if (_vdCtr.playerController.isFullScreen.value) {
                  _vdCtr.playerController.triggerFullScreen(status: false);
                } else if (MediaQuery.of(context).orientation ==
                    Orientation.landscape) {
                  fullscreen.verticalScreen();
                } else {
                  Get.back();
                }
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  /// Compute the pinned header height for ExtendedNestedScrollView.
  /// When playing, return the full pinned height so the video area
  /// does NOT collapse on scroll (same as legacy behavior).
  double _calcPinnedHeaderHeight(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isFullScreen = _vdCtr.playerController.isFullScreen.value;
    if (orientation == Orientation.landscape || isFullScreen) {
      return MediaQuery.sizeOf(context).height;
    }
    // Scaffold 的零高度 appBar 已消费安全区，此处无需加 topPadding
    final videoHeight = MediaQuery.sizeOf(context).width * 9 / 16;
    return kToolbarHeight + videoHeight;
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // 零高度 appBar 消费顶部安全区，使 body 从安全区下方开始，
      // 与旧版行为一致，避免 SliverAppBar 跨越状态栏区域导致滑动抖动
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      body: Obx(() {
        if (_vdCtr.videoDetail != null) {
          return _buildContent(context);
        } else if (_vdCtr.error.isNotEmpty) {
          return _buildError();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    final defaultVideoHeight = MediaQuery.sizeOf(context).width * 9 / 16;

    return ExtendedNestedScrollView(
      controller: _extendNestCtr,
      headerSliverBuilder:
          (BuildContext ctx, bool innerBoxIsScrolled) {
        return <Widget>[
          Obx(() {
            final orientation = MediaQuery.of(context).orientation;
            final isFullScreen =
                _vdCtr.playerController.isFullScreen.value;
            // Scaffold 的零高度 appBar 已消费安全区，body 从安全区下方开始，
            // 因此 expandedHeight 仅需视频高度（与旧版一致）
            final expandedHeight = (orientation == Orientation.landscape ||
                    isFullScreen)
                ? (MediaQuery.sizeOf(context).height -
                    (orientation == Orientation.landscape
                        ? 0
                        : MediaQuery.of(context).padding.top))
                : defaultVideoHeight;

            // Enter/exit fullscreen mode for system UI
            if (orientation == Orientation.landscape || isFullScreen) {
              fullscreen.enterFullScreen();
            } else {
              fullscreen.exitFullScreen();
            }

            return SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              forceElevated: innerBoxIsScrolled,
              expandedHeight: expandedHeight,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                background: PopScope(
                  canPop: !isFullScreen,
                  onPopInvokedWithResult: (bool didPop, dynamic result) {
                    if (_vdCtr.playerController.isFullScreen.value) {
                      _vdCtr.playerController
                          .triggerFullScreen(status: false);
                    }
                    if (MediaQuery.of(context).orientation ==
                        Orientation.landscape) {
                      fullscreen.verticalScreen();
                    }
                  },
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final dataStatus = _vdCtr
                          .playerController.dataStatus.status.value;
                      if (dataStatus == DataStatus.loaded) {
                        return PLVideoPlayer(
                          controller: _vdCtr.playerController,
                          headerControl: _buildPlayerHeader(),
                          danmuWidget: PlDanmaku(
                            key: Key(_vdCtr.cid.toString()),
                            cid: _vdCtr.cid,
                            playerController: _vdCtr.playerController,
                          ),
                          bottomList: _vdCtr.bottomList,
                          fullScreenCb: (bool status) {
                            // Height is handled by Obx rebuild above
                          },
                        );
                      } else if (dataStatus == DataStatus.loading) {
                        return Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (dataStatus == DataStatus.error) {
                        return Container(
                          color: Colors.black,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error,
                                    color: Colors.white, size: 48),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    _vdCtr.loadVideoDetail(
                                      bvid: Get.parameters['bvid'],
                                      aid: Get.parameters['aid'] != null
                                          ? int.parse(Get.parameters['aid']!)
                                          : null,
                                    );
                                  },
                                  child: const Text('重试',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container(color: Colors.black);
                      }
                    },
                  ),
                ),
              ),
            );
          }),
        ];
      },
      pinnedHeaderSliverHeightBuilder: () {
        return _calcPinnedHeaderHeight(context);
      },
      onlyOneScrollInBody: true,
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _vdCtr.tabController,
              children: [
                _buildIntroTab(),
                _buildReplyTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 48),
          const SizedBox(height: 8),
          Text(_vdCtr.error),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              _vdCtr.loadVideoDetail(
                bvid: Get.parameters['bvid'],
                aid: Get.parameters['aid'] != null
                    ? int.parse(Get.parameters['aid']!)
                    : null,
              );
            },
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  // ==================== Tab Bar ====================

  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      height: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Material(
        child: Obx(
          () {
            // Use commentController.count if available, otherwise fall back to tabs
            final commentCtr = _vdCtr.commentController;
            final List<String> tabLabels;
            if (commentCtr != null && commentCtr.count.value > 0) {
              tabLabels = ['简介', '评论 ${commentCtr.count}'];
            } else {
              tabLabels = _vdCtr.tabs;
            }
            return TabBar(
              padding: EdgeInsets.zero,
              controller: _vdCtr.tabController,
              labelStyle: const TextStyle(fontSize: 13),
              labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
              dividerColor: Colors.transparent,
              tabs: tabLabels.map((name) => Tab(text: name)).toList(),
            );
          },
        ),
      ),
    );
  }

  // ==================== Intro Tab ====================

  Widget _buildIntroTab() {
    final detail = _vdCtr.videoDetail;
    if (detail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return CustomScrollView(
      key: const PageStorageKey<String>('简介'),
      slivers: [
        // Video title & description
        SliverToBoxAdapter(
          child: HeaderControlWidget(
            videoDetail: detail,
            playUrl: _vdCtr.playUrl,
          ),
        ),
        // Action bar (like, coin, collect, share)
        SliverToBoxAdapter(
          child: _IntroActionBar(
            isLiked: _vdCtr.isLikedRx,
            isCollected: _vdCtr.isCollectedRx,
            isCoined: _vdCtr.isCoinedRx,
            onLike: _vdCtr.toggleLike,
            onCollect: _vdCtr.toggleCollect,
            onCoin: _showCoinDialog,
          ),
        ),
        const SliverToBoxAdapter(
          child: Divider(height: 1, indent: 12, endIndent: 12),
        ),
        // Chapter (ViewPoints) section
        Obx(() {
          if (_vdCtr.viewPoints.isNotEmpty) {
            return SliverToBoxAdapter(
              child: _ChapterSection(
                viewPoints: _vdCtr.viewPoints,
                currentChapterIndex: _vdCtr.currentChapterIndex,
                onChapterTap: (ViewPoint vp) {
                  _vdCtr.playerController
                      .seekTo(Duration(seconds: vp.from ?? 0));
                },
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),
        // UP master info with follow button
        if (detail.owner != null)
          SliverToBoxAdapter(
            child: _UpMasterInfo(
              owner: detail.owner!,
              isFollowed: _vdCtr.isFollowed,
              followStatusRx: _vdCtr.followStatusRx,
              onFollow: _vdCtr.toggleFollow,
            ),
          ),
        // Pages (分P)
        if (detail.pages != null && detail.pages!.isNotEmpty)
          SliverToBoxAdapter(
            child: _PagesList(
              pages: detail.pages!,
              currentCid: _vdCtr.cid,
            ),
          ),
        // UGC Season (合集)
        if (detail.ugcSeason != null)
          SliverToBoxAdapter(
            child: _UgcSeasonInfo(ugcSeason: detail.ugcSeason!),
          ),
        // Related / recommended videos
        if (_vdCtr.relatedVideos.isNotEmpty)
          SliverToBoxAdapter(
            child: _RelatedVideos(videos: _vdCtr.relatedVideos),
          ),
      ],
    );
  }

  // ==================== Reply Tab ====================

  Widget _buildReplyTab() {
    final commentCtr = _vdCtr.commentController;
    if (commentCtr == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _CommentPanel(commentController: commentCtr);
  }
}

// ==================== Intro Tab Widgets ====================

/// Chapter (view points) section with horizontal scrolling cards.
/// Douyin-style design: rounded card thumbnails with title overlay.
class _ChapterSection extends StatelessWidget {
  final List<ViewPoint> viewPoints;
  final RxInt currentChapterIndex;
  final void Function(ViewPoint) onChapterTap;

  const _ChapterSection({
    required this.viewPoints,
    required this.currentChapterIndex,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.bookmark_outline, size: 18),
              const SizedBox(width: 4),
              Text(
                '章节',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${viewPoints.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 106,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewPoints.length,
            itemBuilder: (context, index) {
              final vp = viewPoints[index];
              return Obx(() => _ChapterCard(
                    viewPoint: vp,
                    isActive: currentChapterIndex.value == index,
                    onTap: () => onChapterTap(vp),
                  ));
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

/// Single chapter card with thumbnail, title overlay and time info.
class _ChapterCard extends StatelessWidget {
  final ViewPoint viewPoint;
  final bool isActive;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.viewPoint,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imgUrl = viewPoint.imgUrl;
    final hasImage = imgUrl != null && imgUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image area
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or placeholder
                    if (hasImage)
                      NetworkImgLayer(
                        src: imgUrl,
                        width: 140,
                        height: 76,
                        quality: 50,
                      )
                    else
                      Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: theme.colorScheme.outline,
                            size: 28,
                          ),
                        ),
                      ),
                    // Time badge overlay at bottom-right
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          viewPoint.fromTimeString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    // Active indicator overlay
                    if (isActive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Chapter title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                viewPoint.content ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action bar inside the intro tab (like, coin, collect, share).
class _IntroActionBar extends StatelessWidget {
  final RxBool isLiked;
  final RxBool isCollected;
  final RxBool isCoined;
  final VoidCallback onLike;
  final VoidCallback onCollect;
  final VoidCallback onCoin;

  const _IntroActionBar({
    required this.isLiked,
    required this.isCollected,
    required this.isCoined,
    required this.onLike,
    required this.onCollect,
    required this.onCoin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Obx(() => _buildActionButton(
                icon: isLiked.value ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: '点赞',
                color: isLiked.value ? Colors.red : null,
                onPressed: onLike,
              )),
          Obx(() => _buildActionButton(
                icon: isCoined.value
                    ? Icons.monetization_on
                    : Icons.monetization_on_outlined,
                label: '投币',
                color: isCoined.value ? Colors.orange : null,
                onPressed: onCoin,
              )),
          Obx(() => _buildActionButton(
                icon: isCollected.value ? Icons.star : Icons.star_outline,
                label: '收藏',
                color: isCollected.value ? Colors.yellow.shade700 : null,
                onPressed: onCollect,
              )),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: '分享',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        label: Text(
          label,
          style: TextStyle(color: color, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// UP master info row with follow button.
class _UpMasterInfo extends StatelessWidget {
  final Owner owner;
  final bool isFollowed;
  final RxMap followStatusRx;
  final VoidCallback onFollow;

  const _UpMasterInfo({
    required this.owner,
    required this.isFollowed,
    required this.followStatusRx,
    required this.onFollow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          NetworkImgLayer(
            src: owner.face ?? '',
            width: 40,
            height: 40,
            type: 'avatar',
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final followed =
                followStatusRx['attribute'] != null && followStatusRx['attribute'] != 0;
            return SizedBox(
              height: 32,
              child: TextButton(
                onPressed: onFollow,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  foregroundColor:
                      followed ? theme.colorScheme.outline : theme.colorScheme.onPrimary,
                  backgroundColor: followed
                      ? theme.colorScheme.onInverseSurface
                      : theme.colorScheme.primary,
                ),
                child: Text(
                  followed ? '已关注' : '关注',
                  style: TextStyle(
                    fontSize: theme.textTheme.labelMedium?.fontSize ?? 12,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Pages (分P) list.
class _PagesList extends StatelessWidget {
  final List<Part> pages;
  final int currentCid;

  const _PagesList({
    required this.pages,
    required this.currentCid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '分P',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pages.map((page) {
              final isCurrent = page.cid != null && page.cid == currentCid;
              return ActionChip(
                backgroundColor: isCurrent
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                label: Text(page.pagePart ?? 'P${page.page ?? "?"}'),
                onPressed: () {},
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// UGC season (合集) info.
class _UgcSeasonInfo extends StatelessWidget {
  final UgcSeason ugcSeason;

  const _UgcSeasonInfo({required this.ugcSeason});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            '合集',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(ugcSeason.title ?? ''),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Related / recommended videos section.
class _RelatedVideos extends StatelessWidget {
  final List<HotVideoItemModel> videos;

  const _RelatedVideos({required this.videos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '推荐视频',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...videos.map((video) => VideoCardH(
              videoItem: video,
              showPubdate: true,
            )),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
      ],
    );
  }
}

// ==================== Comment Panel ====================

class _CommentPanel extends StatefulWidget {
  final CommentController commentController;
  const _CommentPanel({required this.commentController});

  @override
  State<_CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends State<_CommentPanel> {
  late ScrollController _scrollController;
  Future? _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _futureBuilderFuture = widget.commentController.queryReplyList();
    _scrollListener();
  }

  void _scrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        EasyThrottle.throttle(
          'replylist',
          const Duration(milliseconds: 200),
          () => widget.commentController.onLoad(),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentCtr = widget.commentController;
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              return await commentCtr.queryReplyList(type: 'init');
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              key: const PageStorageKey<String>('评论'),
              slivers: <Widget>[
                // Sort bar
                SliverPersistentHeader(
                  pinned: false,
                  floating: true,
                  delegate: _SliverPersistentHeaderDelegate(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.fromLTRB(12, 0, 6, 0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.surface,
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                            offset: const Offset(2, 0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => Text(
                              '${commentCtr.sortTypeLabel.value}评论',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          SizedBox(
                            height: 35,
                            child: TextButton.icon(
                              onPressed: () => commentCtr.queryBySort(),
                              icon: const Icon(Icons.sort, size: 16),
                              label: Obx(
                                () => Text(
                                  commentCtr.sortTypeLabel.value,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Comment list
                FutureBuilder(
                  future: _futureBuilderFuture,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final data = snapshot.data;
                      if (commentCtr.replyList.isNotEmpty ||
                          (data != null && data['status'])) {
                        return Obx(() {
                          if (commentCtr.isLoadingMore &&
                              commentCtr.replyList.isEmpty) {
                            return SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return const VideoReplySkeleton();
                                },
                                childCount: 5,
                              ),
                            );
                          }
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final double bottom =
                                    MediaQuery.of(context).padding.bottom;
                                if (index == commentCtr.replyList.length) {
                                  return Container(
                                    padding: EdgeInsets.only(bottom: bottom),
                                    height: bottom + 100,
                                    child: Center(
                                      child: Obx(
                                        () => Text(
                                          commentCtr.noMore.value,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return CommentItem(
                                  replyItem: commentCtr.replyList[index],
                                  showReplyRow: true,
                                  replyLevel: '1',
                                  onLike: (int rpid, int action) {
                                    commentCtr.likeReply(rpid, action);
                                  },
                                  onReplyTap: (replyItem) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                      builder: (context) => ReplyReplyPanel(
                                        oid: commentCtr.aid ?? 0,
                                        rpid: replyItem.rpid ?? 0,
                                        firstFloor: replyItem,
                                      ),
                                    );
                                  },
                                  onReply: (replyItem) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (ctx) => Padding(
                                        padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(ctx)
                                                .viewInsets
                                                .bottom),
                                        child: CommentInputDialog(
                                          oid: commentCtr.aid ?? 0,
                                          root: replyItem.rpid ?? 0,
                                          parent: replyItem.rpid ?? 0,
                                          replyItem: replyItem,
                                        ),
                                      ),
                                    ).then((value) {
                                      if (value != null && value['data'] != null) {
                                        final idx = commentCtr.replyList
                                            .indexOf(replyItem);
                                        if (idx >= 0) {
                                          commentCtr.replyList[idx].count =
                                            (commentCtr.replyList[idx].count ??
                                                0) +
                                            1;
                                          commentCtr.replyList.refresh();
                                        }
                                      }
                                    });
                                  },
                                );
                              },
                              childCount: commentCtr.replyList.length + 1,
                            ),
                          );
                        });
                      } else {
                        return HttpError(
                          errMsg: data?['msg'],
                          fn: () {
                            setState(() {
                              _futureBuilderFuture =
                                  commentCtr.queryReplyList();
                            });
                          },
                        );
                      }
                    } else {
                      // Skeleton loading
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return const VideoReplySkeleton();
                          },
                          childCount: 5,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        // Bottom comment input bar
        _buildCommentInputBar(context),
      ],
    );
  }
  
  Widget _buildCommentInputBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
              color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (ctx) => Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: CommentInputDialog(
                  oid: widget.commentController.aid ?? 0),
            ),
          ).then((value) {
            if (value != null && value['data'] != null) {
              widget.commentController.replyList.insert(0, value['data']);
            }
          });
        },
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            '写评论...',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverPersistentHeaderDelegate({required this.child});

  final double _minExtent = 40;
  final double _maxExtent = 40;
  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

