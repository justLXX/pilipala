import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/message/domain/message_use_cases.dart';
import 'package:pilipala/models/msg/account.dart';
import 'package:pilipala/models/msg/session.dart';

/// Controller for the whisper (private message) list page.
class WhisperController extends GetxController {
  late final GetSessionListUseCase _getSessionList;
  late final GetAccountListUseCase _getAccountList;
  late final GetUnreadCountUseCase _getUnreadCount;

  RxList<SessionList> sessionList = <SessionList>[].obs;
  RxList<AccountListModel> accountList = <AccountListModel>[].obs;
  bool isLoading = false;
  RxList noticesList = [
    {
      'icon': Icons.message_outlined,
      'title': '回复我的',
      'path': '/messageReply',
      'count': 0,
    },
    {
      'icon': Icons.alternate_email,
      'title': '@我的',
      'path': '/messageAt',
      'count': 0,
    },
    {
      'icon': Icons.thumb_up_outlined,
      'title': '收到的赞',
      'path': '/messageLike',
      'count': 0,
    },
    {
      'icon': Icons.notifications_none_outlined,
      'title': '系统通知',
      'path': '/messageSystem',
      'count': 0,
    }
  ].obs;

  WhisperController({
    GetSessionListUseCase? getSessionList,
    GetAccountListUseCase? getAccountList,
    GetUnreadCountUseCase? getUnreadCount,
  }) {
    _getSessionList = getSessionList ?? GetSessionListUseCase();
    _getAccountList = getAccountList ?? GetAccountListUseCase();
    _getUnreadCount = getUnreadCount ?? GetUnreadCountUseCase();
  }

  @override
  void onInit() {
    unread();
    super.onInit();
  }

  Future querySessionList(String? type) async {
    if (isLoading) return;
    var res = await _getSessionList.execute(
        endTs: type == 'onLoad' ? sessionList.last.sessionTs : null);
    if (res['data'].sessionList != null && res['data'].sessionList.isNotEmpty) {
      await queryAccountList(res['data'].sessionList);
      Map<int, dynamic> accountMap = {};
      for (var j in accountList) {
        accountMap[j.mid!] = j;
      }
      for (var i in res['data'].sessionList) {
        var accountInfo = accountMap[i.talkerId];
        if (accountInfo != null) {
          i.accountInfo = accountInfo;
        }
        if (i.talkerId == 844424930131966) {
          i.accountInfo = AccountListModel(
            name: 'UP主小助手',
            face:
                'https://message.biliimg.com/bfs/im/489a63efadfb202366c2f88853d2217b5ddc7a13.png',
          );
        }
      }
    }
    if (res['status'] && res['data'].sessionList != null) {
      if (type == 'onLoad') {
        sessionList.addAll(res['data'].sessionList);
      } else {
        sessionList.value = res['data'].sessionList;
      }
    }
    isLoading = false;
    return res;
  }

  Future queryAccountList(sessionList) async {
    List midsList = sessionList.map((e) => e.talkerId!).toList();
    var res = await _getAccountList.execute(midsList.join(','));
    if (res['status']) {
      accountList.value = res['data'];
    }
    return res;
  }

  Future onLoad() async {
    querySessionList('onLoad');
  }

  Future onRefresh() async {
    querySessionList('onRefresh');
  }

  void refreshLastMsg(int talkerId, String content) {
    final SessionList currentItem =
        sessionList.where((p0) => p0.talkerId == talkerId).first;
    currentItem.lastMsg!.content['content'] = content;
    sessionList.removeWhere((p0) => p0.talkerId == talkerId);
    sessionList.insert(0, currentItem);
    sessionList.refresh();
  }

  void removeSessionMsg(int talkerId) {
    sessionList.removeWhere((p0) => p0.talkerId == talkerId);
    sessionList.refresh();
  }

  void unread() async {
    var res = await _getUnreadCount.execute();
    if (res['status']) {
      noticesList[0]['count'] = res['data']['reply'];
      noticesList[1]['count'] = res['data']['at'];
      noticesList[2]['count'] = res['data']['like'];
      noticesList[3]['count'] = res['data']['sys_msg'];
      noticesList.refresh();
    }
  }
}
