import 'package:flutter/material.dart';
import 'package:pilipala/models/member/like.dart';

/// LikesWidget displays the user's recent likes.
class LikesWidget extends StatelessWidget {
  final List<MemberLikeDataModel> likes;

  const LikesWidget({
    super.key,
    required this.likes,
  });

  @override
  Widget build(BuildContext context) {
    if (likes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '最近喜欢',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: likes.length,
          itemBuilder: (context, index) {
            final like = likes[index];
            return ListTile(
              title: Text(like.title ?? ''),
              subtitle: Text(like.owner?.name ?? ''),
              leading: like.pic != null
                  ? Image.network(
                      like.pic!,
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
