import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/models/member/coin.dart';
import 'package:pilipala/utils/utils.dart';

class CoinsWidget extends StatelessWidget {
  final int mid;
  final List<MemberCoinsDataModel> coins;

  const CoinsWidget({
    super.key,
    required this.mid,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<MemberCoinsDataModel> preview = coins.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
          child: Row(
            children: [
              Text(
                '最近投币',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed('/memberCoin?mid=$mid'),
                child: const Text('更多'),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          itemBuilder: (context, index) {
            return _CoinItem(coin: preview[index]);
          },
        ),
      ],
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
              width: 128,
              height: 80,
              child: Stack(
                children: [
                  NetworkImgLayer(src: coin.pic, width: 128, height: 80),
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
                height: 80,
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
                      '${Utils.numFormat(coin.view)}播放  ${Utils.numFormat(coin.danmaku)}弹幕',
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
