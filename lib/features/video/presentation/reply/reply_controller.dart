import 'package:easy_debounce/easy_throttle.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/reply.dart';
import 'package:pilipala/models/common/reply_sort_type.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/storage.dart';

class VideoReplyController extends GetxController {
  VideoReplyController(
    dynamic aid,
    this.rpid,
    this.replyLevel,
  ) {
    this.aid = aid is String ? int.tryParse(aid) : aid;
  }
  int? aid;
  String? replyLevel;
  String? rpid;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  int ps = 20;
  RxInt count = 0.obs;
  ReplyItemModel? currentReplyItem;

  ReplySortType _sortType = ReplySortType.time;
  RxString sortTypeTitle = ReplySortType.time.titles.obs;
  RxString sortTypeLabel = ReplySortType.time.labels.obs;

  Box setting = GStrorage.setting;
  RxInt replyReqCode = 200.obs;

  @override
  void onInit() {
    super.onInit();
    int deaultReplySortIndex =
        setting.get(SettingBoxKey.replySortType, defaultValue: 0) as int;
    if (deaultReplySortIndex == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      deaultReplySortIndex = 0;
    }
    _sortType = ReplySortType.values[deaultReplySortIndex];
    sortTypeTitle.value = _sortType.titles;
    sortTypeLabel.value = _sortType.labels;
  }

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
        if (replies.length == res['data'].page.count) {
          noMore.value = '没有更多了';
        }
        count.value = res['data'].page.count;
        currentPage++;
      } else {
        noMore.value = currentPage == 0 ? '还没有评论' : '没有更多了';
      }
      if (type == 'init') {
        replyList.value = replies;
      } else {
        replyList.addAll(replies);
      }
    }
    isLoadingMore = false;
    return res;
  }

  onLoad() {
    EasyThrottle.throttle('reply', const Duration(seconds: 1), () {
      queryReplyList(type: 'onLoad');
    });
  }

  onChangeSortType() async {
    feedBack();
    int deaultReplySortIndex =
        setting.get(SettingBoxKey.replySortType, defaultValue: 0) as int;
    if (deaultReplySortIndex == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      deaultReplySortIndex = 0;
    }
    _sortType = ReplySortType.values[deaultReplySortIndex];
    sortTypeTitle.value = _sortType.titles;
    sortTypeLabel.value = _sortType.labels;
    await queryReplyList(type: 'init');
  }

  // 新增回复
  addReply(ReplyItemModel replyItem) {
    replyList.insert(0, replyItem);
    count.value++;
  }
}
