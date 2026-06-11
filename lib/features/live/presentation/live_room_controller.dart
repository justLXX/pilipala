import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:ns_danmaku/ns_danmaku.dart';
import 'package:pilipala/features/live/domain/live_use_cases.dart';
import 'package:pilipala/http/constants.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/live/message.dart';
import 'package:pilipala/models/live/quality.dart';
import 'package:pilipala/models/live/room_info.dart';
import 'package:pilipala/plugin/pl_player/index.dart';
import 'package:pilipala/plugin/pl_socket/index.dart';
import 'package:pilipala/utils/live.dart';
import 'package:pilipala/models/live/room_info_h5.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/video_utils.dart';

/// Controller for the live room page (player, danmaku, chat).
class LiveRoomController extends GetxController {
  // Dependencies
  late final GetRoomInfoUseCase _getRoomInfo;
  late final GetRoomInfoH5UseCase _getRoomInfoH5;
  late final GetDanmakuInfoUseCase _getDanmakuInfo;
  late final SendDanmakuUseCase _sendDanmaku;
  late final LiveRoomEntryUseCase _liveRoomEntry;

  // State
  String cover = '';
  late int roomId;
  dynamic liveItem;
  late String heroTag;
  double volume = 0.0;
  RxBool volumeOff = false.obs;
  PlPlayerController plPlayerController = PlPlayerController(videoType: 'live');
  Rx<RoomInfoH5Model> roomInfoH5 = RoomInfoH5Model().obs;
  late bool enableCDN;
  late int currentQn;
  int? tempCurrentQn;
  late List<Map<String, dynamic>> acceptQnList;
  RxString currentQnDesc = ''.obs;
  Box userInfoCache = GStrorage.userInfo;
  int userId = 0;
  PlSocket? plSocket;
  List<String> danmuHostList = [];
  String token = '';
  RxList<LiveMessageModel> messageList = <LiveMessageModel>[].obs;
  DanmakuController? danmakuController;
  TextEditingController inputController = TextEditingController();
  RxMap<String, String> joinRoomTip = {'userName': '', 'message': ''}.obs;
  RxBool danmakuSwitch = true.obs;
  String buvid = '';
  RxBool isPortrait = false.obs;

  LiveRoomController({
    GetRoomInfoUseCase? getRoomInfo,
    GetRoomInfoH5UseCase? getRoomInfoH5,
    GetDanmakuInfoUseCase? getDanmakuInfo,
    SendDanmakuUseCase? sendDanmaku,
    LiveRoomEntryUseCase? liveRoomEntry,
  }) {
    _getRoomInfo = getRoomInfo ?? GetRoomInfoUseCase();
    _getRoomInfoH5 = getRoomInfoH5 ?? GetRoomInfoH5UseCase();
    _getDanmakuInfo = getDanmakuInfo ?? GetDanmakuInfoUseCase();
    _sendDanmaku = sendDanmaku ?? SendDanmakuUseCase();
    _liveRoomEntry = liveRoomEntry ?? LiveRoomEntryUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    currentQn = setting.get(SettingBoxKey.defaultLiveQa,
        defaultValue: LiveQuality.values.last.code);
    roomId = int.parse(Get.parameters['roomid']!);
    if (Get.arguments != null) {
      liveItem = Get.arguments['liveItem'];
      heroTag = Get.arguments['heroTag'] ?? '';
      if (liveItem != null) {
        cover = (liveItem.pic != null && liveItem.pic != '')
            ? liveItem.pic
            : (liveItem.cover != null && liveItem.cover != '')
                ? liveItem.cover
                : '';
      }
      Request.getBuvid().then((value) => buvid = value);
    }
    enableCDN = setting.get(SettingBoxKey.enableCDN, defaultValue: true);
    final userInfo = userInfoCache.get('userInfoCache');
    if (userInfo != null && userInfo.mid != null) {
      userId = userInfo.mid;
    }
    liveDanmakuInfo().then((value) => initSocket());
    danmakuSwitch.listen((p0) {
      plPlayerController.isOpenDanmu.value = p0;
    });
  }

  playerInit(source) async {
    await plPlayerController.setDataSource(
      DataSource(
        videoSource: source,
        audioSource: null,
        type: DataSourceType.network,
        httpHeaders: {
          'user-agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15',
          'referer': HttpString.baseUrl
        },
      ),
      enableHA: true,
      autoplay: true,
    );
    plPlayerController.isOpenDanmu.value = danmakuSwitch.value;
    heartBeat();
  }

  Future queryLiveInfo() async {
    var res = await _getRoomInfo.execute(roomId: roomId, qn: currentQn);
    if (res['status']) {
      isPortrait.value = res['data'].isPortrait;
      List<CodecItem> codec =
          res['data'].playurlInfo.playurl.stream.first.format.first.codec;
      CodecItem item = codec.first;
      currentQn = item.currentQn!;
      if (tempCurrentQn != null && tempCurrentQn == currentQn) {
        SmartDialog.showToast('画质切换失败，请检查登录状态');
      }
      List acceptQn = item.acceptQn!;
      acceptQnList = acceptQn.map((e) {
        return {
          'code': e,
          'desc': LiveQuality.values
              .firstWhere((element) => element.code == e)
              .description,
        };
      }).toList();
      currentQnDesc.value = LiveQuality.values
          .firstWhere((element) => element.code == currentQn)
          .description;
      String videoUrl = enableCDN
          ? VideoUtils.getCdnUrl(item)
          : (item.urlInfo?.first.host)! +
              item.baseUrl! +
              item.urlInfo!.first.extra!;
      await playerInit(videoUrl);
      return res;
    }
  }

  void setVolumn(value) {
    if (value == 0) {
      volumeOff.value = false;
    } else {
      volume = value;
      volumeOff.value = true;
    }
  }

  Future queryLiveInfoH5() async {
    var res = await _getRoomInfoH5.execute(roomId: roomId);
    if (res['status']) {
      roomInfoH5.value = res['data'];
    }
    return res;
  }

  void changeQn(int qn) async {
    tempCurrentQn = currentQn;
    if (currentQn == qn) {
      return;
    }
    currentQn = qn;
    currentQnDesc.value = LiveQuality.values
        .firstWhere((element) => element.code == currentQn)
        .description;
    await queryLiveInfo();
  }

  Future liveDanmakuInfo() async {
    var res = await _getDanmakuInfo.execute(roomId: roomId);
    if (res['status']) {
      danmuHostList = (res["data"]["host_list"] as List)
          .map<String>((e) => '${e["host"]}:${e['wss_port']}')
          .toList();
      token = res["data"]["token"];
      return res;
    }
  }

  void initSocket() async {
    final wsUrl = danmuHostList.isNotEmpty
        ? danmuHostList.first
        : "broadcastlv.chat.bilibili.com";
    plSocket = PlSocket(
      url: 'wss://$wsUrl/sub',
      heartTime: 30,
      onReadyCb: () {
        joinRoom();
      },
      onMessageCb: (message) {
        final List<LiveMessageModel>? liveMsg =
            LiveUtils.decodeMessage(message);
        if (liveMsg != null && liveMsg.isNotEmpty) {
          if (liveMsg.first.type == LiveMessageType.online) {
            print('当前直播间人气：${liveMsg.first.data}');
          } else if (liveMsg.first.type == LiveMessageType.join ||
              liveMsg.first.type == LiveMessageType.follow) {
            int index = 0;
            Timer.periodic(const Duration(seconds: 2), (timer) {
              if (index < liveMsg.length) {
                if (liveMsg[index].type == LiveMessageType.join ||
                    liveMsg[index].type == LiveMessageType.follow) {
                  joinRoomTip.value = {
                    'userName': liveMsg[index].userName,
                    'message': liveMsg[index].message!,
                  };
                }
                index++;
              } else {
                timer.cancel();
              }
            });
            return;
          }
          var chatMessages =
              liveMsg.where((msg) => msg.type == LiveMessageType.chat).toList();
          messageList.addAll(chatMessages);
          List<DanmakuItem> danmakuItems = chatMessages.map<DanmakuItem>((e) {
            return DanmakuItem(
              e.message ?? '',
              color: Color.fromARGB(
                255,
                e.color.r,
                e.color.g,
                e.color.b,
              ),
            );
          }).toList();
          if (danmakuSwitch.value) {
            danmakuController?.addItems(danmakuItems);
          }
        }
      },
      onErrorCb: (e) {
        print('error: $e');
      },
    );
    await plSocket?.connect();
  }

  void joinRoom() async {
    var joinData = LiveUtils.encodeData(
      json.encode({
        "uid": userId,
        "roomid": roomId,
        "protover": 3,
        "buvid": buvid,
        "platform": "web",
        "type": 2,
        "key": token,
      }),
      7,
    );
    plSocket?.sendMessage(joinData);
  }

  void sendMsg() async {
    final msg = inputController.text;
    if (msg.isEmpty) {
      return;
    }
    final res = await _sendDanmaku.execute(roomId: roomId, msg: msg);
    if (res['status']) {
      inputController.clear();
    } else {
      SmartDialog.showToast(res['msg']);
    }
  }

  void heartBeat() {
    _liveRoomEntry.execute(roomId: roomId);
  }

  @override
  void onClose() {
    heartBeat();
    plSocket?.onClose();
    inputController.dispose();
    super.onClose();
  }
}
