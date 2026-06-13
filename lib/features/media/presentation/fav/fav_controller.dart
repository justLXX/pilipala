import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/utils/storage.dart';

class FavController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  RxList<FavFolderItemData> favFolderList = <FavFolderItemData>[].obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;
  int currentPage = 1;
  int pageSize = 60;
  RxBool hasMore = true.obs;
  late int mid;
  late int ownerMid;
  RxBool isOwner = false.obs;

  late final GetFavFoldersUseCase _getFavFolders;

  FavController({GetFavFoldersUseCase? getFavFolders})
      : _getFavFolders = getFavFolders ?? GetFavFoldersUseCase();

  @override
  void onInit() {
    mid = int.parse(Get.parameters['mid'] ?? '-1');
    userInfo = userInfoCache.get('userInfoCache');
    ownerMid = userInfo != null ? userInfo!.mid! : -1;
    isOwner.value = mid == -1 || mid == ownerMid;
    super.onInit();
  }

  Future<dynamic> queryFavFolder({type = 'init'}) async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    if (!hasMore.value) {
      return;
    }

    final userId = isOwner.value ? ownerMid : mid;
    try {
      final list = await _getFavFolders.execute(
        mid: userId,
        page: currentPage,
        pageSize: pageSize,
      );

      if (type == 'init') {
        favFolderData.value = FavFolderData(list: list, count: list.length);
        favFolderList.value = list;
      } else {
        if (list.isNotEmpty) {
          favFolderList.addAll(list);
          favFolderData.update((val) {});
        }
      }
      hasMore.value = list.length == pageSize;
      currentPage++;
      return {'status': true, 'data': favFolderData.value, 'msg': ''};
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future onLoad() async {
    queryFavFolder(type: 'onload');
  }

  removeFavFolder({required int mediaIds}) async {
    for (var i in favFolderList) {
      if (i.id == mediaIds) {
        favFolderList.remove(i);
        break;
      }
    }
  }
}
