import 'package:pilipala/features/live/data/live_repository.dart';

/// Use case for fetching the recommended live stream list.
class GetLiveListUseCase {
  final LiveRepository _repository;

  GetLiveListUseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<Map<String, dynamic>> execute({int page = 1}) async {
    return await _repository.getLiveList(page: page);
  }
}

/// Use case for fetching following (subscribed) live streams.
class GetFollowingLiveUseCase {
  final LiveRepository _repository;

  GetFollowingLiveUseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<Map<String, dynamic>> execute({int page = 1, int pageSize = 20}) async {
    return await _repository.getFollowingLive(page: page, pageSize: pageSize);
  }
}

/// Use case for fetching live room info.
class GetRoomInfoUseCase {
  final LiveRepository _repository;

  GetRoomInfoUseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<Map<String, dynamic>> execute({required int roomId, required int qn}) async {
    return await _repository.getRoomInfo(roomId: roomId, qn: qn);
  }
}

/// Use case for fetching live room info (H5).
class GetRoomInfoH5UseCase {
  final LiveRepository _repository;

  GetRoomInfoH5UseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<Map<String, dynamic>> execute({required int roomId}) async {
    return await _repository.getRoomInfoH5(roomId: roomId);
  }
}

/// Use case for fetching danmaku WebSocket connection info.
class GetDanmakuInfoUseCase {
  final LiveRepository _repository;

  GetDanmakuInfoUseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<Map<String, dynamic>> execute({required int roomId}) async {
    return await _repository.getDanmakuInfo(roomId: roomId);
  }
}

/// Use case for sending a danmaku message.
class SendDanmakuUseCase {
  final LiveRepository _repository;

  SendDanmakuUseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<Map<String, dynamic>> execute({required int roomId, required String msg}) async {
    return await _repository.sendDanmaku(roomId: roomId, msg: msg);
  }
}

/// Use case for recording live room entry (heartbeat).
class LiveRoomEntryUseCase {
  final LiveRepository _repository;

  LiveRoomEntryUseCase({LiveRepository? repository})
      : _repository = repository ?? LiveRepository();

  Future<void> execute({required int roomId}) async {
    await _repository.liveRoomEntry(roomId: roomId);
  }
}
