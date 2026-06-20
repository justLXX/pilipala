import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/skeleton/video_card_h.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/common/widgets/no_data.dart';
import 'package:pilipala/features/user/presentation/member_coin/member_coin_controller.dart';
import 'package:pilipala/models/member/coin.dart';
import 'package:pilipala/utils/utils.dart';

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
                            (context, index) => _CoinItem(
                              coin: _controller.list[index],
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

class _CoinItem extends StatelessWidget {
  const _CoinItem({required this.coin});

  final MemberCoinsDataModel coin;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(
        '/video?bvid=${coin.bvid}&cid=${coin.cid ?? 0}',
        arguments: {'heroTag': Utils.makeHeroTag(coin.aid)},
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          StyleString.safeSpace,
          6,
          StyleString.safeSpace,
          6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 142,
              height: 88,
              child: Stack(
                children: [
                  NetworkImgLayer(src: coin.pic, width: 142, height: 88),
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: _Badge(text: Utils.timeFormat(coin.duration ?? 0)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Text(
                      coin.owner?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${Utils.numFormat(coin.view)}播放  ${Utils.numFormat(coin.danmaku)}弹幕  ${Utils.dateFormat(coin.pubdate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }
}
