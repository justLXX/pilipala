import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/reply.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/features/video/presentation/widgets/comment_controller.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/models/video/play/url.dart';
import 'package:pilipala/models/video/reply/data.dart';
import 'package:pilipala/models/video/view_point.dart';
import 'package:pilipala/plugin/pl_player/index.dart';
import 'package:pilipala/plugin/pl_player/models/bottom_control_type.dart';
import 'package:pilipala/utils/id_utils.dart';
import 'package:pilipala/utils/storage.dart';

/// Controller for the video detail feature.
///
/// Manages the state for video playback, comments, and user interactions.
/// Uses [VideoHttp] directly for like/coin/collect operations (same as legacy).
class VideoDetailController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // State
  final Rx<VideoDetailData?> _videoDetail = Rx<VideoDetailData?>(null);
  final Rx<PlayUrlModel?> _playUrl = Rx<PlayUrlModel?>(null);
  final Rx<ReplyData?> _comments = Rx<ReplyData?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isPlaying = false.obs;
  final RxBool _isLiked = false.obs;
  final RxBool _isCollected = false.obs;
  final RxBool _isCoined = false.obs;
  final RxString _error = ''.obs;

  // Follow state
  final RxMap _followStatus = <String, dynamic>{}.obs;
  final RxInt _followerCount = 0.obs;

  // Related videos
  final RxList<HotVideoItemModel> _relatedVideos = <HotVideoItemModel>[].obs;
  final RxBool _isRelatedLoading = false.obs;

  // View points (chapters)
  final RxList<ViewPoint> viewPoints = <ViewPoint>[].obs;

  // Current playing chapter index (for highlighting)
  final RxInt currentChapterIndex = (-1).obs;

  // User login state
  final Box<dynamic> _userInfoCache = GStrorage.userInfo;
  dynamic _userInfo;
  bool _userLogin = false;

  // Player controller
  late final PlPlayerController playerController;

  // Tabs
  late TabController tabController;
  final RxList<String> tabs = <String>['简介', '评论'].obs;

  // Bottom control list for player
  final RxList<BottomControlType> bottomList = [
    BottomControlType.playOrPause,
    BottomControlType.time,
    BottomControlType.space,
    BottomControlType.fit,
    BottomControlType.fullscreen,
  ].obs;

  // Comment controller (initialized after video detail loads)
  CommentController? commentController;

  // Route params
  late String bvid;
  late int cid;
  late String heroTag;

  // Getters
  VideoDetailData? get videoDetail => _videoDetail.value;
  PlayUrlModel? get playUrl => _playUrl.value;
  ReplyData? get comments => _comments.value;
  bool get isLoading => _isLoading.value;
  bool get isPlaying => _isPlaying.value;
  bool get isLiked => _isLiked.value;
  bool get isCollected => _isCollected.value;
  bool get isCoined => _isCoined.value;
  RxBool get isLikedRx => _isLiked;
  RxBool get isCollectedRx => _isCollected;
  RxBool get isCoinedRx => _isCoined;
  String get error => _error.value;

  // Follow getters
  RxMap get followStatusRx => _followStatus;
  bool get isFollowed => _followStatus['attribute'] != null && _followStatus['attribute'] != 0;
  RxInt get followerCount => _followerCount;

  // Related videos getters
  List<HotVideoItemModel> get relatedVideos => _relatedVideos;
  bool get isRelatedLoading => _isRelatedLoading.value;

  VideoDetailController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabs.length, vsync: this);
    bvid = Get.parameters['bvid'] ?? '';
    final cidStr = Get.parameters['cid'];
    cid = cidStr != null ? int.parse(cidStr) : 0;
    heroTag = Get.arguments?['heroTag'] ?? '${bvid}_$cid';

    // Check login state
    _userInfo = _userInfoCache.get('userInfoCache');
    _userLogin = _userInfo != null;

    // Initialize player controller
    playerController = PlPlayerController(videoType: 'archive');
  }

  @override
  void onClose() {
    // Clean up comment controller
    final oid = _videoDetail.value?.aid;
    if (oid != null && oid > 0) {
      Get.delete<CommentController>(tag: 'comment_$oid');
    }
    playerController.dispose();
    tabController.dispose();
    super.onClose();
  }

  /// 重新初始化播放器（从其他视频页返回时调用）
  /// 因为 PlPlayerController 是单例，跳转到新视频后会覆盖旧数据，
  /// 返回时需要重新设置数据源并恢复播放进度
  Future<void> reinitPlayer({Duration seekTo = Duration.zero}) async {
    final playUrl = _playUrl.value;
    if (playUrl == null) return;

    String videoUrl = '';
    String audioUrl = '';

    if (playUrl.dash != null &&
        playUrl.dash!.video != null &&
        playUrl.dash!.video!.isNotEmpty) {
      final videoItem = playUrl.dash!.video!.first;
      videoUrl = videoItem.baseUrl ?? '';
      if (playUrl.dash!.audio != null && playUrl.dash!.audio!.isNotEmpty) {
        audioUrl = playUrl.dash!.audio!.first.baseUrl ?? '';
      }
    } else if (playUrl.durl != null && playUrl.durl!.isNotEmpty) {
      videoUrl = playUrl.durl!.first.url ?? '';
    }

    if (videoUrl.isEmpty) return;

    final dataSource = DataSource(
      videoSource: videoUrl,
      audioSource: audioUrl.isNotEmpty ? audioUrl : null,
      type: DataSourceType.network,
      httpHeaders: {
        'user-agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15',
        'referer': 'https://www.bilibili.com',
      },
    );

    await playerController.setDataSource(
      dataSource,
      autoplay: true,
      seekTo: seekTo,
      bvid: bvid,
      cid: cid,
      duration: Duration(milliseconds: playUrl.timeLength ?? 0),
    );
  }

  /// Load video detail.
  Future<void> loadVideoDetail({String? bvid, int? aid}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      // 1. Get video detail
      final currentBvid = bvid ?? this.bvid;
      if (currentBvid.isEmpty) {
        _error.value = '缺少视频参数';
        return;
      }
      final result = await VideoHttp.videoIntro(bvid: currentBvid);
      if (!result['status'] || result['data'] == null) {
        _error.value = result['msg'] ?? '加载视频详情失败';
        return;
      }
      final videoDetail = result['data'] as VideoDetailData;
      _videoDetail.value = videoDetail;

      // Update cid from video detail if route param is missing
      if (videoDetail.cid != null && cid == 0) {
        cid = videoDetail.cid!;
      }

      // Update tab with reply count
      if (videoDetail.stat?.reply != null) {
        tabs.value = ['简介', '评论 ${videoDetail.stat!.reply}'];
      }

      // 2. Query like/coin/collect status if logged in
      if (_userLogin) {
        _queryInteractionStatus();
      }

      // 3. Load play URL
      if (videoDetail.cid != null) {
        await loadPlayUrl(
          avid: videoDetail.aid ?? 0,
          cid: videoDetail.cid!,
          bvid: bvid,
        );

        // Initialize player with play URL
        await _initPlayer(bvid: bvid, cid: videoDetail.cid!);
      }

      // 4. Initialize comment controller
      final int oid = videoDetail.aid ?? 0;
      if (oid > 0) {
        commentController = Get.put(CommentController(aid: oid), tag: 'comment_$oid');
      }

      // 5. Load related videos
      loadRelatedVideos();

      // 6. Load chapters (view points)
      loadViewPoints();

      // 7. Query follow status if logged in
      if (_userLogin && videoDetail.owner?.mid != null) {
        queryFollowStatus();
      }
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Query like/coin/collect status separately (same as legacy).
  void _queryInteractionStatus() {
    if (bvid.isEmpty) return;
    // Query like status
    VideoHttp.hasLikeVideo(bvid: bvid).then((result) {
      if (result['status']) {
        _isLiked.value = result['data'] == 1;
      }
    });
    // Query coin status
    VideoHttp.hasCoinVideo(bvid: bvid).then((result) {
      if (result['status'] && result['data'] != null) {
        _isCoined.value = result['data']['multiply'] != 0;
      }
    });
    // Query collect status
    final aid = _videoDetail.value?.aid ?? IdUtils.bv2av(bvid);
    VideoHttp.hasFavVideo(aid: aid).then((result) {
      if (result['status'] && result['data'] != null) {
        _isCollected.value = result['data']['favoured'] == true;
      }
    });
  }

  /// Query follow status for the video owner.
  Future<void> queryFollowStatus() async {
    final mid = _videoDetail.value?.owner?.mid;
    if (mid == null) return;
    final result = await VideoHttp.hasFollow(mid: mid);
    if (result['status']) {
      _followStatus.value = Map<String, dynamic>.from(result['data'] as Map);
    }
  }

  /// Toggle follow/unfollow the video owner.
  Future<void> toggleFollow() async {
    if (!_userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final mid = _videoDetail.value?.owner?.mid;
    if (mid == null) return;

    // attribute: 0=未关注, 2=已关注, 6=互关
    final currentAttr = _followStatus['attribute'] ?? 0;
    int act;
    if (currentAttr == 0) {
      act = 1; // 关注
    } else if (currentAttr == 2) {
      act = 2; // 取关
    } else if (currentAttr == 6) {
      act = 2; // 取关互关
    } else {
      act = 1;
    }

    final result = await VideoHttp.relationMod(
      mid: mid,
      act: act,
      reSrc: 11,
    );
    if (result['status']) {
      if (act == 1) {
        // 关注后查询最新状态（可能变成互关）
        await queryFollowStatus();
        SmartDialog.showToast('关注成功');
      } else {
        _followStatus['attribute'] = 0;
        _followStatus.refresh();
        SmartDialog.showToast('已取消关注');
      }
    } else {
      SmartDialog.showToast(result['msg'] ?? '操作失败');
    }
  }

  /// Load related/recommended videos.
  Future<void> loadRelatedVideos() async {
    final currentBvid = _videoDetail.value?.bvid ?? bvid;
    if (currentBvid.isEmpty) return;

    _isRelatedLoading.value = true;
    try {
      final result = await VideoHttp.relatedVideoList(bvid: currentBvid);
      if (result['status'] && result['data'] != null) {
        _relatedVideos.value = result['data'] as List<HotVideoItemModel>;
      }
    } catch (_) {
      // Non-critical, silently fail
    } finally {
      _isRelatedLoading.value = false;
    }
  }

  /// Load chapters (view points) from player info API.
  Future<void> loadViewPoints() async {
    final currentBvid = _videoDetail.value?.bvid ?? bvid;
    final currentAid = _videoDetail.value?.aid;
    final currentCid = _videoDetail.value?.cid ?? cid;
    if (currentCid == 0) return;

    try {
      final result = await VideoHttp.playerInfo(
        aid: currentAid,
        bvid: currentBvid,
        cid: currentCid,
      );
      if (result['status'] && result['data'] != null) {
        viewPoints.value = result['data'] as List<ViewPoint>;
      }
    } catch (_) {
      // Non-critical, silently fail
    }
  }

  /// Update current chapter index based on player position.
  void updateCurrentChapter(int positionSeconds) {
    if (viewPoints.isEmpty) return;
    int newIndex = -1;
    for (int i = 0; i < viewPoints.length; i++) {
      final vp = viewPoints[i];
      if (positionSeconds >= (vp.from ?? 0) && positionSeconds < (vp.to ?? 0)) {
        newIndex = i;
        break;
      }
    }
    if (newIndex != currentChapterIndex.value) {
      currentChapterIndex.value = newIndex;
    }
  }

  /// Initialize player with play URL.
  Future<void> _initPlayer({String? bvid, required int cid}) async {
    final playUrl = _playUrl.value;
    if (playUrl == null) return;

    String videoUrl = '';
    String audioUrl = '';

    // Try DASH format first (preferred for higher quality)
    if (playUrl.dash != null &&
        playUrl.dash!.video != null &&
        playUrl.dash!.video!.isNotEmpty) {
      final videoItem = playUrl.dash!.video!.first;
      videoUrl = videoItem.baseUrl ?? '';
      if (playUrl.dash!.audio != null && playUrl.dash!.audio!.isNotEmpty) {
        audioUrl = playUrl.dash!.audio!.first.baseUrl ?? '';
      }
    }
    // Fallback to DURL format
    else if (playUrl.durl != null && playUrl.durl!.isNotEmpty) {
      videoUrl = playUrl.durl!.first.url ?? '';
    }

    if (videoUrl.isEmpty) {
      _error.value = '无法获取视频播放地址';
      return;
    }

    final dataSource = DataSource(
      videoSource: videoUrl,
      audioSource: audioUrl.isNotEmpty ? audioUrl : null,
      type: DataSourceType.network,
      httpHeaders: {
        'user-agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15',
        'referer': 'https://www.bilibili.com',
      },
    );

    await playerController.setDataSource(
      dataSource,
      autoplay: true,
      bvid: bvid ?? '',
      cid: cid,
      duration: Duration(milliseconds: playUrl.timeLength ?? 0),
    );
  }

  /// Load video play URL.
  Future<void> loadPlayUrl({
    required int avid,
    required int cid,
    String? bvid,
    int qn = 80,
  }) async {
    try {
      final result = await VideoHttp.videoUrl(
        avid: avid,
        bvid: bvid,
        cid: cid,
        qn: qn,
      );
      if (result['status'] && result['data'] != null) {
        _playUrl.value = result['data'] as PlayUrlModel;
      }
    } catch (e) {
      _error.value = e.toString();
    }
  }

  /// Load video comments.
  Future<void> loadComments({
    required int oid,
    int page = 1,
  }) async {
    try {
      final result = await ReplyHttp.replyList(
        oid: oid,
        pageNum: page,
        type: 1,
      );
      if (result['status'] && result['data'] != null) {
        _comments.value = result['data'] as ReplyData;
      }
    } catch (e) {
      // Comments loading failure is non-critical, don't set error
    }
  }

  /// Toggle play/pause.
  void togglePlay() {
    _isPlaying.value = !_isPlaying.value;
  }

  /// Like / unlike video (same as legacy actionLikeVideo).
  Future<void> toggleLike() async {
    if (!_userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final currentBvid = _videoDetail.value?.bvid ?? bvid;
    if (currentBvid.isEmpty) return;

    final result =
        await VideoHttp.likeVideo(bvid: currentBvid, type: !_isLiked.value);
    if (result['status']) {
      if (!_isLiked.value) {
        SmartDialog.showToast('点赞成功');
        _isLiked.value = true;
        if (_videoDetail.value?.stat?.like != null) {
          _videoDetail.value!.stat!.like = _videoDetail.value!.stat!.like! + 1;
        }
      } else {
        SmartDialog.showToast('取消赞');
        _isLiked.value = false;
        if (_videoDetail.value?.stat?.like != null) {
          _videoDetail.value!.stat!.like = _videoDetail.value!.stat!.like! - 1;
        }
      }
      _isLiked.refresh();
    } else {
      SmartDialog.showToast(result['msg'] ?? '操作失败');
    }
  }

  /// Collect / uncollect video (same as legacy actionFavVideo).
  Future<void> toggleCollect() async {
    if (!_userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final aid = _videoDetail.value?.aid ?? IdUtils.bv2av(bvid);
    if (aid == 0) return;

    final addIds = !_isCollected.value ? '1' : '';
    final delIds = _isCollected.value ? '1' : '';

    final result = await VideoHttp.favVideo(
      aid: aid,
      addIds: addIds,
      delIds: delIds,
    );
    if (result['status']) {
      // Re-query fav status
      final favResult = await VideoHttp.hasFavVideo(aid: aid);
      if (favResult['status'] && favResult['data'] != null) {
        _isCollected.value = favResult['data']['favoured'] == true;
      }
      SmartDialog.showToast('操作成功');
    } else {
      SmartDialog.showToast(result['msg'] ?? '操作失败');
    }
  }

  /// Coin video (same as legacy actionCoinVideo).
  Future<void> toggleCoin({required int multiply}) async {
    if (!_userLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final currentBvid = _videoDetail.value?.bvid ?? bvid;
    if (currentBvid.isEmpty) return;

    final result =
        await VideoHttp.coinVideo(bvid: currentBvid, multiply: multiply);
    if (result['status']) {
      SmartDialog.showToast('投币成功');
      _isCoined.value = true;
      if (_videoDetail.value?.stat?.coin != null) {
        _videoDetail.value!.stat!.coin =
            _videoDetail.value!.stat!.coin! + multiply;
      }
    } else {
      SmartDialog.showToast(result['msg'] ?? '投币失败');
    }
  }
}
