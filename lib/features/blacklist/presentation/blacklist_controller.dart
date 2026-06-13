import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/http/black.dart';
import 'package:pilipala/models/user/black.dart';
import 'package:pilipala/utils/storage.dart';

class BlackListController extends GetxController {
  int currentPage = 1;
  int pageSize = 50;
  RxInt total = 0.obs;
  RxList<BlackListItem> blackList = <BlackListItem>[].obs;

  Future queryBlacklist({type = 'init'}) async {
    if (type == 'init') {
      currentPage = 1;
    }
    var result = await BlackHttp.blackList(pn: currentPage, ps: pageSize);
    if (result['status']) {
      if (type == 'init') {
        blackList.value = result['data'].list;
        total.value = result['data'].total;
      } else {
        blackList.addAll(result['data'].list);
      }
      currentPage += 1;
    }
    return result;
  }

  Future removeBlack(mid) async {
    var result = await BlackHttp.removeBlack(fid: mid);
    if (result['status']) {
      blackList.removeWhere((e) => e.mid == mid);
      total.value = total.value - 1;
      SmartDialog.showToast(result['msg']);
    }
  }
}
