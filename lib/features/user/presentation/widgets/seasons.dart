import 'package:flutter/material.dart';
import 'package:pilipala/models/member/seasons.dart';

/// SeasonsWidget displays the user's seasons.
class SeasonsWidget extends StatelessWidget {
  final List<MemberSeasonsList> seasons;

  const SeasonsWidget({
    super.key,
    required this.seasons,
  });

  @override
  Widget build(BuildContext context) {
    if (seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
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
          itemCount: seasons.length,
          itemBuilder: (context, index) {
            final season = seasons[index];
            return ListTile(
              title: Text(season.meta?.name ?? ''),
              subtitle: Text('${season.meta?.total ?? 0} 个视频'),
              leading: season.meta?.cover != null
                  ? Image.network(
                      season.meta!.cover!,
                      width: 80,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }
}
