import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_card_h.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/features/media/presentation/subscription/sub_controller.dart';
import 'package:pilipala/features/media/presentation/subscription/widgets/item.dart';
import 'package:pilipala/utils/route_push.dart';

class SubPage extends StatelessWidget {
  const SubPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 GetX 管理生命周期，避免重复注册警告
    final SubController subController = Get.put(SubController(), permanent: false);
    final Future futureBuilderFuture = subController.querySubFolder();

    return _SubPageBody(
      subController: subController,
      futureBuilderFuture: futureBuilderFuture,
    );
  }
}

class _SubPageBody extends StatefulWidget {
  final SubController subController;
  final Future futureBuilderFuture;

  const _SubPageBody({
    required this.subController,
    required this.futureBuilderFuture,
  });

  @override
  State<_SubPageBody> createState() => _SubPageBodyState();
}

class _SubPageBodyState extends State<_SubPageBody> {
  late ScrollController scrollController;
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = widget.futureBuilderFuture;
    scrollController = widget.subController.scrollController;
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        EasyThrottle.throttle('sub_load_more', const Duration(seconds: 1),
            () {
          widget.subController.onLoad();
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Obx(
          () => Text(
            '${widget.subController.isOwner.value ? '我' : 'Ta'}的订阅',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final Map? data = snapshot.data;
            if (data != null && data['status']) {
              if (widget.subController.subFolderData.value.list!.isNotEmpty) {
                return Obx(
                  () => ListView.builder(
                    controller: scrollController,
                    itemCount:
                        widget.subController.subFolderData.value.list!.length,
                    itemBuilder: (context, index) {
                      return SubItem(
                        subFolderItem: widget
                            .subController.subFolderData.value.list![index],
                        isOwner: widget.subController.isOwner.value,
                        cancelSub: widget.subController.cancelSub,
                      );
                    },
                  ),
                );
              } else {
                return const CustomScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  slivers: [
                    HttpError(errMsg: '', btnText: '没有数据', fn: null)
                  ],
                );
              }
            } else {
              return CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  HttpError(
                    errMsg: data?['msg'] ?? '请求异常',
                    btnText: data?['code'] == -101 ? '去登录' : null,
                    fn: () {
                      if (data?['code'] == -101) {
                        RoutePush.loginRedirectPush();
                      } else {
                        setState(() {
                          _futureBuilderFuture =
                              widget.subController.querySubFolder();
                        });
                      }
                    },
                  ),
                ],
              );
            }
          } else {
            return ListView.builder(
              itemBuilder: (context, index) {
                return const VideoCardHSkeleton();
              },
              itemCount: 10,
            );
          }
        },
      ),
    );
  }
}
