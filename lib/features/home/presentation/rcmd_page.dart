import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/skeleton/video_card_h.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/video_card_h.dart';
import 'package:pilipala/features/home/presentation/home_controller.dart';
import 'package:pilipala/features/main/presentation/main_controller.dart';

/// RcmdPage displays the recommended video list.
///
/// This is the migrated version using the new architecture.
class RcmdPage extends StatefulWidget {
  const RcmdPage({Key? key}) : super(key: key);

  @override
  State<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends State<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  late final HomeController _homeController;
  Future? _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _futureBuilderFuture = _homeController.loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        return await _homeController.refreshVideos();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              if (!_homeController.isLoadingMore) {
                _homeController.loadMore();
              }
            }
          }
          if (notification is UserScrollNotification) {
            final direction = notification.direction;
            EasyThrottle.throttle(
              'stream-throttler',
              const Duration(milliseconds: 300),
              () {
                try {
                  final mainStream =
                      Get.find<MainController>().bottomBarStream;
                  if (direction == ScrollDirection.forward) {
                    mainStream.add(true);
                  } else if (direction == ScrollDirection.reverse) {
                    mainStream.add(false);
                  }
                } catch (_) {}
              },
            );
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(0, StyleString.safeSpace - 5, 0, 0),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Obx(
                      () {
                        if (_homeController.videoList.isNotEmpty) {
                          return SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              return VideoCardH(
                                videoItem: _homeController.videoList[index],
                                showPubdate: true,
                              );
                            }, childCount: _homeController.videoList.length),
                          );
                        } else if (_homeController.error.isNotEmpty) {
                          return HttpError(
                            errMsg: _homeController.error,
                            fn: () {
                              setState(() {
                                _futureBuilderFuture =
                                    _homeController.loadVideos();
                              });
                            },
                          );
                        } else {
                          return SliverList(
                            delegate:
                                SliverChildBuilderDelegate((context, index) {
                              return const VideoCardHSkeleton();
                            }, childCount: 10),
                          );
                        }
                      },
                    );
                  } else {
                    // Skeleton screen
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return const VideoCardHSkeleton();
                      }, childCount: 10),
                    );
                  }
                },
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 10,
              ),
            )
          ],
        ),
      ),
    );
  }
}
