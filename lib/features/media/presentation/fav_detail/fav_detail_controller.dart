import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/features/media/presentation/fav/fav_controller.dart';
import 'package:pilipala/models/user/fav_detail.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/utils/utils.dart';
import 'package:pilipala/utils/navigation_helper.dart';

class FavDetailController extends GetxController {
  FavFolderItemData? item;
  RxString title = ''.obs;

  int? mediaId;
  late String heroTag;
  int currentPage = 1;
  bool isLoadingMore = false;
  RxMap favInfo = {}.obs;
  RxList<FavDetailItemData> favList = <FavDetailItemData>[].obs;
  RxString loadingText = '加载中...'.obs;
  RxInt mediaCount = 0.obs;
  late String isOwner;

  late final GetFavFolderDetailUseCase _getFavFolderDetail;
  late final DeleteFavFolderUseCase _deleteFavFolder;
  late final CancelFavVideoUseCase _cancelFavVideo;

  FavDetailController({
    GetFavFolderDetailUseCase? getFavFolderDetail,
    DeleteFavFolderUseCase? deleteFavFolder,
    CancelFavVideoUseCase? cancelFavVideo,
  })  : _getFavFolderDetail = getFavFolderDetail ?? GetFavFolderDetailUseCase(),
        _deleteFavFolder = deleteFavFolder ?? DeleteFavFolderUseCase(),
        _cancelFavVideo = cancelFavVideo ?? CancelFavVideoUseCase();

  @override
  void onInit() {
    item = Get.arguments;
    title.value = item!.title!;
    if (Get.parameters.keys.isNotEmpty) {
      mediaId = int.parse(Get.parameters['mediaId']!);
      heroTag = Get.parameters['heroTag']!;
      isOwner = Get.parameters['isOwner']!;
    }
    super.onInit();
  }

  Future<dynamic> queryUserFavFolderDetail({type = 'init'}) async {
    if (type == 'onLoad' && favList.length >= mediaCount.value) {
      loadingText.value = '没有更多了';
      return;
    }
    isLoadingMore = true;

    try {
      final list = await _getFavFolderDetail.execute(
        mediaId: mediaId!,
        page: currentPage,
        pageSize: 20,
      );

      if (currentPage == 1 && type == 'init') {
        favList.value = list;
        mediaCount.value = list.length;
      } else if (type == 'onLoad') {
        favList.addAll(list);
      }
      if (favList.length >= mediaCount.value) {
        loadingText.value = '没有更多了';
      }
      currentPage += 1;
      isLoadingMore = false;
      return {'status': true, 'data': {'medias': list}, 'msg': ''};
    } catch (e) {
      isLoadingMore = false;
      return {'status': false, 'msg': e.toString()};
    }
  }

  onCancelFav(int id) async {
    try {
      await _cancelFavVideo.execute(
        aid: id,
        mediaIds: mediaId.toString(),
      );
      favList.removeWhere((i) => i.id == id);
      SmartDialog.showToast('取消收藏');
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  onLoad() {
    queryUserFavFolderDetail(type: 'onLoad');
  }

  onDelFavFolder() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确定删除这个收藏夹吗？'),
          actions: [
            TextButton(
              onPressed: () async {
                SmartDialog.dismiss();
              },
              child: Text(
                '点错了',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _deleteFavFolder.execute(mediaId: mediaId!);
                  SmartDialog.dismiss();
                  SmartDialog.showToast('操作成功');
                  FavController favController = Get.find<FavController>();
                  await favController.removeFavFolder(mediaIds: mediaId!);
                  safeBack();
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

  onEditFavFolder() async {
    var res = await Get.toNamed(
      '/favEdit',
      arguments: {
        'mediaId': mediaId.toString(),
        'title': item!.title,
        'intro': item!.intro,
        'cover': item!.cover,
        'privacy': [23, 1].contains(item!.attr) ? 1 : 0,
      },
    );
    if (res != null && res['title'] != null) {
      title.value = res['title'];
    }
  }

  Future toViewPlayAll() async {
    final FavDetailItemData firstItem = favList.first;
    final String heroTag = Utils.makeHeroTag(firstItem.bvid);
    Get.toNamed(
      '/video?bvid=${firstItem.bvid}&cid=${firstItem.cid}',
      arguments: {
        'videoItem': firstItem,
        'heroTag': heroTag,
        'sourceType': 'fav',
        'mediaId': favInfo['id'],
        'oid': firstItem.id,
        'favTitle': favInfo['title'],
        'favInfo': favInfo,
        'count': favInfo['media_count'],
      },
    );
  }
}
