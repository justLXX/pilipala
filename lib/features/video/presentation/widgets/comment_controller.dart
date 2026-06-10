import 'package:easy_debounce/easy_throttle.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/reply.dart';
import 'package:pilipala/models/common/reply_sort_type.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/storage.dart';

class CommentController extends GetxController {
  CommentController({this.aid});

  /// 视频aid，请求时使用的oid
  int? aid;

  /// 评论列表
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;

  /// 当前页码
  int currentPage = 0;

  /// 加载锁
  bool isLoadingMore = false;

  /// 底部提示文字
  RxString noMore = ''.obs;

  /// 每页数量
  int ps = 20;

  /// 评论总数
  RxInt count = 0.obs;

  /// 排序类型
  ReplySortType _sortType = ReplySortType.time;

  /// 排序显示标题
  RxString sortTypeTitle = ReplySortType.time.titles.obs;

  /// 排序显示标签
  RxString sortTypeLabel = ReplySortType.time.labels.obs;

  /// 请求返回码
  RxInt replyReqCode = 200.obs;

  Box setting = GStrorage.setting;

  @override
  void onInit() {
    super.onInit();
    int defaultReplySortIndex =
        setting.get(SettingBoxKey.replySortType, defaultValue: 0) as int;
    if (defaultReplySortIndex == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      defaultReplySortIndex = 0;
    }
    _sortType = ReplySortType.values[defaultReplySortIndex];
    sortTypeTitle.value = _sortType.titles;
    sortTypeLabel.value = _sortType.labels;
  }

  /// 请求评论列表
  /// [type] 'init' 初始化 / 'onLoad' 加载更多
  Future queryReplyList({type = 'init'}) async {
    if (isLoadingMore) {
      return;
    }
    isLoadingMore = true;

    if (type == 'init') {
      currentPage = 0;
      noMore.value = '';
    }

    if (noMore.value == '没有更多了') {
      isLoadingMore = false;
      return;
    }

    final res = await ReplyHttp.replyList(
      oid: aid!,
      pageNum: currentPage + 1,
      ps: ps,
      type: ReplyType.video.index,
      sort: _sortType.index,
    );

    if (res['status']) {
      final List<ReplyItemModel> replies = res['data'].replies;
      if (replies.isNotEmpty) {
        noMore.value = '加载中...';

        // 第一页回复数小于18，说明没有更多
        if (currentPage == 0 && replies.length < 18) {
          noMore.value = '没有更多了';
        }
        currentPage++;

        if (replyList.length == res['data'].page.acount) {
          noMore.value = '没有更多了';
        }
      } else {
        // 未登录状态 replies 可能返回 null
        noMore.value = currentPage == 0 ? '还没有评论' : '没有更多了';
      }

      if (type == 'init') {
        // 添加置顶回复
        if (res['data'].upper.top != null) {
          final bool flag = res['data'].topReplies.any((ReplyItemModel reply) =>
              reply.rpid == res['data'].upper.top.rpid) as bool;
          if (!flag) {
            replies.insert(0, res['data'].upper.top);
          }
        }
        replies.insertAll(0, res['data'].topReplies);
        count.value = res['data'].page.count;
        replyList.value = replies;
      } else {
        replyList.addAll(replies);
      }
    }

    replyReqCode.value = res['code'];
    isLoadingMore = false;
    return res;
  }

  /// 上拉加载更多
  Future onLoad() async {
    queryReplyList(type: 'onLoad');
  }

  /// 切换排序方式并刷新评论
  void queryBySort() {
    EasyThrottle.throttle('queryBySort', const Duration(seconds: 1), () {
      feedBack();
      switch (_sortType) {
        case ReplySortType.time:
          _sortType = ReplySortType.like;
          break;
        case ReplySortType.like:
          _sortType = ReplySortType.time;
          break;
      }
      sortTypeTitle.value = _sortType.titles;
      sortTypeLabel.value = _sortType.labels;
      currentPage = 0;
      noMore.value = '';
      replyList.clear();
      queryReplyList(type: 'init');
    });
  }

  /// 点赞/取消点赞评论
  /// [rpid] 评论id
  /// [action] 1点赞 2取消点赞
  Future likeReply(int rpid, int action) async {
    final res = await ReplyHttp.likeReply(
      type: ReplyType.video.index,
      oid: aid!,
      rpid: rpid,
      action: action,
    );
    if (res['status']) {
      final int index = replyList.indexWhere((e) => e.rpid == rpid);
      if (index != -1) {
        final item = replyList[index];
        item.like = action == 1 ? (item.like ?? 0) + 1 : (item.like ?? 1) - 1;
        item.action = action;
        replyList.refresh();
      }
    }
    return res;
  }
}
