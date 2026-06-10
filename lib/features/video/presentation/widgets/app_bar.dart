import 'package:flutter/material.dart';
import 'package:pilipala/models/video_detail_res.dart';

/// AppBarWidget displays the video action bar (like, coin, collect, share).
class AppBarWidget extends StatelessWidget {
  final VideoDetailData videoDetail;
  final bool isLiked;
  final bool isCollected;
  final bool isCoined;
  final VoidCallback onLike;
  final VoidCallback onCollect;
  final VoidCallback onCoin;

  const AppBarWidget({
    super.key,
    required this.videoDetail,
    required this.isLiked,
    required this.isCollected,
    required this.isCoined,
    required this.onLike,
    required this.onCollect,
    required this.onCoin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: '点赞',
            color: isLiked ? Colors.red : null,
            onPressed: onLike,
          ),
          _buildActionButton(
            icon: isCoined ? Icons.monetization_on : Icons.monetization_on_outlined,
            label: '投币',
            color: isCoined ? Colors.orange : null,
            onPressed: onCoin,
          ),
          _buildActionButton(
            icon: isCollected ? Icons.star : Icons.star_outline,
            label: '收藏',
            color: isCollected ? Colors.yellow.shade700 : null,
            onPressed: onCollect,
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: '分享',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    VoidCallback? onPressed,
  }) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
        label: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}
