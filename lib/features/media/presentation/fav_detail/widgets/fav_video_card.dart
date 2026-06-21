import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/http/search.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/common/search_type.dart';
import 'package:pilipala/utils/id_utils.dart';
import 'package:pilipala/utils/image_save.dart';
import 'package:pilipala/utils/navigation_helper.dart';
import 'package:pilipala/utils/utils.dart';

class FavVideoCardH extends StatelessWidget {
  const FavVideoCardH({
    super.key,
    required this.videoItem,
    this.callFn,
    this.searchType,
    required this.isOwner,
  });

  final dynamic videoItem;
  final Function? callFn;
  final int? searchType;
  final String isOwner;

  @override
  Widget build(BuildContext context) {
    final int id = videoItem.id;
    final String bvid = videoItem.bvid ?? IdUtils.av2bv(id);
    final String heroTag = Utils.makeHeroTag(id);
    final bool canCancel = searchType != 1 && isOwner == '1';
    final Map? ogv = videoItem.ogv;
    return CleanVideoListTile(
      videoItem: videoItem,
      title: videoItem.title,
      cover: videoItem.pic,
      ownerName: videoItem.owner?.name,
      duration: videoItem.duration,
      pubdate: videoItem.favTime,
      view: videoItem.cntInfo?['play'],
      danmaku: videoItem.cntInfo?['danmaku'],
      topBadgeText: ogv?['type_name']?.toString(),
      trailingIcon: canCancel ? Icons.clear_outlined : null,
      onTrailingPressed: canCancel ? () => _confirmCancel(context) : null,
      onTap: () async {
        String? epId;
        if (ogv != null &&
            (ogv['type_name'] == '番剧' || ogv['type_name'] == '国创')) {
          videoItem.cid = await SearchHttp.ab2c(bvid: bvid);
          epId = videoItem.epId;
        } else if (videoItem.page == 0 || videoItem.page > 1) {
          final result = await VideoHttp.videoIntro(bvid: bvid);
          if (result['status']) {
            epId = result['data'].epId;
          }
        }

        Get.toNamed(
          '/video',
          parameters: {
            'bvid': bvid,
            'cid': videoItem.cid.toString(),
            'epId': epId ?? '',
          },
          arguments: {
            'videoItem': videoItem,
            'heroTag': heroTag,
            'videoType':
                epId != null ? SearchType.media_bangumi : SearchType.video,
          },
        );
      },
      onLongPress: () => imageSaveDialog(
        context,
        videoItem,
        SmartDialog.dismiss,
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('要取消收藏吗?'),
          actions: [
            TextButton(
              onPressed: () => safeBack(),
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                await callFn?.call();
                safeBack();
              },
              child: const Text('确定取消'),
            ),
          ],
        );
      },
    );
  }
}
