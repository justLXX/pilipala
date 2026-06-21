import 'package:easy_debounce/easy_throttle.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/skeleton/video_reply.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_controller.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_input_dialog.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_item.dart';
import 'package:pilipala/features/video/presentation/widgets/reply_reply_panel.dart';
import 'package:pilipala/features/video/presentation/widgets/header_control.dart';
import 'package:pilipala/features/main/presentation/main_controller.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/models/video/play/quality.dart';
import 'package:pilipala/models/video/view_point.dart';
import 'package:pilipala/common/widgets/danmaku/view.dart';
import 'package:pilipala/plugin/pl_player/index.dart';
import 'package:pilipala/plugin/pl_player/models/play_repeat.dart';
import 'package:pilipala/plugin/pl_player/utils/fullscreen.dart' as fullscreen;
import 'package:pilipala/utils/navigation_helper.dart';
import 'package:pilipala/utils/responsive.dart';
import 'package:universal_platform/universal_platform.dart';

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
  bool _didPushImagePreview = false;
  bool _coveredByVideoRoute = false;
  int _lastChapterCheckSecond = -1;
  PageRoute<dynamic>? _subscribedRoute;
  // Tracks current system-UI mode to avoid redundant SystemChrome calls on
  // each Obx rebuild. True == immersive requested.
  bool _systemImmersive = false;
  DataStatus? _lastLoggedPlayerDataStatus;
  String? _lastLoggedPlayerKey;

  @override
  void initState() {
    super.initState();
    // 使用 tag 隔离每个视频页面的 controller，避免同路由跳转时 controller 被替换
    final bvid = Get.parameters['bvid'] ?? '';
    final cid = Get.parameters['cid'] ?? '0';
    _heroTag = Get.arguments?['heroTag'] ?? '${bvid}_$cid';
    _log(
        'initState bvid=$bvid cid=$cid heroTag=$_heroTag route=${Get.currentRoute}');
    _vdCtr = Get.put(VideoDetailController(), tag: _heroTag);
    _vdCtr.playerController.addStatusLister(_playerStatusListener);
    _vdCtr.playerController.addPositionListener(_playerPositionListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vdCtr.loadVideoDetail(
        bvid: bvid,
        aid: Get.parameters['aid'] != null
            ? int.parse(Get.parameters['aid']!)
            : null,
      );
    });
  }

  void _playerPositionListener(Duration position) {
    final second = position.inSeconds;
    if (second == _lastChapterCheckSecond) return;
    _lastChapterCheckSecond = second;
    _vdCtr.updateCurrentChapter(second);
  }

  void _playerStatusListener(PlayerStatus status) {
    _log('播放器状态回调 status=$status');
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
    _log('dispose heroTag=$_heroTag');
    VideoDetailPage.routeObserver.unsubscribe(this);
    _vdCtr.playerController.removeStatusLister(_playerStatusListener);
    _vdCtr.playerController.removePositionListener(_playerPositionListener);
    // Restore normal system UI in case the page was immersive when disposed.
    if (_systemImmersive) {
      fullscreen.exitFullScreen();
    }
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
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        VideoDetailPage.routeObserver.unsubscribe(this);
      }
      _subscribedRoute = route;
      VideoDetailPage.routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    _log('didPushNext currentRoute=${Get.currentRoute}');
    final bool isImagePreview = Get.isRegistered<MainController>() &&
        Get.find<MainController>().imgPreviewStatus;
    if (isImagePreview) {
      _didPushImagePreview = true;
      super.didPushNext();
      return;
    }
    if (Get.currentRoute.startsWith('/video')) {
      _setCoveredByVideoRoute(true);
      if (_vdCtr.playerController.videoPlayerController != null) {
        _lastPosition = _vdCtr.playerController.position.value;
        _log('跳到新视频页，摘除当前页监听 lastPosition=$_lastPosition');
        _vdCtr.playerController.removeStatusLister(_playerStatusListener);
        _vdCtr.playerController.removePositionListener(_playerPositionListener);
      }
      super.didPushNext();
      return;
    }
    // 离开页面：保存进度，移除监听，暂停播放
    if (_vdCtr.playerController.videoPlayerController != null) {
      _lastPosition = _vdCtr.playerController.position.value;
      _log('跳到非视频页，暂停播放器 lastPosition=$_lastPosition');
      _vdCtr.playerController.removeStatusLister(_playerStatusListener);
      _vdCtr.playerController.removePositionListener(_playerPositionListener);
      _vdCtr.playerController.pause();
    }
    super.didPushNext();
  }

  @override
  void didPopNext() {
    _log('didPopNext currentRoute=${Get.currentRoute}');
    _setCoveredByVideoRoute(false);
    if (_didPushImagePreview) {
      _didPushImagePreview = false;
      super.didPopNext();
      return;
    }
    // 返回页面：重新初始化播放器，恢复进度
    if (_vdCtr.playerController.videoPlayerController != null &&
        _vdCtr.playUrl != null) {
      _log('返回详情页，reinitPlayer seekTo=$_lastPosition');
      _vdCtr.reinitPlayer(seekTo: _lastPosition).then((_) {
        _vdCtr.playerController.addStatusLister(_playerStatusListener);
        _vdCtr.playerController.addPositionListener(_playerPositionListener);
      });
    } else {
      _log('返回详情页，仅恢复监听');
      _vdCtr.playerController.addStatusLister(_playerStatusListener);
      _vdCtr.playerController.addPositionListener(_playerPositionListener);
    }
    super.didPopNext();
  }

  void _setCoveredByVideoRoute(bool value) {
    if (_coveredByVideoRoute == value) return;
    if (!mounted) {
      _coveredByVideoRoute = value;
      return;
    }
    setState(() {
      _coveredByVideoRoute = value;
    });
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
                  safeBack();
                },
                child: const Text('1 枚'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  _vdCtr.toggleCoin(multiply: 2);
                  safeBack();
                },
                child: const Text('2 枚'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQualitySheet() {
    final formats = _vdCtr.qualityFormats;
    if (formats.isEmpty) {
      SmartDialog.showToast('暂无可切换清晰度');
      return;
    }
    final availableCodes = _vdCtr.availableQualityCodes;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Obx(() {
            final currentCode = _vdCtr.currentVideoQualityRx.value?.code;
            return ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: formats.length + 1,
              separatorBuilder: (_, index) {
                return index == 0
                    ? const SizedBox.shrink()
                    : const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      '选择清晰度',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                final format = formats[index - 1];
                final qualityCode = format.quality;
                final quality = qualityCode == null
                    ? null
                    : VideoQualityCode.fromCode(qualityCode);
                final enabled = qualityCode != null &&
                    (availableCodes.isEmpty ||
                        availableCodes.contains(qualityCode));
                final title = format.newDesc ??
                    format.displayDesc ??
                    quality?.description ??
                    '${qualityCode ?? ''}';
                return ListTile(
                  enabled: enabled,
                  title: Text(title),
                  subtitle: format.format == null || format.format!.isEmpty
                      ? null
                      : Text(format.format!),
                  trailing: qualityCode == currentCode
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: enabled
                      ? () {
                          safeBack(context: context);
                          _vdCtr.switchVideoQuality(qualityCode);
                        }
                      : null,
                );
              },
            );
          }),
        );
      },
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
                final isPhoneLandscape = Responsive.isCompact(context) &&
                    MediaQuery.of(context).orientation == Orientation.landscape;
                if (_vdCtr.playerController.isFullScreen.value &&
                    isPhoneLandscape) {
                  _vdCtr.playerController.triggerFullScreen(status: false);
                } else if (isPhoneLandscape) {
                  fullscreen.verticalScreen();
                } else {
                  safeBack(context: context);
                }
              },
            ),
            const Spacer(),
            Obx(() {
              final quality = _vdCtr.currentVideoQualityRx.value;
              return TextButton.icon(
                onPressed: _showQualitySheet,
                icon: const Icon(
                  Icons.high_quality,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  quality?.description ?? '清晰度',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 页面级加载/错误状态下的顶部返回按钮，确保任何情况下都能退出
  Widget _buildTopBackButton() {
    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
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
    final isPhoneLandscape =
        Responsive.isCompact(context) && orientation == Orientation.landscape;
    if (isPhoneLandscape || isFullScreen) {
      return MediaQuery.sizeOf(context).height;
    }
    // Scaffold 的零高度 appBar 已消费安全区，此处无需加 topPadding
    final videoHeight = Responsive.videoPlayerWidth(context) * 9 / 16;
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
          return Stack(
            children: [
              _buildError(),
              _buildTopBackButton(),
            ],
          );
        } else {
          return Stack(
            children: [
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              _buildTopBackButton(),
            ],
          );
        }
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_useDesktopLayout(context)) {
      return _buildDesktopContent(context);
    }

    final defaultVideoHeight = Responsive.videoPlayerWidth(context) * 9 / 16;

    return ExtendedNestedScrollView(
      controller: _extendNestCtr,
      physics: const ClampingScrollPhysics(),
      headerSliverBuilder: (BuildContext ctx, bool innerBoxIsScrolled) {
        return <Widget>[
          Obx(() {
            final orientation = MediaQuery.of(context).orientation;
            final isFullScreen = _vdCtr.playerController.isFullScreen.value;
            final isPhoneLandscape = Responsive.isCompact(context) &&
                orientation == Orientation.landscape;
            // Scaffold 的零高度 appBar 已消费安全区，body 从安全区下方开始，
            // 因此 expandedHeight 仅需视频高度（与旧版一致）
            final expandedHeight = (isPhoneLandscape || isFullScreen)
                ? (MediaQuery.sizeOf(context).height -
                    (isPhoneLandscape ? 0 : MediaQuery.of(context).padding.top))
                : defaultVideoHeight;

            // System UI (immersive vs. normal) is a side-effect. It must NOT
            // run during the reactive Obx evaluation (which re-runs on every
            // Rx change and can re-enter SystemChrome calls redundantly).
            // Defer to post-frame and guard against repeated calls via
            // _systemImmersive so we only toggle when the desired mode changes.
            final wantImmersive = isPhoneLandscape || isFullScreen;
            if (wantImmersive != _systemImmersive) {
              _systemImmersive = wantImmersive;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (wantImmersive) {
                  fullscreen.enterFullScreen();
                } else {
                  fullscreen.exitFullScreen();
                }
              });
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
                  canPop: !(isFullScreen && isPhoneLandscape),
                  onPopInvokedWithResult: (bool didPop, dynamic result) {
                    if (_vdCtr.playerController.isFullScreen.value &&
                        isPhoneLandscape) {
                      _vdCtr.playerController.triggerFullScreen(status: false);
                    }
                    if (isPhoneLandscape) {
                      fullscreen.verticalScreen();
                    }
                  },
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      final player = _buildPlayer(context);
                      if (!isPhoneLandscape && !isFullScreen) {
                        return ColoredBox(
                          color: Colors.black,
                          child: Center(
                            child: SizedBox(
                              width: Responsive.videoPlayerWidth(context),
                              height: defaultVideoHeight,
                              child: player,
                            ),
                          ),
                        );
                      }
                      return player;
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
      body: Center(
        child: SizedBox(
          width: Responsive.constrainedContentWidth(context),
          child: Column(
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
        ),
      ),
    );
  }

  bool _useDesktopLayout(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 900 &&
        (UniversalPlatform.isMacOS ||
            UniversalPlatform.isWindows ||
            UniversalPlatform.isLinux);
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Obx(() {
      final isFullScreen = _vdCtr.playerController.isFullScreen.value;
      if (isFullScreen) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) {
            _vdCtr.playerController.triggerFullScreen(status: false);
          },
          child: ColoredBox(
            color: Colors.black,
            child: _buildPlayer(context),
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final pageWidth = maxWidth >= 1680 ? 1680.0 : maxWidth;
          final horizontalPadding = pageWidth >= 1280 ? 24.0 : 16.0;
          final gap = pageWidth >= 1280 ? 18.0 : 12.0;
          final commentWidth = pageWidth >= 1280 ? 430.0 : 380.0;
          final leftWidth =
              pageWidth - horizontalPadding * 2 - gap - commentWidth;
          final videoHeightByWidth = leftWidth * 9 / 16;
          final maxVideoHeight = constraints.maxHeight * 0.62;
          final playerHeight = videoHeightByWidth > maxVideoHeight
              ? maxVideoHeight
              : videoHeightByWidth;

          return ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: Center(
              child: SizedBox(
                width: pageWidth,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: playerHeight,
                              child: ColoredBox(
                                color: Colors.black,
                                child: _buildPlayer(context),
                              ),
                            ),
                            Expanded(child: _buildIntroTab()),
                          ],
                        ),
                      ),
                      SizedBox(width: gap),
                      SizedBox(
                        width: commentWidth,
                        child: _buildDesktopReplyPanel(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildDesktopReplyPanel() {
    final commentCtr = _vdCtr.commentController;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final count = commentCtr?.count.value ?? 0;
              return Text(
                count > 0 ? '评论 $count' : '评论',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
          ),
          Expanded(
            child: commentCtr == null
                ? const Center(child: CircularProgressIndicator())
                : _CommentPanel(commentController: commentCtr),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    return Obx(() {
      if (_coveredByVideoRoute) {
        return const ColoredBox(color: Colors.black);
      }
      final dataStatus = _vdCtr.playerController.dataStatus.status.value;
      final textureKey = _vdCtr.playerController.videoTextureKey.value;
      final playerKey = '${_vdCtr.bvid}_${_vdCtr.cid}_$textureKey';
      if (_lastLoggedPlayerDataStatus != dataStatus ||
          _lastLoggedPlayerKey != playerKey) {
        _lastLoggedPlayerDataStatus = dataStatus;
        _lastLoggedPlayerKey = playerKey;
        _log(
          '_buildPlayer dataStatus=$dataStatus key=$playerKey '
          'videoDetail=${_vdCtr.videoDetail != null} '
          'playUrl=${_vdCtr.playUrl != null} '
          'playerStatus=${_vdCtr.playerController.playerStatus.status.value} '
          'buffering=${_vdCtr.playerController.isBuffering.value} '
          'position=${_vdCtr.playerController.position.value} '
          'hasPlaybackStarted=${_vdCtr.playerController.hasPlaybackStarted.value}',
        );
      }
      if (dataStatus == DataStatus.loaded) {
        return PLVideoPlayer(
          key: ValueKey(playerKey),
          controller: _vdCtr.playerController,
          headerControl: _buildPlayerHeader(),
          danmuWidget: PlDanmaku(
            key: Key(_vdCtr.cid.toString()),
            cid: _vdCtr.cid,
            playerController: _vdCtr.playerController,
          ),
          bottomList: _vdCtr.bottomList,
          fullScreenCb: (bool status) {
            // 高度由上层 Obx 重建处理
          },
        );
      } else if (dataStatus == DataStatus.loading) {
        return Stack(
          children: [
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildPlayerHeader(),
            ),
          ],
        );
      } else if (dataStatus == DataStatus.error) {
        return Stack(
          children: [
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.white, size: 48),
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
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildPlayerHeader(),
            ),
          ],
        );
      } else {
        return Container(color: Colors.black);
      }
    });
  }

  void _log(String message) {
    if (!kDebugMode) return;
    debugPrint('[播放器链路][VideoDetailPage ${identityHashCode(this)}] $message');
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Container(
        width: double.infinity,
        height: 38,
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
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
                padding: const EdgeInsets.all(3),
                controller: _vdCtr.tabController,
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                ),
                tabs: tabLabels.map((name) => Tab(text: name)).toList(),
              );
            },
          ),
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
    // Single Obx subscribes to relatedVideos / viewPoints / isRelatedLoading
    // so async-loaded data refreshes this tab when it arrives (P1 loads these
    // in parallel, fire-and-forget). Keeps _ChapterSection / _RelatedVideos
    // reactive without per-item Obx.
    return Obx(() {
      final related = _vdCtr.relatedVideos;
      final viewPoints = _vdCtr.viewPoints;
      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: CustomScrollView(
          key: const PageStorageKey<String>('简介'),
          physics: const ClampingScrollPhysics(),
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
            if (viewPoints.isNotEmpty)
              SliverToBoxAdapter(
                child: _ChapterSection(
                  viewPoints: viewPoints,
                  currentChapterIndex: _vdCtr.currentChapterIndex,
                  onChapterTap: (ViewPoint vp) {
                    _vdCtr.playerController
                        .seekTo(Duration(seconds: vp.from ?? 0));
                  },
                ),
              ),
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
            if (related.isNotEmpty) ..._buildRelatedVideoSlivers(related),
          ],
        ),
      );
    });
  }

  // ==================== Reply Tab ====================

  Widget _buildReplyTab() {
    final commentCtr = _vdCtr.commentController;
    if (commentCtr == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return _CommentPanel(commentController: commentCtr);
  }

  List<Widget> _buildRelatedVideoSlivers(List<HotVideoItemModel> videos) {
    final crossAxisCount = Responsive.videoGridCount(context);
    return [
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            '推荐视频',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      if (crossAxisCount == 1)
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => CleanVideoListTile(
              videoItem: videos[index],
              showPubdate: true,
            ),
            childCount: videos.length,
            addAutomaticKeepAlives: false,
          ),
        )
      else
        SliverLayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.crossAxisExtent >= 720;
            final double horizontalPadding = isDesktop ? 24.0 : 12.0;
            final double crossAxisSpacing = isDesktop ? 24.0 : 12.0;
            final double mainAxisSpacing = isDesktop ? 24.0 : 16.0;
            final itemWidth = (constraints.crossAxisExtent -
                    horizontalPadding * 2 -
                    crossAxisSpacing * (crossAxisCount - 1)) /
                crossAxisCount;
            final itemHeight = itemWidth / StyleString.aspectRatio + 118;
            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  mainAxisExtent: itemHeight,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => CleanVideoCard(
                    videoItem: videos[index],
                    showPubdate: true,
                  ),
                  childCount: videos.length,
                  addAutomaticKeepAlives: false,
                ),
              ),
            );
          },
        ),
      SliverToBoxAdapter(
        child: SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
      ),
    ];
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
        // Single Obx reads currentChapterIndex once and passes a plain bool to
        // each card. Without this, every chapter card had its own Obx and all
        // of them rebuilt on each position-update of the player.
        Obx(() {
          final current = currentChapterIndex.value;
          return SizedBox(
            height: 106,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: viewPoints.length,
              itemBuilder: (context, index) {
                final vp = viewPoints[index];
                return _ChapterCard(
                  viewPoint: vp,
                  isActive: current == index,
                  onTap: () => onChapterTap(vp),
                );
              },
            ),
          );
        }),
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
                          color: Colors.black.withValues(alpha: 0.7),
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
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
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
    // Single Obx reads all three interaction states in one pass. Previously
    // each button had its own Obx (three subscriptions + three rebuilds when
    // the controller toggles multiple states together, e.g. after _query).
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Obx(() {
        final liked = isLiked.value;
        final coined = isCoined.value;
        final collected = isCollected.value;
        return Row(
          children: [
            _buildActionButton(
              icon: liked ? Icons.thumb_up : Icons.thumb_up_outlined,
              label: '点赞',
              color: liked ? Theme.of(context).colorScheme.primary : null,
              onPressed: onLike,
            ),
            _buildActionButton(
              icon: coined
                  ? Icons.monetization_on
                  : Icons.monetization_on_outlined,
              label: '投币',
              color: coined ? Theme.of(context).colorScheme.primary : null,
              onPressed: onCoin,
            ),
            _buildActionButton(
              icon: collected ? Icons.star : Icons.star_outline,
              label: '收藏',
              color: collected ? Theme.of(context).colorScheme.primary : null,
              onPressed: onCollect,
            ),
            _buildActionButton(
              icon: Icons.share_outlined,
              label: '分享',
              onPressed: () {},
            ),
          ],
        );
      }),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: StyleString.mdRadius,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              NetworkImgLayer(
                src: owner.face ?? '',
                width: 42,
                height: 42,
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
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'UP 主',
                      style: TextStyle(
                        color: theme.colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Obx(() {
                final followed = followStatusRx['attribute'] != null &&
                    followStatusRx['attribute'] != 0;
                return SizedBox(
                  height: 34,
                  child: TextButton(
                    onPressed: onFollow,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      foregroundColor: followed
                          ? theme.colorScheme.outline
                          : theme.colorScheme.onPrimary,
                      backgroundColor: followed
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      followed ? '已关注' : '关注',
                      style: TextStyle(
                        fontSize: theme.textTheme.labelMedium?.fontSize ?? 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
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

// ==================== Comment Panel ====================

class _CommentPanel extends StatefulWidget {
  final CommentController commentController;
  const _CommentPanel({required this.commentController});

  @override
  State<_CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends State<_CommentPanel> {
  static const ScrollPhysics _commentScrollPhysics = ClampingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );

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

  // Helper to build the sort-bar header sliver used in every comment branch.
  Widget _buildSortHeader(BuildContext context, commentCtr) {
    return SliverPersistentHeader(
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
    );
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
            child: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data;
                  if (commentCtr.replyList.isNotEmpty ||
                      (data != null && data['status'])) {
                    if (commentCtr.isLoadingMore &&
                        commentCtr.replyList.isEmpty) {
                      // Loading more skeleton
                      return CustomScrollView(
                        controller: _scrollController,
                        physics: _commentScrollPhysics,
                        key: const PageStorageKey<String>('评论'),
                        slivers: <Widget>[
                          _buildSortHeader(context, commentCtr),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                return const VideoReplySkeleton();
                              },
                              childCount: 5,
                            ),
                          ),
                        ],
                      );
                    }
                    // Comment list (reactive)
                    return Obx(() {
                      final replyList = commentCtr.replyList;
                      return CustomScrollView(
                        controller: _scrollController,
                        physics: _commentScrollPhysics,
                        key: const PageStorageKey<String>('评论'),
                        slivers: <Widget>[
                          _buildSortHeader(context, commentCtr),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                if (replyList.isEmpty) {
                                  return const VideoReplySkeleton();
                                }
                                final double bottom =
                                    MediaQuery.of(context).padding.bottom;
                                if (index == replyList.length) {
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
                                final replyItem = replyList[index];
                                return CommentItem(
                                  key: ValueKey(replyItem.rpid),
                                  replyItem: replyItem,
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
                                      if (value != null &&
                                          value['data'] != null) {
                                        final idx =
                                            replyList.indexOf(replyItem);
                                        if (idx >= 0) {
                                          replyList[idx].count =
                                              (replyList[idx].count ?? 0) + 1;
                                          replyList.refresh();
                                        }
                                      }
                                    });
                                  },
                                );
                              },
                              childCount:
                                  replyList.isEmpty ? 5 : replyList.length + 1,
                              // Comment items are cheap to rebuild when scrolled
                              // back into view and carry no keep-alive state
                              // worth preserving; disabling keep-alive lowers
                              // memory pressure on long comment threads.
                              addAutomaticKeepAlives: false,
                              // Items are wrapped in RepaintBoundary above, but
                              // keep the delegate default explicit for clarity.
                              addRepaintBoundaries: true,
                            ),
                          ),
                        ],
                      );
                    });
                  } else {
                    // Error state
                    return CustomScrollView(
                      controller: _scrollController,
                      physics: _commentScrollPhysics,
                      key: const PageStorageKey<String>('评论'),
                      slivers: <Widget>[
                        _buildSortHeader(context, commentCtr),
                        HttpError(
                          errMsg: data?['msg'],
                          fn: () {
                            setState(() {
                              _futureBuilderFuture =
                                  commentCtr.queryReplyList();
                            });
                          },
                        ),
                      ],
                    );
                  }
                } else {
                  // Skeleton loading
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: _commentScrollPhysics,
                    key: const PageStorageKey<String>('评论'),
                    slivers: <Widget>[
                      _buildSortHeader(context, commentCtr),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return const VideoReplySkeleton();
                          },
                          childCount: 5,
                        ),
                      ),
                    ],
                  );
                }
              },
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
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
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
              child: CommentInputDialog(oid: widget.commentController.aid ?? 0),
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
            borderRadius: StyleString.lgRadius,
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
