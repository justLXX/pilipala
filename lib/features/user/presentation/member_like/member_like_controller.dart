import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/http/member.dart';
import 'package:pilipala/models/member/like.dart';

class MemberLikeController extends GetxController {
  final ScrollController scrollController = ScrollController();
  late int mid;
  RxList<MemberLikeDataModel> list = <MemberLikeDataModel>[].obs;
  RxBool isLoading = false.obs;

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

  Future getData() async {
    if (isLoading.value) {
      return {'status': true};
    }
    isLoading.value = true;
    try {
      final res = await MemberHttp.getRecentLikeVideo(mid: mid);
      if (res['status']) {
        list.value = List<MemberLikeDataModel>.from(res['data']);
      }
      return res;
    } catch (e) {
      return {
        'status': false,
        'msg': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }
}
