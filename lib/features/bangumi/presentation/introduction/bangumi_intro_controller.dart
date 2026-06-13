import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/constants.dart';
import 'package:pilipala/http/search.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/bangumi/info.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/features/video/presentation/reply/reply_controller.dart';
import 'package:pilipala/plugin/pl_player/models/play_repeat.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/id_utils.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:share_plus/share_plus.dart';

class BangumiIntroController extends GetxController {
  String bvid = Get.parameters['bvid'] ?? '';
  var seasonId = Get.parameters['seasonId'] != null
      ? int.parse(Get.parameters['seasonId']!)
      : null;
  var epId = Get.parameters['epId'] != null
      ? int.tryParse(Get.parameters['epId']!)
      : null;

  RxBool isLoading = false.obs;
  Rx<BangumiInfoModel> bangumiDetail = BangumiInfoModel().obs;
  String responseMsg = '请求异常';
  Map userStat = {'follower': '-'};
  RxBool hasLike = false.obs;
  RxBool hasCoin = false.obs;
  RxBool hasFav = false.obs;
  Box userInfoCache = GStrorage.userInfo;
  bool userLogin = false;
  Rx<FavFolderData> favFolderData = FavFolderData().obs;
  List addMediaIdsNew = [];
  List delMediaIdsNew = [];
  RxMap followStatus = {}.obs;
  int _tempThemeValue = -1;
  var userInfo;
  PersistentBottomSheetController? bottomSheetController;

  @override
  void onInit() {
    super.onInit();
    userInfo = userInfoCache.get('userInfoCache');
    userLogin = userInfo != null;
  }

  Future queryBangumiIntro() async {
    if (userLogin) {
      queryHasLikeVideo();
      queryHasCoinVideo();
      queryHasFavVideo();
    }
    var result = await SearchHttp.bangumiInfo(seasonId: seasonId, epId: epId);
    if (result['status']) {
      bangumiDetail.value = result['data'];
      epId = bangumiDetail.value.episodes!.first.id;
    }
    return result;
  }

  Future queryHasLikeVideo() async {
    var result = await VideoHttp.hasLikeVideo(bvid: bvid);
    hasLike.value = result["data"] == 1 ? true : false;
  }

  Future queryHasCoinVideo() async {
    var result = await VideoHttp.hasCoinVideo(bvid: bvid);
    hasCoin.value = result["data"]['multiply'] == 0 ? false : true;
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
    await Share.share('https://www.bilibili.com/bangumi/play/$epId');
  }
}
