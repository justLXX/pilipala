import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/skeleton/skeleton.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/utils/utils.dart';

import 'whisper_controller.dart';

class WhisperPage extends StatefulWidget {
  const WhisperPage({super.key});

  @override
  State<WhisperPage> createState() => _WhisperPageState();
}

class _WhisperPageState extends State<WhisperPage> {
  late final WhisperController _whisperController =
      Get.find<WhisperController>();
  late Future _futureBuilderFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _whisperController.querySessionList('init');
    _scrollController.addListener(_scrollListener);
  }

  Future _scrollListener() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      EasyThrottle.throttle('my-throttler', const Duration(milliseconds: 800),
          () async {
        await _whisperController.onLoad();
        _whisperController.isLoading = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: const Text('消息'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _whisperController.unread();
          await _whisperController.onRefresh();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  // 在这里根据父级容器的约束条件构建小部件树
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                    child: SizedBox(
                      height: constraints.maxWidth / 4.2,
                      child: Obx(
                        () => GridView.count(
                          primary: false,
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          padding: EdgeInsets.zero,
                          children: [
                            ..._whisperController.noticesList.map((element) {
                              return Material(
                                color: Colors.transparent,
                                borderRadius: StyleString.lgRadius,
                                child: InkWell(
                                  onTap: () {
                                    if (['/messageAt']
                                        .contains(element['path'])) {
                                      SmartDialog.showToast('功能开发中');
                                      return;
                                    }
                                    Get.toNamed(element['path']);

                                    if (element['count'] > 0) {
                                      element['count'] = 0;
                                    }
                                    _whisperController.noticesList.refresh();
                                  },
                                  onLongPress: () {},
                                  borderRadius: StyleString.lgRadius,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.36),
                                      borderRadius: StyleString.lgRadius,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Badge(
                                          isLabelVisible: element['count'] > 0,
                                          label: Text(element['count'] > 99
                                              ? '99+'
                                              : element['count'].toString()),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              element['icon'],
                                              size: 21,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(element['title'])
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    Map? data = snapshot.data;
                    if (data != null && data['status']) {
                      RxList sessionList = _whisperController.sessionList;
                      return Obx(
                        () => sessionList.isEmpty
                            ? const SizedBox()
                            : ListView.builder(
                                itemCount: sessionList.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.fromLTRB(12, 0, 12, 24),
                                itemBuilder: (_, int i) {
                                  return SessionItem(
                                    sessionItem: sessionList[i],
                                    changeFucCall: () => sessionList.refresh(),
                                  );
                                },
                              ),
                      );
                    } else {
                      // 请求错误
                      return Center(
                        child: Text(data?['msg'] ?? '请求异常'),
                      );
                    }
                  } else {
                    // 骨架屏
                    return ListView.builder(
                      itemCount: 15,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, int i) {
                        return Skeleton(
                          child: ListTile(
                            leading: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onInverseSurface,
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            title: Container(
                              width: 100,
                              height: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            ),
                            subtitle: Container(
                              width: 80,
                              height: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionItem extends StatelessWidget {
  final dynamic sessionItem;
  final Function changeFucCall;

  const SessionItem({
    super.key,
    required this.sessionItem,
    required this.changeFucCall,
  });

  @override
  Widget build(BuildContext context) {
    final String heroTag = Utils.makeHeroTag(sessionItem.accountInfo?.mid ?? 0);
    final content = sessionItem.lastMsg.content;
    final msgStatus = sessionItem.lastMsg.msgStatus;
    final int msgType = sessionItem.lastMsg.msgType;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.34),
        shape: RoundedRectangleBorder(
          borderRadius: StyleString.lgRadius,
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
          ),
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: StyleString.lgRadius),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          onTap: () {
            sessionItem.unreadCount = 0;
            changeFucCall.call();
            Get.toNamed(
              '/whisperDetail',
              parameters: {
                'talkerId': sessionItem.talkerId.toString(),
                'name': sessionItem.accountInfo.name,
                'face': sessionItem.accountInfo.face,
                'mid': (sessionItem.accountInfo?.mid ?? 0).toString(),
                'heroTag': heroTag,
              },
            );
          },
          leading: Badge(
            isLabelVisible: sessionItem.unreadCount > 0,
            label: Text(sessionItem.unreadCount.toString()),
            alignment: Alignment.topRight,
            child: Hero(
              tag: heroTag,
              child: NetworkImgLayer(
                width: 45,
                height: 45,
                type: 'avatar',
                src: sessionItem.accountInfo.face,
              ),
            ),
          ),
          title: Text(sessionItem.accountInfo.name),
          subtitle: Text(
              msgStatus == 1
                  ? '你撤回了一条消息'
                  : msgType == 2
                      ? '[图片]'
                      : content != null && content != ''
                          ? (content['text'] ??
                              content['content'] ??
                              content['title'] ??
                              content['reply_content'] ??
                              '不支持的消息类型')
                          : '不支持的消息类型',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: Theme.of(context).colorScheme.outline)),
          trailing: Text(
            Utils.dateFormat(sessionItem.lastMsg.timestamp),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
