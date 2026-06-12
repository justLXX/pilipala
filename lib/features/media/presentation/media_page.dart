import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/features/media/presentation/media_controller.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/utils/utils.dart';

/// MediaPage displays the media library (watch later, history, favorites).
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>
    with AutomaticKeepAliveClientMixin {
  late MediaController _mediaController;
  late Future _favFolderFuture;
  late StreamSubscription _loginSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mediaController = Get.find<MediaController>();
    _favFolderFuture = _mediaController.queryFavFolder();
    _loginSubscription = _mediaController.userLogin.listen((status) {
      setState(() {
        _favFolderFuture = _mediaController.queryFavFolder();
      });
    });
  }

  @override
  void dispose() {
    _loginSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 30),
      body: SingleChildScrollView(
        controller: _mediaController.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 8, bottom: 4),
              child: Text(
                '媒体库',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Navigation items
            for (var item in _mediaController.navList) ...[
              ListTile(
                onTap: () => item['onTap'](),
                dense: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Icon(item['icon'], color: primary),
                ),
                contentPadding:
                    const EdgeInsets.only(left: 15, top: 2, bottom: 2),
                minLeadingWidth: 0,
                title: Text(item['title'], style: const TextStyle(fontSize: 15)),
              ),
            ],
            // Favorites folder section (only shown when logged in)
            Obx(() => _mediaController.userLogin.value
                ? _buildFavFolderSection(context)
                : const SizedBox()),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom +
                  kBottomNavigationBarHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavFolderSection(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 35,
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        ListTile(
          onTap: () => Get.toNamed('/fav'),
          leading: null,
          dense: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Obx(
              () => Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '收藏夹 ',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_mediaController.favFolderData.value.count != null)
                      TextSpan(
                        text: _mediaController.favFolderData.value.count
                            .toString(),
                        style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleSmall!.fontSize,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              setState(() {
                _favFolderFuture = _mediaController.queryFavFolder();
              });
            },
            icon: const Icon(Icons.refresh, size: 20),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.textScalerOf(context).scale(200),
          child: FutureBuilder(
            future: _favFolderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const SizedBox();
                }
                Map data = snapshot.data as Map;
                if (data['status'] == true) {
                  List<FavFolderItemData> favFolderList =
                      _mediaController.favFolderData.value.list ?? [];
                  int favFolderCount =
                      _mediaController.favFolderData.value.count ?? 0;
                  bool hasMore = favFolderCount > favFolderList.length;
                  return Obx(() {
                    final list =
                        _mediaController.favFolderData.value.list ?? [];
                    return ListView.builder(
                      itemCount: list.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (hasMore && index == list.length) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 14, bottom: 35),
                            child: Center(
                              child: IconButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                    (states) => Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withOpacity(0.5),
                                  ),
                                ),
                                onPressed: () => Get.toNamed('/fav'),
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return FavFolderItem(
                            item: list[index],
                            index: index,
                          );
                        }
                      },
                      scrollDirection: Axis.horizontal,
                    );
                  });
                } else {
                  return SizedBox(
                    height: 160,
                    child: Center(
                      child: Text(data['msg'] ?? '加载失败'),
                    ),
                  );
                }
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }
}

class FavFolderItem extends StatelessWidget {
  const FavFolderItem({super.key, this.item, this.index});
  final FavFolderItemData? item;
  final int? index;

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(item!.fid);

    return Container(
      margin: EdgeInsets.only(left: index == 0 ? 20 : 0, right: 14),
      child: GestureDetector(
        onTap: () => Get.toNamed('/favDetail', arguments: item, parameters: {
          'mediaId': item!.id.toString(),
          'heroTag': heroTag,
          'isOwner': '1',
        }),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 180,
              height: 110,
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.onInverseSurface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    offset: const Offset(4, -12),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, BoxConstraints box) {
                  return Hero(
                    tag: heroTag,
                    child: NetworkImgLayer(
                      src: item!.cover,
                      width: box.maxWidth,
                      height: box.maxHeight,
                    ),
                  );
                },
              ),
            ),
            Text(
              ' ${item!.title}',
              overflow: TextOverflow.fade,
              maxLines: 1,
            ),
            Text(
              ' 共${item!.mediaCount}条视频',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall!
                  .copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
