import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/http/member.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/member/coin.dart';
import 'package:pilipala/models/member/info.dart';
import 'package:pilipala/models/member/like.dart';
import 'package:pilipala/models/member/seasons.dart';

class MemberController extends GetxController {
  final ScrollController scrollController = ScrollController();
  late int mid;

  final Rx<MemberInfoModel?> memberInfo = Rx<MemberInfoModel?>(null);
  final RxMap<String, dynamic> memberStat = <String, dynamic>{}.obs;
  final RxList<MemberCoinsDataModel> coins = <MemberCoinsDataModel>[].obs;
  final RxList<MemberLikeDataModel> likes = <MemberLikeDataModel>[].obs;
  final RxList<MemberSeasonsList> seasons = <MemberSeasonsList>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<Map> loadMember() async {
    if (isLoading.value) {
      return {'status': true};
    }
    isLoading.value = true;
    error.value = '';

    try {
      final infoRes = await MemberHttp.memberInfo(mid: mid);
      if (!infoRes['status']) {
        error.value = infoRes['msg'] ?? '请求异常';
        return infoRes;
      }

      memberInfo.value = infoRes['data'];
      await Future.wait([
        loadStat(),
        loadCoins(),
        loadLikes(),
        loadSeasons(),
      ]);
      return infoRes;
    } catch (e) {
      error.value = e.toString();
      return {
        'status': false,
        'msg': error.value,
      };
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStat() async {
    final res = await MemberHttp.memberStat(mid: mid);
    if (res['status']) {
      memberStat.value = Map<String, dynamic>.from(res['data']);
    }
  }

  Future<void> loadCoins() async {
    final res = await MemberHttp.getRecentCoinVideo(mid: mid);
    if (res['status']) {
      coins.value = List<MemberCoinsDataModel>.from(res['data']);
    }
  }

  Future<void> loadLikes() async {
    final res = await MemberHttp.getRecentLikeVideo(mid: mid);
    if (res['status']) {
      likes.value = List<MemberLikeDataModel>.from(res['data']);
    }
  }

  Future<void> loadSeasons() async {
    final res = await MemberHttp.getMemberSeasons(mid, 1, 10);
    if (res['status']) {
      final MemberSeasonsDataModel data = res['data'];
      seasons.value = data.seasonsList ?? [];
    }
  }

  Future<void> toggleFollow() async {
    final info = memberInfo.value;
    if (info == null) {
      return;
    }
    final bool followed = info.isFollowed ?? false;
    final res = await VideoHttp.relationMod(
      mid: mid,
      act: followed ? 2 : 1,
      reSrc: 11,
    );
    SmartDialog.showToast(res['msg'] ?? '操作成功');
    if (res['status']) {
      info.isFollowed = !followed;
      memberInfo.refresh();
    }
  }
}
