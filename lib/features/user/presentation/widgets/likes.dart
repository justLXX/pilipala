import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/common/widgets/section_header.dart';
import 'package:pilipala/models/member/like.dart';

class LikesWidget extends StatelessWidget {
  const LikesWidget({
    super.key,
    required this.mid,
    required this.likes,
  });

  final int mid;
  final List<MemberLikeDataModel> likes;

  @override
  Widget build(BuildContext context) {
    if (likes.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<MemberLikeDataModel> preview = likes.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: '最近喜欢',
          actionText: '更多',
          onAction: () => Get.toNamed('/memberLike?mid=$mid'),
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
