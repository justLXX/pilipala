import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_reply.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/http/reply.dart';
import 'package:pilipala/models/video/reply/item.dart';
import 'comment_item.dart';
import 'comment_input_dialog.dart';

class ReplyReplyPanel extends StatefulWidget {
  const ReplyReplyPanel({
    required this.oid,
    required this.rpid,
    required this.firstFloor,
    this.sheetHeight,
    super.key,
  });

  final int oid;
  final int rpid;
  final ReplyItemModel firstFloor;
  final double? sheetHeight;

  @override
  State<ReplyReplyPanel> createState() => _ReplyReplyPanelState();
}

class _ReplyReplyPanelState extends State<ReplyReplyPanel> {
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  int currentPage = 0;
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  late ScrollController scrollController;
  Future? _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _futureBuilderFuture = queryReplyList();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 300) {
      EasyThrottle.throttle('replyReplyList', const Duration(milliseconds: 200),
          () {
        queryReplyList(type: 'onLoad');
      });
    }
  }

  Future queryReplyList({type = 'init'}) async {
    if (type == 'init') {
      currentPage = 0;
    }
    if (isLoadingMore) return;
    isLoadingMore = true;
    final res = await ReplyHttp.replyReplyList(
      oid: widget.oid,
      root: widget.rpid.toString(),
      pageNum: currentPage + 1,
      type: 1,
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
        if (replies.length == 1 &&
            replyList.isNotEmpty &&
            replies.last.rpid == replyList.last.rpid) {
          return;
        }
        replyList.addAll(replies);
      }
    }
    isLoadingMore = false;
    return res;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height =
        widget.sheetHeight ?? MediaQuery.of(context).size.height * 0.75;
    return Container(
      height: height,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 顶部栏
          AppBar(
            toolbarHeight: 45,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Text(
              '评论详情',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  currentPage = 0;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 14),
            ],
          ),
          // 内容区
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                return await queryReplyList();
              },
              child: CustomScrollView(
                controller: scrollController,
                slivers: <Widget>[
                  // 一楼评论
                  SliverToBoxAdapter(
                    child: CommentItem(
                      replyItem: widget.firstFloor,
                      showReplyRow: false,
                      replyLevel: '2',
                      onReply: (replyItem) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (ctx) => Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(ctx).viewInsets.bottom),
                            child: CommentInputDialog(
                              oid: widget.oid,
                              root: widget.rpid,
                              parent: replyItem.rpid ?? 0,
                              replyItem: replyItem,
                            ),
                          ),
                        ).then((value) {
                          if (value != null && value['data'] != null) {
                            replyList.add(value['data']);
                          }
                        });
                      },
                    ),
                  ),
                  // 分割线
                  SliverToBoxAdapter(
                    child: Divider(
                      height: 20,
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                      thickness: 6,
                    ),
                  ),
                  // 二级评论列表
                  FutureBuilder(
                    future: _futureBuilderFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        Map? data = snapshot.data;
                        if (data != null && data['status']) {
                          return Obx(
                            () => SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  if (index == replyList.length) {
                                    return Container(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .padding
                                              .bottom),
                                      height:
                                          MediaQuery.of(context).padding.bottom +
                                              100,
                                      child: Center(
                                        child: Obx(
                                          () => Text(
                                            noMore.value,
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
                                  } else {
                                    return CommentItem(
                                      replyItem: replyList[index],
                                      replyLevel: '2',
                                      showReplyRow: false,
                                      onReply: (replyItem) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (ctx) => Padding(
                                            padding: EdgeInsets.only(
                                                bottom:
                                                    MediaQuery.of(ctx)
                                                        .viewInsets
                                                        .bottom),
                                            child: CommentInputDialog(
                                              oid: widget.oid,
                                              root: widget.rpid,
                                              parent: replyItem.rpid ?? 0,
                                              replyItem: replyItem,
                                            ),
                                          ),
                                        ).then((value) {
                                          if (value != null &&
                                              value['data'] != null) {
                                            replyList.add(value['data']);
                                          }
                                        });
                                      },
                                    );
                                  }
                                },
                                childCount: replyList.length + 1,
                              ),
                            ),
                          );
                        } else {
                          return HttpError(
                            errMsg: data?['msg'] ?? '请求错误',
                            fn: () => setState(() {}),
                          );
                        }
                      } else {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return const VideoReplySkeleton();
                            },
                            childCount: 8,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
