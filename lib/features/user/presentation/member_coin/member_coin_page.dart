import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/skeleton/video_card_h.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/no_data.dart';
import 'package:pilipala/features/user/presentation/member_coin/member_coin_controller.dart';

class MemberCoinPage extends StatefulWidget {
  const MemberCoinPage({super.key});

  @override
  State<MemberCoinPage> createState() => _MemberCoinPageState();
}

class _MemberCoinPageState extends State<MemberCoinPage> {
  late MemberCoinController _controller;
  late Future _futureBuilderFuture;
  late String heroTag;

  @override
  void initState() {
    super.initState();
    heroTag = 'member_coin_${Get.parameters['mid']}';
    _controller = Get.put(MemberCoinController(), tag: heroTag);
    _futureBuilderFuture = _controller.getData();
  }

  @override
  void dispose() {
    Get.delete<MemberCoinController>(tag: heroTag);
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
        title: Text('最近投币', style: Theme.of(context).textTheme.titleMedium),
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
