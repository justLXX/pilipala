import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_reply.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/features/video/presentation/reply_reply/reply_reply_controller.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'package:pilipala/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:pilipala/pages/video/detail/reply_new/index.dart';
import 'package:pilipala/utils/feed_back.dart';

class VideoReplyReplyPage extends StatefulWidget {
  final int? oid;
  final String? root;
  final String? rpid;
  final ReplyType? replyType;
  final ReplyItemModel? currentReply;

  const VideoReplyReplyPage({
    super.key,
    this.oid,
    this.root,
    this.rpid,
    this.replyType,
    this.currentReply,
  });

  @override
  State<VideoReplyReplyPage> createState() => _VideoReplyReplyPageState();
}

class _VideoReplyReplyPageState extends State<VideoReplyReplyPage> {
  late VideoReplyReplyController _videoReplyReplyController;
  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _videoReplyReplyController = Get.put(
        VideoReplyReplyController(widget.oid, widget.root, widget.replyType),
        tag: widget.root);
    _futureBuilderFuture = _videoReplyReplyController.queryReplyList(
        currentReply: widget.currentReply);
    scrollController = _videoReplyReplyController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'reply_reply', const Duration(milliseconds: 1000), () {
            _videoReplyReplyController.onLoad();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text('回复列表', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return await _videoReplyReplyController.queryReplyList(
              type: 'init', currentReply: widget.currentReply);
        },
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                Map data = snapshot.data as Map;
                if (data['status']) {
                  return Obx(
                    () => _videoReplyReplyController.replyList.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount:
                                _videoReplyReplyController.replyList.length + 1,
                            itemBuilder: (context, index) {
                              if (index ==
                                  _videoReplyReplyController.replyList.length) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).padding.bottom + 60,
                                  padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).padding.bottom),
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        _videoReplyReplyController.noMore.value,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                            fontSize: 13),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return ReplyItem(
                                  replyItem:
                                      _videoReplyReplyController.replyList[index],
                                  replyType: widget.replyType ?? ReplyType.video,
                                );
                              }
                            },
                          )
                        : CustomScrollView(
                            slivers: [
                              HttpError(
                                errMsg: _videoReplyReplyController.noMore.value,
                                fn: () {},
                              )
                            ],
                          ),
                  );
                } else {
                  return HttpError(
                    errMsg: data['msg'],
                    fn: () {},
                  );
                }
              } else {
                return const SizedBox();
              }
            } else {
              return ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return const VideoReplySkeleton();
                },
              );
            }
          },
        ),
      ),
    );
  }
}
