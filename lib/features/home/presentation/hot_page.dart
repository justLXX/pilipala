import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/features/home/presentation/home_controller.dart';
import 'package:pilipala/features/main/presentation/main_controller.dart';

/// HotPage displays the hot video list.
///
/// This is the migrated version using the new architecture.
class HotPage extends StatefulWidget {
  const HotPage({Key? key}) : super(key: key);

  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> with AutomaticKeepAliveClientMixin {
  late final HomeController _homeController;
  Future? _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _futureBuilderFuture = _homeController.loadHotVideos();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        return await _homeController.refreshHotVideos();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            final metrics = notification.metrics;
            if (metrics.pixels >= metrics.maxScrollExtent - 200) {
              if (!_homeController.isHotLoadingMore) {
                _homeController.loadMoreHot();
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
                  final mainStream = Get.find<MainController>().bottomBarStream;
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
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Obx(
                () {
                  if (_homeController.hotVideoList.isNotEmpty) {
                    return _buildScrollView(
                        context,
                        _homeController.hotVideoList.length,
                        (index) => CleanVideoCard(
                              videoItem: _homeController.hotVideoList[index],
                              showPubdate: true,
                            ));
                  } else if (_homeController.hotError.isNotEmpty) {
                    return CustomScrollView(
                      slivers: [
                        HttpError(
                          errMsg: _homeController.hotError,
                          fn: () {
                            setState(() {
                              _futureBuilderFuture =
                                  _homeController.loadHotVideos();
                            });
                          },
                        ),
                      ],
                    );
                  } else {
                    return _buildScrollView(
                        context, 10, (_) => const CleanVideoCardSkeleton());
                  }
                },
              );
            } else {
              return _buildScrollView(
                  context, 10, (_) => const CleanVideoCardSkeleton());
            }
          },
        ),
      ),
    );
  }

  Widget _buildScrollView(
    BuildContext context,
    int childCount,
    Widget Function(int index) builder,
  ) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _buildVideoSliver(context, childCount, builder),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSliver(
    BuildContext context,
    int childCount,
    Widget Function(int index) builder,
  ) {
    final crossAxisCount = _homeVideoGridCount(context);
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 14.0;
        const crossAxisSpacing = 12.0;
        final itemWidth = (constraints.crossAxisExtent -
                horizontalPadding * 2 -
                crossAxisSpacing * (crossAxisCount - 1)) /
            crossAxisCount;
        final itemHeight = itemWidth / StyleString.aspectRatio + 104;
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            horizontalPadding,
            StyleString.safeSpace - 5,
            horizontalPadding,
            0,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: 16,
              mainAxisExtent: itemHeight,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => builder(index),
              childCount: childCount,
            ),
          ),
        );
      },
    );
  }

  int _homeVideoGridCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) {
      return 4;
    }
    if (width >= 1000) {
      return 3;
    }
    return 2;
  }
}
