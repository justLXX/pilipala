import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/rank/domain/rank_use_cases.dart';
import 'package:pilipala/models/common/rank_type.dart';
import 'package:pilipala/models/model_hot_video_item.dart';

/// Per-zone state holder.
///
/// Each zone (identified by its Bilibili `rid`) maintains its own scroll
/// position, video list, loading flag, and FutureBuilder future.
class _ZoneState {
  final ScrollController scrollController = ScrollController();
  final RxList<HotVideoItemModel> videoList = <HotVideoItemModel>[].obs;
  bool isLoading = false;
  Future? futureBuilderFuture;

  void dispose() {
    scrollController.dispose();
  }
}

/// Controller for the ranking feature.
///
/// Manages the zone TabBar and per-zone video lists. The old architecture
/// used one [ZoneController] per tab; the new design consolidates all zone
/// state into a single controller keyed by `rid`.
class RankController extends GetxController with GetTickerProviderStateMixin {
  // Dependencies
  late final GetRankVideoListUseCase _getRankVideoList;

  // Tab state
  late RxList tabs = [].obs;
  RxInt initialIndex = 0.obs;
  late TabController tabController;

  // Double-tap detection flag (used by main_page.dart)
  bool flag = false;

  // Per-zone state map, keyed by rid.
  final Map<int, _ZoneState> _zoneStates = {};

  // Search bar stream (kept for compatibility with legacy callers).
  late final StreamController<bool> searchBarStream =
      StreamController<bool>.broadcast();

  RankController({GetRankVideoListUseCase? getRankVideoList}) {
    _getRankVideoList = getRankVideoList ?? GetRankVideoListUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    _setTabConfig();
  }

  /// Initialise tabs and the [TabController] from [rankTabConfigs].
  void _setTabConfig() {
    tabs.value = rankTabConfigs;
    initialIndex.value = 0;

    tabController = TabController(
      initialIndex: initialIndex.value,
      length: tabs.length,
      vsync: this,
    );
  }

  // ---------------------------------------------------------------------------
  // Zone state accessors
  // ---------------------------------------------------------------------------

  /// Return (and lazily create) the [_ZoneState] for the given [rid].
  _ZoneState _getOrCreateZone(int rid) {
    return _zoneStates.putIfAbsent(rid, () => _ZoneState());
  }

  /// Scroll controller for zone [rid].
  ScrollController getScrollController(int rid) {
    return _getOrCreateZone(rid).scrollController;
  }

  /// Reactive video list for zone [rid].
  RxList<HotVideoItemModel> getVideoList(int rid) {
    return _getOrCreateZone(rid).videoList;
  }

  /// FutureBuilder future for zone [rid].
  ///
  /// If the future has not been created yet (first time the tab is shown),
  /// it triggers a data load and stores the future.
  Future getFuture(int rid) {
    final zone = _getOrCreateZone(rid);
    zone.futureBuilderFuture ??= queryRankFeed(rid);
    return zone.futureBuilderFuture!;
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  /// Fetch the ranking video list for zone [rid] and update the zone state.
  ///
  /// Returns a map compatible with FutureBuilder:
  /// `{'status': true/false, 'data': [...], 'msg': '...'}`.
  Future<Map<String, dynamic>> queryRankFeed(int rid) async {
    final zone = _getOrCreateZone(rid);
    zone.isLoading = true;

    try {
      final videos = await _getRankVideoList.execute(rid: rid);
      zone.videoList.value = videos;
      zone.isLoading = false;
      return {'status': true, 'data': videos};
    } catch (e) {
      zone.isLoading = false;
      return {'status': false, 'data': <HotVideoItemModel>[], 'msg': e.toString()};
    }
  }

  /// Refresh the currently selected zone.
  void onRefresh() {
    final rid = _currentRid();
    final zone = _getOrCreateZone(rid);
    // Reset the future so FutureBuilder re-runs.
    zone.futureBuilderFuture = queryRankFeed(rid);
  }

  /// Scroll the currently selected zone to the top.
  void animateToTop() {
    final rid = _currentRid();
    final zone = _getOrCreateZone(rid);
    final sc = zone.scrollController;
    if (sc.hasClients) {
      if (sc.offset >= MediaQuery.of(Get.context!).size.height * 5) {
        sc.jumpTo(0);
      } else {
        sc.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Return the rid of the currently selected tab.
  int _currentRid() {
    final index = tabController.index;
    return tabs[index]['rid'] as int;
  }

  @override
  void onClose() {
    searchBarStream.close();
    for (final zone in _zoneStates.values) {
      zone.dispose();
    }
    _zoneStates.clear();
    super.onClose();
  }
}
