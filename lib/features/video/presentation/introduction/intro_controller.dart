import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/user.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/id_utils.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:share_plus/share_plus.dart';

class VideoIntroController extends GetxController {
  VideoIntroController({required this.bvid});
  String bvid;
  Rx<VideoDetailData> videoDetail = VideoDetailData().obs;
  RxInt follower = 0.obs;
  RxBool hasLike = false.obs;
  RxBool hasCoin = false.obs;
  RxBool hasFav = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  bool userLogin = false;
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  List addMediaIdsNew = [];
  List delMediaIdsNew = [];
  RxMap followStatus = {}.obs;

  RxInt lastPlayCid = 0.obs;
  var userInfo;

  bool isShowOnlineTotal = false;
  RxString total = '1'.obs;
  Timer? timer;
  bool isPaused = false;
  String heroTag = '';

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    try {
      heroTag = Get.arguments['heroTag'];
    } catch (_) {}
    userLogin = userInfo != null;
    lastPlayCid.value = int.parse(Get.parameters['cid'] ?? '0');
  }

  Future queryVideoIntro() async {
    var result = await VideoHttp.videoIntro(bvid: bvid);
    if (result['status']) {
      videoDetail.value = result['data']!;
      if (videoDetail.value.pages!.isNotEmpty && lastPlayCid.value == 0) {
        lastPlayCid.value = videoDetail.value.pages!.first.cid!;
      }
      final VideoDetailController videoDetailCtr =
          Get.find<VideoDetailController>(tag: heroTag);
      videoDetailCtr.tabs.value = ['简介', '评论 ${result['data']?.stat?.reply}'];
      await queryUserStat();
    }
    if (userLogin) {
      queryHasLikeVideo();
      queryHasCoinVideo();
      queryHasFavVideo();
      queryFollowStatus();
    }
    return result;
  }

  Future queryUserStat() async {
    var result = await UserHttp.userStat(mid: videoDetail.value.owner!.mid!);
    if (result['status']) {
      follower.value = result['data']['follower'];
    }
  }

  Future queryHasLikeVideo() async {
    var result = await VideoHttp.hasLikeVideo(bvid: bvid);
    hasLike.value = result["data"] == 1 ? true : false;
  }

  Future queryHasCoinVideo() async {
    var result = await VideoHttp.hasCoinVideo(bvid: bvid);
    if (result['status']) {
      hasCoin.value = result["data"]['multiply'] == 0 ? false : true;
    }
  }

  Future queryHasFavVideo() async {
    await Future.delayed(const Duration(milliseconds: 200));
    var result = await VideoHttp.hasFavVideo(aid: IdUtils.bv2av(bvid));
    if (result['status']) {
      hasFav.value = result["data"]['favoured'];
    } else {
      hasFav.value = false;
    }
  }

  Future actionLike() async {
    feedBack();
    var result = await VideoHttp.likeVideo(bvid: bvid, type: !hasLike.value);
    if (result['status']) {
      hasLike.value = !hasLike.value;
    }
    return result;
  }

  Future actionCoin(int num) async {
    feedBack();
    var result = await VideoHttp.coinVideo(bvid: bvid, multiply: num);
    if (result['status']) {
      hasCoin.value = true;
    }
    return result;
  }

  Future actionFav() async {
    feedBack();
    var result = await VideoHttp.favVideo(
        aid: IdUtils.bv2av(bvid), addIds: '', delIds: '');
    if (result['status']) {
      hasFav.value = !hasFav.value;
    }
    return result;
  }

  Future actionShare() async {
    feedBack();
    await Share.share('https://www.bilibili.com/video/$bvid');
  }

  queryFollowStatus() async {
    if (videoDetail.value.owner == null) {
      return;
    }
    var result = await VideoHttp.hasFollow(mid: videoDetail.value.owner!.mid!);
    if (result['status']) {
      followStatus.value = result['data'];
    }
    return result;
  }

  actionFollow() async {
    feedBack();
    if (userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final int currentStatus = followStatus['attribute'] ?? 0;
    int actionStatus = currentStatus == 0 ? 1 : 0;
    
    var result = await VideoHttp.relationMod(
      mid: videoDetail.value.owner!.mid!,
      act: actionStatus,
      reSrc: 11,
    );
    if (result['status']) {
      followStatus['attribute'] = actionStatus;
      followStatus.refresh();
      if (actionStatus == 1) {
        follower.value++;
      } else {
        follower.value--;
      }
    }
  }
}
