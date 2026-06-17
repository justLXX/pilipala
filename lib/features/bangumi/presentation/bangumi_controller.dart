import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/bangumi/domain/bangumi_use_cases.dart';
import 'package:pilipala/models/bangumi/list.dart';
import 'package:pilipala/utils/storage.dart';

class BangumiController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final GetBangumiListUseCase _getBangumiListUseCase;
  final GetFollowedBangumiListUseCase _getFollowedBangumiListUseCase;

  BangumiController({
    GetBangumiListUseCase? getBangumiListUseCase,
    GetFollowedBangumiListUseCase? getFollowedBangumiListUseCase,
  })  : _getBangumiListUseCase =
            getBangumiListUseCase ?? Get.find<GetBangumiListUseCase>(),
        _getFollowedBangumiListUseCase = getFollowedBangumiListUseCase ??
            Get.find<GetFollowedBangumiListUseCase>();

  RxList<BangumiListItemModel> bangumiList = <BangumiListItemModel>[].obs;
  RxList<BangumiListItemModel> bangumiFollowList =
      <BangumiListItemModel>[].obs;
  int _currentPage = 1;
  bool isLoadingMore = true;
  Box userInfoCache = GStrorage.userInfo;
  RxBool userLogin = false.obs;
  late int mid;
  var userInfo;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    if (userInfo != null) {
      mid = userInfo.mid;
    }
    userLogin.value = userInfo != null;
  }

  Future queryBangumiListFeed({type = 'init'}) async {
    if (type == 'init') {
      _currentPage = 1;
    }
    var result =
        await _getBangumiListUseCase.execute(page: _currentPage);
    if (result['status']) {
      if (type == 'init') {
        bangumiList.value = result['data'].list;
      } else {
        bangumiList.addAll(result['data'].list);
      }
      _currentPage += 1;
    } else {}
    isLoadingMore = false;
    return result;
  }

  Future onLoad() async {
    queryBangumiListFeed(type: 'onLoad');
  }

  Future queryBangumiFollow() async {
    userInfo = userInfo ?? userInfoCache.get('userInfoCache');
    if (userInfo == null) {
      return;
    }
    var result =
        await _getFollowedBangumiListUseCase.execute(mid: userInfo.mid);
    if (result['status']) {
      bangumiFollowList.value = result['data'].list;
    } else {}
    return result;
  }

  void animateToTop() async {
    if (scrollController.offset >=
        MediaQuery.of(Get.context!).size.height * 5) {
      scrollController.jumpTo(0);
    } else {
      await scrollController.animateTo(0,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }
}
