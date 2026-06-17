import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/blacklist/domain/blacklist_use_cases.dart';
import 'package:pilipala/models/user/black.dart';
import 'package:pilipala/utils/storage.dart';

class BlackListController extends GetxController {
  int currentPage = 1;
  int pageSize = 50;
  RxInt total = 0.obs;
  RxList<BlackListItem> blackList = <BlackListItem>[].obs;

  final GetBlacklistUseCase _getBlacklistUseCase =
      Get.find<GetBlacklistUseCase>();
  final RemoveFromBlacklistUseCase _removeFromBlacklistUseCase =
      Get.find<RemoveFromBlacklistUseCase>();

  Future queryBlacklist({type = 'init'}) async {
    if (type == 'init') {
      currentPage = 1;
    }
    final result = await _getBlacklistUseCase.execute(
      pn: currentPage,
      ps: pageSize,
    );

    if (result['status'] == true) {
      final data = result['data'] as BlackListDataModel;
      if (type == 'init') {
        blackList.value = data.list ?? [];
        total.value = data.total ?? 0;
      } else {
        blackList.addAll(data.list ?? []);
      }
      currentPage += 1;
    }
    return result;
  }

  Future removeBlack(mid) async {
    final result = await _removeFromBlacklistUseCase.execute(mid);
    if (result['status'] == true) {
      blackList.removeWhere((e) => e.mid == mid);
      total.value = total.value - 1;
      SmartDialog.showToast(result['msg'] ?? '已移除');
    } else {
      SmartDialog.showToast(result['msg'] ?? '移除失败');
    }
  }

  @override
  void onClose() {
    // Save blacklist to settings
    List<int> blackMidsList =
        blackList.map<int>((e) => e.mid!).toList();
    GStrorage.setting.put('blackMidsList', blackMidsList);
    super.onClose();
  }
}
