import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/http/search.dart';
import 'package:url_launcher/url_launcher.dart';

/// 附加面板组件
Widget addWidget(item, context, type, {floor = 1}) {
  Map<dynamic, dynamic> dynamicProperty = {
    'ADDITIONAL_TYPE_UGC': item.modules.moduleDynamic.additional.ugc,
    'ADDITIONAL_TYPE_RESERVE': item.modules.moduleDynamic.additional.reserve,
    'ADDITIONAL_TYPE_GOODS': item.modules.moduleDynamic.additional.goods,
    'ADDITIONAL_TYPE_MATCH': item.modules.moduleDynamic.additional.match,
    'ADDITIONAL_TYPE_COMMON': item.modules.moduleDynamic.additional.common,
  };
  Color bgColor = floor == 1
      ? Theme.of(context).dividerColor.withOpacity(0.08)
      : Theme.of(context).colorScheme.surface;
  switch (type) {
    case 'ADDITIONAL_TYPE_UGC':
      return InkWell(
        onTap: () async {
          String text = dynamicProperty[type].jumpUrl;
          RegExp bvRegex = RegExp(r'BV[0-9A-Za-z]{10}', caseSensitive: false);
          Iterable<Match> matches = bvRegex.allMatches(text);
          if (matches.isNotEmpty) {
            Match match = matches.first;
            String bvid = match.group(0)!;
            String cover = dynamicProperty[type].cover;
            try {
              int cid = await SearchHttp.ab2c(bvid: bvid);
              Get.toNamed('/video?bvid=$bvid&cid=$cid',
                  arguments: {'pic': cover, 'heroTag': bvid});
            } catch (err) {
              SmartDialog.showToast(err.toString());
            }
          }
        },
        child: Container(
          padding:
              const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
          color: bgColor,
          child: Row(
            children: [
              NetworkImgLayer(
                width: 120,
                height: 75,
                src: dynamicProperty[type].cover,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      dynamicProperty[type].title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dynamicProperty[type].descSecond,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize:
                            Theme.of(context).textTheme.labelMedium!.fontSize,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    case 'ADDITIONAL_TYPE_RESERVE':
      return dynamicProperty[type].state != -1
          ? dynamicProperty[type].title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      if (dynamicProperty[type].jumpUrl != null) {
                        String url = dynamicProperty[type].jumpUrl;
                        if (url.startsWith('//')) {
                          url = 'https:$url';
                        }
                        launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 12, top: 10, right: 12, bottom: 10),
                      color: bgColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dynamicProperty[type].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text.rich(
                            TextSpan(
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .fontSize),
                              children: [
                                if (dynamicProperty[type].desc1 != null)
                                  TextSpan(
                                      text:
                                          dynamicProperty[type].desc1['text']),
                                const TextSpan(text: '  '),
                                if (dynamicProperty[type].desc2 != null)
                                  TextSpan(
                                      text:
                                          dynamicProperty[type].desc2['text']),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox()
          : const SizedBox();
    case 'ADDITIONAL_TYPE_GOODS':
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: InkWell(
          onTap: () {
            if (dynamicProperty[type].jumpUrl != null) {
              String url = dynamicProperty[type].jumpUrl;
              if (url.startsWith('//')) {
                url = 'https:$url';
              }
              launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Row(
              children: [
                if (dynamicProperty[type].items != null &&
                    dynamicProperty[type].items.isNotEmpty)
                  NetworkImgLayer(
                    width: 75,
                    height: 75,
                    src: dynamicProperty[type].items.first.cover,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (dynamicProperty[type].items != null &&
                          dynamicProperty[type].items.isNotEmpty) ...[
                        Text(
                          dynamicProperty[type].items.first.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dynamicProperty[type].items.first.brief,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .fontSize,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dynamicProperty[type].items.first.price,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    case 'ADDITIONAL_TYPE_MATCH':
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: InkWell(
          onTap: () {
            if (dynamicProperty[type].jumpUrl != null) {
              String url = dynamicProperty[type].jumpUrl;
              if (url.startsWith('//')) {
                url = 'https:$url';
              }
              launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
                left: 12, top: 10, right: 12, bottom: 10),
            color: bgColor,
            child: Text(
              dynamicProperty[type].title ?? '比赛信息',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    case 'ADDITIONAL_TYPE_COMMON':
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: InkWell(
          onTap: () {
            if (dynamicProperty[type].jumpUrl != null) {
              String url = dynamicProperty[type].jumpUrl;
              if (url.startsWith('//')) {
                url = 'https:$url';
              }
              launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, top: 8, right: 12, bottom: 8),
            color: bgColor,
            child: Row(
              children: [
                if (dynamicProperty[type].cover != null)
                  NetworkImgLayer(
                    width: 75,
                    height: 75,
                    src: dynamicProperty[type].cover,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        dynamicProperty[type].title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dynamicProperty[type].desc != null)
                        Text(
                          dynamicProperty[type].desc,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelMedium!
                                .fontSize,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    case 'ADDITIONAL_TYPE_VOTE':
      return const SizedBox();
    default:
      return const SizedBox();
  }
}
