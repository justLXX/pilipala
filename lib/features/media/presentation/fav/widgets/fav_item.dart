import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/utils/utils.dart';

class FavItem extends StatelessWidget {
  final dynamic favFolderItem;
  final bool isOwner;
  const FavItem(
      {super.key, required this.favFolderItem, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(favFolderItem.fid);
    return InkWell(
      onTap: () async {
        Get.toNamed(
          '/favDetail',
          arguments: favFolderItem,
          parameters: {
            'heroTag': heroTag,
            'mediaId': favFolderItem.id.toString(),
            'isOwner': isOwner ? '1' : '0',
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
        child: LayoutBuilder(
          builder: (context, boxConstraints) {
            double width =
                (boxConstraints.maxWidth - StyleString.cardSpace * 5) / 2;
            return SizedBox(
              height: width / StyleString.aspectRatio,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: LayoutBuilder(
                        builder: (context, boxConstraints) {
                          double maxWidth = boxConstraints.maxWidth;
                          double maxHeight = boxConstraints.maxHeight;
                          return Hero(
                            tag: heroTag,
                            child: NetworkImgLayer(
                              src: favFolderItem.cover,
                              width: maxWidth,
                              height: maxHeight,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  VideoContent(favFolderItem: favFolderItem)
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class VideoContent extends StatelessWidget {
  final dynamic favFolderItem;
  const VideoContent({super.key, required this.favFolderItem});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 2, 6, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              favFolderItem.title,
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.32,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${favFolderItem.mediaCount}个内容',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelMedium!.fontSize,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.52),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    [23, 1].contains(favFolderItem.attr) ? '私密' : '公开',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
