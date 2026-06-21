import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_card_h.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/no_data.dart';
import 'package:pilipala/features/user/presentation/member_like/member_like_controller.dart';

class MemberLikePage extends StatefulWidget {
  const MemberLikePage({super.key});

  @override
  State<MemberLikePage> createState() => _MemberLikePageState();
}

class _MemberLikePageState extends State<MemberLikePage> {
  late MemberLikeController _controller;
  late Future _futureBuilderFuture;
  late String heroTag;

  @override
  void initState() {
    super.initState();
    heroTag = 'member_like_${Get.parameters['mid']}';
    _controller = Get.put(MemberLikeController(), tag: heroTag);
    _futureBuilderFuture = _controller.getData();
  }

  @override
  void dispose() {
    Get.delete<MemberLikeController>(tag: heroTag);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _futureBuilderFuture = _controller.getData();
    });
    await _futureBuilderFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text('最近喜欢', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _controller.scrollController,
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const VideoCardHSkeleton(),
                      childCount: 10,
                    ),
                  );
                }
                if (snapshot.data == null || snapshot.data['status'] != true) {
                  return HttpError(
                    errMsg: snapshot.data?['msg'] ?? '请求异常',
                    fn: _onRefresh,
                  );
                }
                return Obx(
                  () => _controller.list.isEmpty
                      ? const NoData()
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => CleanVideoListTile(
                              videoItem: _controller.list[index],
                              showPubdate: true,
                            ),
                            childCount: _controller.list.length,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
