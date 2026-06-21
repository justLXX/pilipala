import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/clean_video_card.dart';
import 'package:pilipala/http/search.dart';
import 'package:pilipala/models/common/search_type.dart';
import 'package:pilipala/models/user/sub_detail.dart';
import 'package:pilipala/utils/image_save.dart';
import 'package:pilipala/utils/utils.dart';

class SubVideoCardH extends StatelessWidget {
  const SubVideoCardH({
    super.key,
    required this.videoItem,
    this.searchType,
  });

  final SubDetailMediaItem videoItem;
  final int? searchType;

  @override
  Widget build(BuildContext context) {
    final int id = videoItem.id ?? 0;
    final String bvid = videoItem.bvid ?? '';
    final String heroTag = Utils.makeHeroTag(id);
    return CleanVideoListTile(
      videoItem: videoItem,
      title: videoItem.title,
      cover: videoItem.cover,
      ownerName: videoItem.upper?['name']?.toString(),
      duration: videoItem.duration,
      pubdate: videoItem.pubtime,
      view: videoItem.cntInfo?['play'],
      danmaku: videoItem.cntInfo?['danmaku'],
      onTap: () async {
        final int cid = await SearchHttp.ab2c(bvid: bvid);
        Get.toNamed(
          '/video',
          parameters: {
            'bvid': bvid,
            'cid': cid.toString(),
          },
          arguments: {
            'videoItem': videoItem,
            'heroTag': heroTag,
            'videoType': SearchType.video,
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
}
