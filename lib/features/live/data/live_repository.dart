import 'package:pilipala/http/live.dart';
import 'package:pilipala/models/live/follow.dart';
import 'package:pilipala/models/live/item.dart';
import 'package:pilipala/models/live/room_info.dart';
import 'package:pilipala/models/live/room_info_h5.dart';

/// LiveRepository provides a clean interface for live-related data operations.
class LiveRepository {
  /// Fetch the recommended live stream list.
  Future<Map<String, dynamic>> getLiveList({int page = 1}) async {
    return await LiveHttp.liveList(pn: page);
  }

  /// Fetch the following (subscribed) live streams.
  Future<Map<String, dynamic>> getFollowingLive({int page = 1, int pageSize = 20}) async {
    return await LiveHttp.liveFollowing(pn: page, ps: pageSize);
  }

  /// Fetch live room info (for player initialization).
  Future<Map<String, dynamic>> getRoomInfo({required int roomId, required int qn}) async {
    return await LiveHttp.liveRoomInfo(roomId: roomId, qn: qn);
  }

  /// Fetch live room info (H5 version, for header display).
  Future<Map<String, dynamic>> getRoomInfoH5({required int roomId}) async {
    return await LiveHttp.liveRoomInfoH5(roomId: roomId);
  }

  /// Fetch danmaku WebSocket connection info.
  Future<Map<String, dynamic>> getDanmakuInfo({required int roomId}) async {
    return await LiveHttp.liveDanmakuInfo(roomId: roomId);
  }

  /// Send a danmaku message to a live room.
  Future<Map<String, dynamic>> sendDanmaku({required int roomId, required String msg}) async {
    return await LiveHttp.sendDanmaku(roomId: roomId, msg: msg);
  }

  /// Record live room entry (heartbeat / history).
  Future<void> liveRoomEntry({required int roomId}) async {
    await LiveHttp.liveRoomEntry(roomId: roomId);
  }
}
