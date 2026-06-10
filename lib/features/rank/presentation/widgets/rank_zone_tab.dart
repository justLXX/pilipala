import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/skeleton/video_card_h.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/video_card_h.dart';
import 'package:pilipala/features/rank/presentation/rank_controller.dart';
import 'package:pilipala/utils/main_stream.dart';

/// A single zone tab inside the ranking page.
///
/// Each instance is identified by its Bilibili zone [rid].
/// It reads all state (video list, scroll controller, future) from the
/// shared [RankController] via `Get.find()`.
class RankZoneTab extends StatefulWidget {
  const RankZoneTab({Key? key, required this.rid}) : super(key: key);

  final int rid;

  @override
  State<RankZoneTab> createState() => _RankZoneTabState();
}

class _RankZoneTabState extends State<RankZoneTab>
    with AutomaticKeepAliveClientMixin {
  late final RankController _rankController;
  late Future _futureBuilderFuture;
  late ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _rankController = Get.find<RankController>();
    _futureBuilderFuture = _rankController.getFuture(widget.rid);
    _scrollController = _rankController.getScrollController(widget.rid);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // The ranking list is a fixed-size result set (≈100 items), so
      // re-requesting is equivalent to "load more".
      if (_rankController.getVideoList(widget.rid).isNotEmpty) {
        // Only trigger if data has already been loaded once.
        _rankController.queryRankFeed(widget.rid);
      }
    }
    handleScrollEvent(_scrollController);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final videoList = _rankController.getVideoList(widget.rid);

    return RefreshIndicator(
      onRefresh: () async {
        final zone = _rankController;
        // Reset the future so FutureBuilder re-runs.
        _futureBuilderFuture = zone.queryRankFeed(widget.rid);
        setState(() {});
        await _futureBuilderFuture;
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(0, StyleString.safeSpace - 5, 0, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final data = snapshot.data as Map;
                  if (data['status'] == true) {
                    return Obx(
                      () => SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return VideoCardH(
                              videoItem: videoList[index],
                              showPubdate: true,
                            );
                          },
                          childCount: videoList.length,
                        ),
                      ),
                    );
                  } else {
                    return HttpError(
                      errMsg: data['msg']?.toString() ?? '加载失败',
                      fn: () {
                        setState(() {
                          _futureBuilderFuture =
                              _rankController.queryRankFeed(widget.rid);
                        });
                      },
                    );
                  }
                } else {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return const VideoCardHSkeleton();
                      },
                      childCount: 10,
                    ),
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
    );
  }
}
