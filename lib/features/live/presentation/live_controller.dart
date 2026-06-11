import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/live/domain/live_use_cases.dart';
import 'package:pilipala/models/live/follow.dart';
import 'package:pilipala/models/live/item.dart';
import 'package:pilipala/utils/storage.dart';

/// Controller for the live stream list page.
class LiveController extends GetxController {
  // Dependencies
  late final GetLiveListUseCase _getLiveList;
  late final GetFollowingLiveUseCase _getFollowingLive;

  // UI state
  final ScrollController scrollController = ScrollController();
  int count = 12;
  int _currentPage = 1;
  RxInt crossAxisCount = 2.obs;
  RxList<LiveItemModel> liveList = <LiveItemModel>[].obs;
  RxList<LiveFollowingItemModel> liveFollowingList =
      <LiveFollowingItemModel>[].obs;
  bool flag = false;
  OverlayEntry? popupDialog;
  Box setting = GStrorage.setting;

  LiveController({
    GetLiveListUseCase? getLiveList,
    GetFollowingLiveUseCase? getFollowingLive,
  }) {
    _getLiveList = getLiveList ?? GetLiveListUseCase();
    _getFollowingLive = getFollowingLive ?? GetFollowingLiveUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    crossAxisCount.value =
        setting.get(SettingBoxKey.customRows, defaultValue: 2);
  }

  /// Fetch recommended live list.
  Future queryLiveList(type) async {
    var res = await _getLiveList.execute(page: _currentPage);
    if (res['status']) {
      if (type == 'init') {
        liveList.value = res['data'];
      } else if (type == 'onLoad') {
        liveList.addAll(res['data']);
      }
      _currentPage += 1;
    }
    return res;
  }

  /// Pull-to-refresh.
  Future onRefresh() async {
    _currentPage = 1;
    queryLiveList('init');
    fetchLiveFollowing();
  }

  /// Load more (scroll to bottom).
  Future onLoad() async {
    queryLiveList('onLoad');
  }

  /// Scroll to top and refresh.
  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  /// Fetch following (subscribed) live streams.
  Future fetchLiveFollowing() async {
    var res = await _getFollowingLive.execute(page: 1, pageSize: 20);
    if (res['status']) {
      liveFollowingList.value =
          (res['data'].list as List<LiveFollowingItemModel>)
              .where((LiveFollowingItemModel item) =>
                  item.liveStatus == 1 && item.recordLiveTime == 0)
              .toList();
    }
    return res;
  }
}
