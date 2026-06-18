import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/models/member/seasons.dart';
import 'package:pilipala/utils/utils.dart';

class SeasonsWidget extends StatelessWidget {
  final int mid;
  final List<MemberSeasonsList> seasons;

  const SeasonsWidget({
    super.key,
    required this.mid,
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<MemberSeasonsList> preview = seasons.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
          child: Text(
            '合集',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: preview.length,
          itemBuilder: (context, index) {
            final season = preview[index];
            final meta = season.meta;
            final String category = meta?.category?.toString() ?? '0';
            final String seasonName = Uri.encodeComponent(meta?.name ?? '');
            return ListTile(
              onTap: () => Get.toNamed(
                '/memberSeasons?mid=$mid'
                '&category=$category'
                '&seasonId=${meta?.seasonId ?? 0}'
                '&seriesId=${meta?.seriesId ?? 0}'
                '&seasonName=$seasonName',
              ),
              title: Text(
                meta?.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${Utils.numFormat(meta?.total)} 个视频'),
              leading: SizedBox(
                width: 80,
                height: 52,
                child: NetworkImgLayer(
                  src: meta?.cover,
                  width: 80,
                  height: 52,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
