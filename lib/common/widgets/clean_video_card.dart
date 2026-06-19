import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/common/widgets/video_card_h.dart';
import 'package:pilipala/http/search.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/image_save.dart';
import 'package:pilipala/utils/utils.dart';

class CleanVideoCard extends StatelessWidget {
  const CleanVideoCard({
    super.key,
    required this.videoItem,
    this.showPubdate = false,
  });

  final dynamic videoItem;
  final bool showPubdate;

  Future<void> _openVideo() async {
    try {
      final String bvid = videoItem.bvid ?? '';
      if (bvid.isEmpty) {
        SmartDialog.showToast('视频信息不完整');
        return;
      }
      final int? aid = videoItem.aid;
      final int cid =
          videoItem.cid ?? await SearchHttp.ab2c(aid: aid, bvid: bvid);
      final String heroTag = Utils.makeHeroTag(aid ?? bvid);
      Get.toNamed(
        '/video?bvid=$bvid&cid=$cid',
        arguments: {'videoItem': videoItem, 'heroTag': heroTag},
      );
    } catch (err) {
      SmartDialog.showToast(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = videoItem.title ?? '';
    final String cover = videoItem.pic ?? '';
    final String ownerName = videoItem.owner?.name ?? '';
    final int duration = videoItem.duration ?? 0;
    final int view = videoItem.stat?.view ?? 0;
    final int danmaku = _statCount(videoItem.stat, ['danmaku', 'danmu']);
    final int? pubdate = videoItem.pubdate;
    final bool isFollowed = videoItem.isFollowed == 1;
    final String? reason = _reasonText(videoItem);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _openVideo,
      onLongPress: () => imageSaveDialog(
        context,
        videoItem,
        SmartDialog.dismiss,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: StyleString.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Hero(
                        tag: Utils.makeHeroTag(
                            videoItem.aid ?? videoItem.bvid ?? title),
                        child: NetworkImgLayer(
                          src: cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                        ),
                      );
                    },
                  ),
                  if (duration > 0)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: _Badge(text: Utils.timeFormat(duration)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.32,
                ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (isFollowed) ...[
                const _SoftLabel(text: '已关注'),
                const SizedBox(width: 5),
              ] else if (reason != null && reason.isNotEmpty) ...[
                _SoftLabel(text: reason),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  ownerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: () {
                    feedBack();
                    showModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      isScrollControlled: true,
                      builder: (context) => MorePanel(videoItem: videoItem),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            _buildMeta(view, danmaku, pubdate),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  String _buildMeta(int view, int danmaku, int? pubdate) {
    final parts = <String>[
      '${Utils.numFormat(view)}播放',
      '${Utils.numFormat(danmaku)}弹幕',
    ];
    if (showPubdate && pubdate != null && pubdate > 0) {
      parts.add(Utils.formatTimestampToRelativeTime(pubdate));
    }
    return parts.join('  ');
  }

  String? _reasonText(dynamic item) {
    try {
      final reason = item.rcmdReason;
      if (reason is String) return reason;
      return reason?.content;
    } catch (_) {
      return null;
    }
  }
}

class CleanVideoCardSkeleton extends StatelessWidget {
  const CleanVideoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onInverseSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: StyleString.aspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(width: double.infinity, height: 12, color: color),
        const SizedBox(height: 6),
        FractionallySizedBox(
          widthFactor: 0.72,
          child: Container(height: 12, color: color),
        ),
        const SizedBox(height: 10),
        FractionallySizedBox(
          widthFactor: 0.52,
          child: Container(height: 10, color: color),
        ),
      ],
    );
  }
}

class CleanVideoListTile extends StatelessWidget {
  const CleanVideoListTile({
    super.key,
    required this.videoItem,
    this.showPubdate = false,
  });

  final dynamic videoItem;
  final bool showPubdate;

  Future<void> _openVideo() async {
    try {
      final String bvid = videoItem.bvid ?? '';
      if (bvid.isEmpty) {
        SmartDialog.showToast('视频信息不完整');
        return;
      }
      final int? aid = videoItem.aid;
      final int cid =
          videoItem.cid ?? await SearchHttp.ab2c(aid: aid, bvid: bvid);
      final String heroTag = Utils.makeHeroTag(aid ?? bvid);
      Get.toNamed(
        '/video?bvid=$bvid&cid=$cid',
        arguments: {'videoItem': videoItem, 'heroTag': heroTag},
      );
    } catch (err) {
      SmartDialog.showToast(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final int view = videoItem.stat?.view ?? 0;
    final int danmaku = _statCount(videoItem.stat, ['danmaku', 'danmu']);
    final int? pubdate = videoItem.pubdate;
    final int duration = videoItem.duration ?? 0;
    return InkWell(
      onTap: _openVideo,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 132,
              child: AspectRatio(
                aspectRatio: StyleString.aspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return NetworkImgLayer(
                            src: videoItem.pic ?? '',
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                          );
                        },
                      ),
                      if (duration > 0)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: _Badge(text: Utils.timeFormat(duration)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoItem.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    videoItem.owner?.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _buildMeta(view, danmaku, pubdate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildMeta(int view, int danmaku, int? pubdate) {
    final parts = <String>[
      '${Utils.numFormat(view)}播放',
      '${Utils.numFormat(danmaku)}弹幕',
    ];
    if (showPubdate && pubdate != null && pubdate > 0) {
      parts.add(Utils.formatTimestampToRelativeTime(pubdate));
    }
    return parts.join('  ');
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }
}

int _statCount(dynamic stat, List<String> fields) {
  if (stat == null) return 0;
  for (final field in fields) {
    try {
      final value = field == 'danmaku'
          ? stat.danmaku
          : field == 'danmu'
              ? stat.danmu
              : field == 'view'
                  ? stat.view
                  : null;
      if (value is int) return value;
    } catch (_) {}
  }
  return 0;
}

class _SoftLabel extends StatelessWidget {
  const _SoftLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
