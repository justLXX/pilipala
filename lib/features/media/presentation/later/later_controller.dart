import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/video/later.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/utils.dart';

class LaterController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<MediaVideoItemModel> laterList = <MediaVideoItemModel>[].obs;
  int count = 0;
  RxBool isLoading = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;

  late final GetWatchLaterUseCase _getWatchLater;
  late final RemoveFromWatchLaterUseCase _removeFromWatchLater;

  LaterController({
    GetWatchLaterUseCase? getWatchLater,
    RemoveFromWatchLaterUseCase? removeFromWatchLater,
  })  : _getWatchLater = getWatchLater ?? GetWatchLaterUseCase(),
        _removeFromWatchLater =
            removeFromWatchLater ?? RemoveFromWatchLaterUseCase();

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
  }

  Future queryLaterList() async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    isLoading.value = true;

    try {
      final list = await _getWatchLater.execute();
      laterList.value = list;
      count = list.length;
      isLoading.value = false;
      return {'status': true, 'data': {'count': count, 'list': list}, 'msg': ''};
    } catch (e) {
      isLoading.value = false;
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future toViewDel({String? bvid}) async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(bvid != null
              ? '即将移除该视频，确定是否移除'
              : '即将删除所有已观看视频，此操作不可恢复。确定是否删除？'),
          actions: [
            TextButton(
              onPressed: SmartDialog.dismiss,
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  if (bvid != null) {
                    await _removeFromWatchLater.execute(bvid: bvid!);
                    laterList.removeWhere((e) => e.bvid == bvid);
                  } else {
                    for (var item in laterList) {
                      if (item.bvid != null) {
                        await _removeFromWatchLater.execute(bvid: item.bvid!);
                      }
                    }
                    laterList.clear();
                    queryLaterList();
                  }
                  SmartDialog.dismiss();
                  SmartDialog.showToast('操作成功');
                } catch (e) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast(e.toString());
                }
              },
              child: Text(bvid != null ? '确认移除' : '确认删除'),
            )
          ],
        );
      },
    );
  }

  Future toViewClear() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('清空确认'),
          content: const Text('确定要清空你的稍后再看列表吗？'),
          actions: [
            TextButton(
              onPressed: SmartDialog.dismiss,
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  for (var item in laterList) {
                    if (item.bvid != null) {
                      await _removeFromWatchLater.execute(bvid: item.bvid!);
                    }
                  }
                  laterList.clear();
                  SmartDialog.dismiss();
                  SmartDialog.showToast('清空成功');
                } catch (e) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast(e.toString());
                }
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  Future toViewPlayAll() async {
    final MediaVideoItemModel firstItem = laterList.first;
    final String heroTag = Utils.makeHeroTag(firstItem.bvid);
    Get.toNamed(
      '/video?bvid=${firstItem.bvid}&cid=${firstItem.cid}',
      arguments: {
        'videoItem': firstItem,
        'heroTag': heroTag,
        'sourceType': 'watchLater',
        'count': laterList.length,
      },
    );
  }
}
