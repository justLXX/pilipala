import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/http/reply.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/video/reply/item.dart';

class VideoReplyReplyController extends GetxController {
  VideoReplyReplyController(dynamic aid, this.rpid, this.replyType) {
    this.aid = aid is String ? int.tryParse(aid) : aid;
  }
  final ScrollController scrollController = ScrollController();
  int? aid;
  String? rpid;
  ReplyType? replyType;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  ReplyItemModel? currentReplyItem;

  @override
  void onInit() {
    super.onInit();
    currentPage = 0;
  }

  Future queryReplyList({type = 'init', currentReply}) async {
    if (type == 'init') {
      currentPage = 0;
    }
    if (isLoadingMore) {
      return;
    }
    isLoadingMore = true;
    final res = await ReplyHttp.replyReplyList(
      oid: aid!,
      root: rpid!,
      pageNum: currentPage + 1,
      type: replyType?.index ?? ReplyType.video.index,
    );
    if (res['status']) {
      final List<ReplyItemModel> replies = res['data'].replies;
      if (replies.isNotEmpty) {
        noMore.value = '加载中...';
        if (replies.length == res['data'].page.count) {
          noMore.value = '没有更多了';
        }
        currentPage++;
      } else {
        noMore.value = currentPage == 0 ? '还没有评论' : '没有更多了';
      }
      if (type == 'init') {
        replyList.value = replies;
      } else {
        if (replies.length == 1 && replies.last.rpid == replyList.last.rpid) {
          return;
        }
        replyList.addAll(replies);
      }
    }
    if (replyList.isNotEmpty && currentReply != null) {
      int indexToRemove =
          replyList.indexWhere((item) => currentReply.rpid == item.rpid);
      if (indexToRemove != -1) {
        replyList.removeAt(indexToRemove);
      }
      if (currentPage == 1 && type == 'init') {
        replyList.insert(0, currentReply);
      }
    }
    isLoadingMore = false;
    return res;
  }

  onLoad() {
    queryReplyList(type: 'onLoad');
  }
}
