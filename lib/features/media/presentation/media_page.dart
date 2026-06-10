import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/features/media/presentation/media_controller.dart';
import 'package:pilipala/utils/utils.dart';

/// MediaPage displays the media library (watch later, history, favorites).
class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  late MediaController _mediaController;
  late Future _watchLaterFuture;

  @override
  void initState() {
    super.initState();
    _mediaController = Get.find<MediaController>();
    _watchLaterFuture = _mediaController.loadWatchLater();
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(toolbarHeight: 30),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '媒体库',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Navigation items
            ListTile(
              onTap: () => Get.toNamed('/later'),
              leading: Icon(Icons.watch_later_outlined, color: primary),
              title: const Text('稍后再看', style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              onTap: () => Get.toNamed('/history'),
              leading: Icon(Icons.history, color: primary),
              title: const Text('历史记录', style: TextStyle(fontSize: 15)),
            ),
            ListTile(
              onTap: () => Get.toNamed('/fav'),
              leading: Icon(Icons.favorite_border, color: primary),
              title: const Text('收藏', style: TextStyle(fontSize: 15)),
            ),
            // Watch later preview
            Divider(
              height: 35,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '稍后再看',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed('/later'),
                    child: const Text('查看更多'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: FutureBuilder(
                future: _watchLaterFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Obx(() {
                      if (_mediaController.watchLaterList.isNotEmpty) {
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _mediaController.watchLaterList.length.clamp(0, 10),
                          itemBuilder: (context, index) {
                            final item = _mediaController.watchLaterList[index];
                            return GestureDetector(
                              onTap: () {
                                Get.toNamed('/video', parameters: {
                                  'bvid': item.bvid ?? '',
                                  'cid': item.cid.toString(),
                                });
                              },
                              child: Container(
                                width: 160,
                                margin: const EdgeInsets.only(left: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NetworkImgLayer(
                                      width: 160,
                                      height: 100,
                                      src: item.cover ?? '',
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.title ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (_mediaController.error.isNotEmpty) {
                        return Center(
                          child: Text(
                            '加载失败',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        );
                      } else {
                        return const Center(child: Text('暂无数据'));
                      }
                    });
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight,
            ),
          ],
        ),
      ),
    );
  }
}
