import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/history.dart';
import 'package:pilipala/utils/navigation_helper.dart';

class HistorySearchController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<TextEditingController> controller = TextEditingController().obs;
  final FocusNode searchFocusNode = FocusNode();
  RxString searchKeyWord = ''.obs;
  String hintText = '搜索';
  RxBool loadingStatus = false.obs;
  RxString loadingText = '加载中...'.obs;
  late int mid;
  RxString uname = ''.obs;
  int pn = 1;
  int count = 0;
  RxList<HisListItem> historyList = <HisListItem>[].obs;
  RxBool enableMultiple = false.obs;

  late final SearchHistoryUseCase _searchHistory;
  late final DeleteHistoryUseCase _deleteHistory;

  HistorySearchController({
    SearchHistoryUseCase? searchHistory,
    DeleteHistoryUseCase? deleteHistory,
  })  : _searchHistory = searchHistory ?? SearchHistoryUseCase(),
        _deleteHistory = deleteHistory ?? DeleteHistoryUseCase();

  void onClear() {
    if (searchKeyWord.value.isNotEmpty && controller.value.text != '') {
      controller.value.clear();
      searchKeyWord.value = '';
    } else {
      safeBack();
    }
  }

  void onChange(value) {
    searchKeyWord.value = value;
  }

  void submit() {
    if (!loadingStatus.value) {
      pn = 1;
      searchHistories();
    }
  }

  Future searchHistories({type = 'init'}) async {
    if (type == 'onLoad' && loadingText.value == '没有更多了') {
      return;
    }
    loadingStatus.value = true;

    try {
      final data = await _searchHistory.execute(
        pn: pn,
        keyword: controller.value.text,
      );

      final list = (data['list'] as List?)
              ?.map((e) => HisListItem.fromJson(e))
              .toList() ??
          [];

      if (type == 'init' && pn == 1) {
        historyList.value = list;
      } else {
        historyList.addAll(list);
      }
      count = data['page']['total'] ?? 0;
      if (historyList.length == count) {
        loadingText.value = '没有更多了';
      }
      pn += 1;
      loadingStatus.value = false;
      return {'status': true, 'data': data, 'msg': ''};
    } catch (e) {
      loadingStatus.value = false;
      return {'status': false, 'msg': e.toString()};
    }
  }

  onLoad() {
    searchHistories(type: 'onLoad');
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
}
