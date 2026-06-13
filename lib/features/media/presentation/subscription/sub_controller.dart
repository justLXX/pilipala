import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/models/user/sub_folder.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/navigation_helper.dart';

class SubController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<SubFolderModelData> subFolderData = SubFolderModelData().obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;
  int currentPage = 1;
  int pageSize = 20;
  RxBool hasMore = true.obs;
  late int mid;
  late int ownerMid;
  RxBool isOwner = false.obs;

  late final GetSubFolderUseCase _getSubFolder;
  late final CancelSubscriptionUseCase _cancelSubscription;

  SubController({
    GetSubFolderUseCase? getSubFolder,
    CancelSubscriptionUseCase? cancelSubscription,
  })  : _getSubFolder = getSubFolder ?? GetSubFolderUseCase(),
        _cancelSubscription = cancelSubscription ?? CancelSubscriptionUseCase();

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid'] ?? '-1');
    userInfo = userInfoCache.get('userInfoCache');
    ownerMid = userInfo != null ? userInfo!.mid! : -1;
    isOwner.value = mid == -1 || mid == ownerMid;
  }

  Future<dynamic> querySubFolder({type = 'init'}) async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }

    try {
      final data = await _getSubFolder.execute(
        mid: isOwner.value ? ownerMid : mid,
        page: currentPage,
        pageSize: pageSize,
      );

      final folderData = SubFolderModelData.fromJson(data);

      if (type == 'init') {
        subFolderData.value = folderData;
      } else {
        if (folderData.list != null && folderData.list!.isNotEmpty) {
          subFolderData.value.list!.addAll(folderData.list!);
          subFolderData.update((val) {});
        }
      }
      currentPage++;
      return {'status': true, 'data': folderData, 'msg': ''};
    } catch (e) {
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future onLoad() async {
    querySubFolder(type: 'onload');
  }

  Future<void> cancelSub(SubFolderItemData subFolderItem) async {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('确定取消订阅吗？'),
        actions: [
          TextButton(
            onPressed: () {
              safeBack();
            },
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _cancelSubscription.execute(
                  seasonId: subFolderItem.id!,
                );
                subFolderData.value.list!.remove(subFolderItem);
                subFolderData.update((val) {});
                SmartDialog.showToast('取消订阅成功');
              } catch (e) {
                SmartDialog.showToast(e.toString());
              }
              safeBack();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
