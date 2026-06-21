import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/common/widgets/section_header.dart';
import 'package:pilipala/models/member/coin.dart';

class CoinsWidget extends StatelessWidget {
  const CoinsWidget({
    super.key,
    required this.mid,
    required this.coins,
  });

  final int mid;
  final List<MemberCoinsDataModel> coins;

  @override
  Widget build(BuildContext context) {
    if (coins.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<MemberCoinsDataModel> preview = coins.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '最近投币',
          actionText: '更多',
          onAction: () => Get.toNamed('/memberCoin?mid=$mid'),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          itemBuilder: (context, index) {
            return CleanVideoListTile(videoItem: preview[index]);
          },
        ),
      ],
    );
  }
}
