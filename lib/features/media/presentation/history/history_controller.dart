import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/history.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/utils/storage.dart';

class HistoryController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HisListItem> historyList = <HisListItem>[].obs;
  RxBool isLoadingMore = false.obs;
  RxBool pauseStatus = false.obs;
  Box localCache = GStrorage.localCache;
  RxBool isLoading = false.obs;
  RxBool enableMultiple = false.obs;
  RxInt checkedCount = 0.obs;
  Box userInfoCache = GStrorage.userInfo;
  UserInfoData? userInfo;

  late final GetHistoryUseCase _getHistory;
  late final PauseHistoryUseCase _pauseHistory;
  late final GetHistoryStatusUseCase _getHistoryStatus;
  late final ClearHistoryUseCase _clearHistory;
  late final DeleteHistoryUseCase _deleteHistory;

  HistoryController({
    GetHistoryUseCase? getHistory,
    PauseHistoryUseCase? pauseHistory,
    GetHistoryStatusUseCase? getHistoryStatus,
    ClearHistoryUseCase? clearHistory,
    DeleteHistoryUseCase? deleteHistory,
  })  : _getHistory = getHistory ?? GetHistoryUseCase(),
        _pauseHistory = pauseHistory ?? PauseHistoryUseCase(),
        _getHistoryStatus = getHistoryStatus ?? GetHistoryStatusUseCase(),
        _clearHistory = clearHistory ?? ClearHistoryUseCase(),
        _deleteHistory = deleteHistory ?? DeleteHistoryUseCase();

  @override
  void onInit() {
    super.onInit();
    historyStatus();
    userInfo = userInfoCache.get('userInfoCache');
  }

  Future queryHistoryList({type = 'init'}) async {
    if (userInfo == null) {
      return {'status': false, 'msg': '账号未登录', 'code': -101};
    }
    int max = 0;
    int viewAt = 0;
    if (type == 'onload') {
      max = historyList.last.history!.oid!;
      viewAt = historyList.last.viewAt!;
    }
    isLoadingMore.value = true;

    try {
      final response = await _getHistory.execute();
      isLoadingMore.value = false;
      if (type == 'onload') {
        historyList.addAll(response);
      } else {
        historyList.value = response;
      }
      return {'status': true, 'data': response, 'msg': ''};
    } catch (e) {
      isLoadingMore.value = false;
      return {'status': false, 'msg': e.toString()};
    }
  }

  Future onLoad() async {
    queryHistoryList(type: 'onload');
  }

  Future onRefresh() async {
    queryHistoryList(type: 'onRefresh');
  }

  Future onPauseHistory() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: Text(!pauseStatus.value
              ? '啊叻？你要暂停历史记录功能吗？'
              : '啊叻？要恢复历史记录功能吗？'),
          actions: [
            TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: const Text('取消')),
            TextButton(
              onPressed: () async {
                SmartDialog.showLoading(msg: '请求中');
                try {
                  await _pauseHistory.execute(pause: !pauseStatus.value);
                  SmartDialog.showToast(
                      !pauseStatus.value ? '暂停观看历史' : '恢复观看历史');
                  pauseStatus.value = !pauseStatus.value;
                  localCache.put(LocalCacheKey.historyPause, pauseStatus.value);
                } catch (e) {
                  SmartDialog.showToast(e.toString());
                }
                SmartDialog.dismiss();
              },
              child: Text(!pauseStatus.value ? '确认暂停' : '确认恢复'),
            )
          ],
        );
      },
    );
  }

  Future historyStatus() async {
    try {
      final status = await _getHistoryStatus.execute();
      pauseStatus.value = status;
      localCache.put(LocalCacheKey.historyPause, status);
    } catch (e) {
      // Ignore error
    }
  }

  Future onClearHistory() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('啊叻？你要清空历史记录功能吗？'),
          actions: [
            TextButton(
                onPressed: () => SmartDialog.dismiss(),
                child: const Text('取消')),
            TextButton(
              onPressed: () async {
                SmartDialog.showLoading(msg: '请求中');
                try {
                  await _clearHistory.execute();
                  SmartDialog.showToast('清空观看历史');
                  historyList.clear();
                } catch (e) {
                  SmartDialog.showToast(e.toString());
                }
                SmartDialog.dismiss();
              },
              child: const Text('确认清空'),
            )
          ],
        );
      },
    );
  }

  Future delHistory(kid, business) async {
    String resKid = 'archive_$kid';
    if (business == 'live') {
      resKid = 'live_$kid';
    } else if (business.contains('article')) {
      resKid = 'article_$kid';
    }

    try {
      await _deleteHistory.execute(kid: resKid);
      historyList.removeWhere((e) => e.kid == kid);
      SmartDialog.showToast('删除成功');
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  Future onDelHistory() async {
    List<HisListItem> result =
        historyList.where((e) => e.progress == -1).toList();
    for (HisListItem i in result) {
      String resKid = 'archive_${i.kid}';
      try {
        await _deleteHistory.execute(kid: resKid);
        historyList.removeWhere((e) => e.kid == i.kid);
      } catch (e) {
        // Ignore error
      }
    }
    SmartDialog.showToast('操作完成');
  }

  Future onDelCheckedHistory() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确认删除所选历史记录吗？'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: Text(
                '取消',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await SmartDialog.dismiss();
                SmartDialog.showLoading(msg: '请求中');
                List<HisListItem> result =
                    historyList.where((e) => e.checked!).toList();
                for (HisListItem i in result) {
                  String str = 'archive';
                  try {
                    str = i.history!.business!;
                  } catch (_) {}
                  String resKid = '${str}_${i.kid}';
                  try {
                    await _deleteHistory.execute(kid: resKid);
                    historyList.removeWhere((e) => e.kid == i.kid);
                  } catch (e) {
                    // Ignore error
                  }
                }
                checkedCount.value = 0;
                SmartDialog.dismiss();
                enableMultiple.value = false;
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }
}
