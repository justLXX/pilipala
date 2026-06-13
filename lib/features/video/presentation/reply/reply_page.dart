import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_reply.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/models/common/reply_type.dart';
import 'package:pilipala/features/video/presentation/reply/reply_controller.dart';
import 'package:pilipala/pages/video/detail/reply/widgets/reply_item.dart';
import 'package:pilipala/pages/video/detail/reply_new/index.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/id_utils.dart';

class VideoReplyPanel extends StatefulWidget {
  final String? bvid;
  final int? oid;
  final int rpid;
  final String? replyLevel;
  final Function(ScrollController)? onControllerCreated;

  const VideoReplyPanel({
    this.bvid,
    this.oid,
    this.rpid = 0,
    this.replyLevel,
    this.onControllerCreated,
    super.key,
  });

  @override
  State<VideoReplyPanel> createState() => _VideoReplyPanelState();
}

class _VideoReplyPanelState extends State<VideoReplyPanel>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late VideoReplyController _videoReplyController;
  late AnimationController fabAnimationCtr;
  late ScrollController scrollController;

  Future? _futureBuilderFuture;
  bool _isFabVisible = true;
  String replyLevel = '1';
  late String heroTag;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    heroTag = Get.arguments['heroTag'];
    replyLevel = widget.replyLevel ?? '1';
    if (replyLevel == '2') {
      _videoReplyController = Get.put(
          VideoReplyController(widget.oid, widget.rpid.toString(), replyLevel),
          tag: widget.rpid.toString());
    } else {
      _videoReplyController = Get.put(
          VideoReplyController(widget.oid, '', replyLevel),
          tag: heroTag);
    }

    fabAnimationCtr = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _futureBuilderFuture = _videoReplyController.queryReplyList();
    scrollController = ScrollController();
    widget.onControllerCreated?.call(scrollController);
    fabAnimationCtr.forward();
    scrollListener();
  }

  void scrollListener() {
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          _videoReplyController.onLoad();
        }
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          if (_isFabVisible) {
            _isFabVisible = false;
            fabAnimationCtr.reverse();
          }
        }
        if (scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (!_isFabVisible) {
            _isFabVisible = true;
            fabAnimationCtr.forward();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    fabAnimationCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: ScaleTransition(
        scale: fabAnimationCtr,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () async {
            feedBack();
            var result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) {
                return VideoReplyNewDialog(
                  oid: widget.oid,
                  root: widget.rpid,
                  parent: widget.rpid,
                  replyType: ReplyType.video,
                );
              },
            );
            if (result != null && result['data'] != null) {
              _videoReplyController.addReply(result['data']);
              scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
            }
          },
          child: const Icon(Icons.edit),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          return await _videoReplyController.queryReplyList(type: 'init');
        },
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data != null) {
                Map data = snapshot.data as Map;
                if (data['status']) {
                  return Obx(
                    () => _videoReplyController.replyList.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount:
                                _videoReplyController.replyList.length + 1,
                            itemBuilder: (context, index) {
                              if (index ==
                                  _videoReplyController.replyList.length) {
                                return Container(
                                  height:
                                      MediaQuery.of(context).padding.bottom + 60,
                                  padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(context).padding.bottom),
                                  child: Center(
                                    child: Obx(
                                      () => Text(
                                        _videoReplyController.noMore.value,
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
                                      _videoReplyController.replyList[index],
                                  replyType: ReplyType.video,
                                );
                              }
                            },
                          )
                        : CustomScrollView(
                            slivers: [
                              HttpError(
                                errMsg: _videoReplyController.noMore.value,
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
