import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/media_overlay_badge.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/common/widgets/video_card_h.dart';
import 'package:pilipala/http/constants.dart';
import 'package:pilipala/http/search.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/image_save.dart';
import 'package:pilipala/utils/route_push.dart';
import 'package:pilipala/utils/url_utils.dart';
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
      final int cid = await _resolveCid(videoItem, aid: aid, bvid: bvid);
      final String heroTag = Utils.makeHeroTag(aid ?? bvid);
      Get.toNamed(
        '/video?bvid=$bvid&cid=$cid',
        arguments: {'videoItem': videoItem, 'heroTag': heroTag},
        preventDuplicates: false,
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
    final dynamic duration = videoItem.duration ?? 0;
    final int view = videoItem.stat?.view ?? 0;
    final int danmaku = _statCount(videoItem.stat, ['danmaku', 'danmu']);
    final int? pubdate = videoItem.pubdate;
    final bool isFollowed = _checkFollowed(videoItem);
    final String? reason = _reasonText(videoItem);

    return Material(
      color: Colors.transparent,
      borderRadius: StyleString.lgRadius,
      child: InkWell(
        borderRadius: StyleString.lgRadius,
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
                borderRadius: const BorderRadius.all(StyleString.imgRadius),
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
                    if (_hasDuration(duration))
                      Positioned(
                        right: 6,
                        bottom: 6,
                        child: MediaOverlayBadge(
                          text: _durationText(duration),
                        ),
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
            const SizedBox(height: 1),
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

  bool _checkFollowed(dynamic item) {
    try {
      return item.isFollowed == 1;
    } catch (_) {
      return false;
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
              borderRadius: const BorderRadius.all(StyleString.imgRadius),
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
    this.showCharge = false,
    this.onTap,
    this.onLongPress,
    this.title,
    this.cover,
    this.ownerName,
    this.duration,
    this.view,
    this.danmaku,
    this.pubdate,
    this.topBadgeText,
    this.trailingIcon,
    this.onTrailingPressed,
  });

  final dynamic videoItem;
  final bool showPubdate;
  final bool showCharge;
  final Future<void> Function()? onTap;
  final VoidCallback? onLongPress;
  final String? title;
  final String? cover;
  final String? ownerName;
  final dynamic duration;
  final int? view;
  final int? danmaku;
  final int? pubdate;
  final String? topBadgeText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingPressed;

  Future<void> _openVideo() async {
    try {
      if (onTap != null) {
        await onTap!();
        return;
      }
      final String bvid = videoItem.bvid ?? '';
      if (bvid.isEmpty) {
        SmartDialog.showToast('视频信息不完整');
        return;
      }
      if (showCharge &&
          _fieldValue(videoItem, ['typeid']) == 33 &&
          _fieldValue(videoItem, ['isChargingSrc']) == true) {
        final String redirectUrl = await UrlUtils.parseRedirectUrl(
            '${HttpString.baseUrl}/video/$bvid/');
        final String lastPathSegment = redirectUrl.split('/').last;
        if (lastPathSegment.contains('ss')) {
          RoutePush.bangumiPush(Utils.matchNum(lastPathSegment).first, null);
        }
        if (lastPathSegment.contains('ep')) {
          RoutePush.bangumiPush(null, Utils.matchNum(lastPathSegment).first);
        }
        return;
      }
      final int? aid = videoItem.aid;
      final int cid = await _resolveCid(videoItem, aid: aid, bvid: bvid);
      final String heroTag = Utils.makeHeroTag(aid ?? bvid);
      Get.toNamed(
        '/video?bvid=$bvid&cid=$cid',
        arguments: {'videoItem': videoItem, 'heroTag': heroTag},
        preventDuplicates: false,
      );
    } catch (err) {
      SmartDialog.showToast(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final int view = this.view ??
        _fieldValue(videoItem, ['view']) ??
        _statCount(_fieldValue(videoItem, ['stat']), ['view']);
    final int danmaku = this.danmaku ??
        _fieldValue(videoItem, ['danmaku', 'danmu']) ??
        _statCount(_fieldValue(videoItem, ['stat']), ['danmaku', 'danmu']);
    final int? pubdate =
        this.pubdate ?? _fieldValue(videoItem, ['pubdate', 'pubtime']);
    final dynamic duration =
        this.duration ?? _fieldValue(videoItem, ['duration']) ?? 0;
    final String title = this.title ?? _fieldValue(videoItem, ['title']) ?? '';
    final String cover =
        this.cover ?? _fieldValue(videoItem, ['pic', 'cover']) ?? '';
    final String ownerName = this.ownerName ??
        _ownerName(_fieldValue(videoItem, ['owner', 'upper'])) ??
        '';
    return Material(
      color: Colors.transparent,
      borderRadius: StyleString.mdRadius,
      child: InkWell(
        onTap: _openVideo,
        onLongPress: onLongPress,
        borderRadius: StyleString.mdRadius,
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
                    borderRadius: const BorderRadius.all(StyleString.imgRadius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return NetworkImgLayer(
                              src: cover,
                              width: constraints.maxWidth,
                              height: constraints.maxHeight,
                            );
                          },
                        ),
                        if (_hasDuration(duration))
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: MediaOverlayBadge(
                              text: _durationText(duration),
                            ),
                          ),
                        if (showCharge &&
                            _fieldValue(videoItem, ['isChargingSrc']) == true)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: MediaOverlayBadge(
                              text: '充电专属',
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        if (topBadgeText != null && topBadgeText!.isNotEmpty)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: MediaOverlayBadge(
                              text: topBadgeText!,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
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
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ownerName,
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
              if (trailingIcon != null && onTrailingPressed != null) ...[
                const SizedBox(width: 4),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onTrailingPressed,
                    icon: Icon(
                      trailingIcon,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ],
          ),
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

Future<int> _resolveCid(
  dynamic videoItem, {
  required int? aid,
  required String bvid,
}) async {
  final dynamic rawCid = _fieldValue(videoItem, ['cid']);
  if (rawCid is int && rawCid > 0) {
    return rawCid;
  }
  if (rawCid is String) {
    final cid = int.tryParse(rawCid);
    if (cid != null && cid > 0) {
      return cid;
    }
  }
  final cid = await SearchHttp.ab2c(aid: aid, bvid: bvid);
  return cid;
}

dynamic _fieldValue(dynamic item, List<String> fields) {
  if (item == null) return null;
  for (final field in fields) {
    try {
      final value = switch (field) {
        'aid' => item.aid,
        'bvid' => item.bvid,
        'cid' => item.cid,
        'cover' => item.cover,
        'danmaku' => item.danmaku,
        'danmu' => item.danmu,
        'duration' => item.duration,
        'owner' => item.owner,
        'pic' => item.pic,
        'pubdate' => item.pubdate,
        'pubtime' => item.pubtime,
        'stat' => item.stat,
        'title' => item.title,
        'typeid' => item.typeid,
        'view' => item.view,
        'isChargingSrc' => item.isChargingSrc,
        'upper' => item.upper,
        _ => null,
      };
      if (value != null) return value;
    } catch (_) {}
  }
  return null;
}

String? _ownerName(dynamic owner) {
  if (owner == null) return null;
  if (owner is Map) {
    return owner['name']?.toString();
  }
  try {
    return owner.name;
  } catch (_) {
    return null;
  }
}

bool _hasDuration(dynamic duration) {
  if (duration == null) return false;
  if (duration is int) return duration > 0;
  if (duration is String) return duration.isNotEmpty && duration != '0';
  return false;
}

String _durationText(dynamic duration) {
  if (duration is String) return Utils.timeFormat(duration);
  return Utils.timeFormat(duration ?? 0);
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
