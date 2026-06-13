import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/message/domain/message_use_cases.dart';
import 'package:pilipala/models/msg/session.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/navigation_helper.dart';

import '../whisper/whisper_controller.dart';

/// Controller for whisper (private message) detail page.
class WhisperDetailController extends GetxController {
  late final GetSessionMsgUseCase _getSessionMsg;
  late final AckSessionMsgUseCase _ackSessionMsg;
  late final SendMsgUseCase _sendMsg;
  late final RemoveSessionUseCase _removeSession;

  int? talkerId;
  late String name;
  late String face;
  late String mid;
  late String heroTag;
  RxList<MessageItem> messageList = <MessageItem>[].obs;
  RxList<dynamic> eInfos = [].obs;
  final TextEditingController replyContentController = TextEditingController();
  Box userInfoCache = GStrorage.userInfo;
  List emoteList = [];
  List<String> picList = [];

  WhisperDetailController({
    GetSessionMsgUseCase? getSessionMsg,
    AckSessionMsgUseCase? ackSessionMsg,
    SendMsgUseCase? sendMsg,
    RemoveSessionUseCase? removeSession,
  }) {
    _getSessionMsg = getSessionMsg ?? GetSessionMsgUseCase();
    _ackSessionMsg = ackSessionMsg ?? AckSessionMsgUseCase();
    _sendMsg = sendMsg ?? SendMsgUseCase();
    _removeSession = removeSession ?? RemoveSessionUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.parameters.containsKey('talkerId')) {
      talkerId = int.parse(Get.parameters['talkerId']!);
    } else {
      talkerId = int.parse(Get.parameters['mid']!);
    }
    name = Get.parameters['name']!;
    face = Get.parameters['face']!;
    mid = Get.parameters['mid']!;
    heroTag = Get.parameters['heroTag']!;
  }

  Future querySessionMsg() async {
    var res = await _getSessionMsg.execute(talkerId: talkerId);
    if (res['status']) {
      messageList.value = res['data'].messages;
      try {
        for (var item in messageList) {
          if (item.msgType == 2) {
            picList.add(item.content['url']);
          }
        }
        picList = picList.reversed.toList();
      } catch (e) {
        print('e: $e');
      }
      if (messageList.isNotEmpty) {
        ackSessionMsg();
        if (res['data'].eInfos != null) {
          eInfos.value = res['data'].eInfos;
        }
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  Future ackSessionMsg() async {
    if (messageList.isEmpty) return;
    await _ackSessionMsg.execute(
      talkerId: talkerId,
      ackSeqno: messageList.last.msgSeqno,
    );
  }

  Future sendMsg() async {
    feedBack();
    String message = replyContentController.text;
    final userInfo = userInfoCache.get('userInfoCache');
    if (userInfo == null) {
      SmartDialog.showToast('请先登录');
      return;
    }
    if (message == '') {
      SmartDialog.showToast('请输入内容');
      return;
    }
    var result = await _sendMsg.execute(
      senderUid: userInfo.mid,
      receiverId: int.parse(mid),
      content: {'content': message},
      msgType: 1,
    );
    if (result['status']) {
      String content = jsonDecode(result['data']['msg_content'])['content'];
      messageList.insert(
        0,
        MessageItem(
          msgSeqno: result['data']['msg_key'],
          senderUid: userInfo.mid,
          receiverId: int.parse(mid),
          content: {'content': content},
          msgType: 1,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      eInfos.addAll(emoteList);
      replyContentController.clear();
      try {
        late final WhisperController whisperController =
            Get.find<WhisperController>();
        whisperController.refreshLastMsg(talkerId!, message);
      } catch (_) {}
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  void removeSession(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          clipBehavior: Clip.hardEdge,
          title: const Text('提示'),
          content: const Text('确认清空会话内容并移除会话？'),
          actions: [
            TextButton(
              onPressed: safeBack,
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () async {
                var res = await _removeSession.execute(talkerId: talkerId);
                if (res['status']) {
                  SmartDialog.showToast('操作成功');
                  try {
                    late final WhisperController whisperController =
                        Get.find<WhisperController>();
                    whisperController.removeSessionMsg(talkerId!);
                    safeBack();
                  } catch (_) {}
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }
}
