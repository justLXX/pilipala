import 'package:pilipala/features/message/data/message_repository.dart';

class GetSessionListUseCase {
  final MessageRepository _repo;
  GetSessionListUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute({int? endTs}) => _repo.getSessionList(endTs: endTs);
}

class GetAccountListUseCase {
  final MessageRepository _repo;
  GetAccountListUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute(String mids) => _repo.getAccountList(mids);
}

class GetUnreadCountUseCase {
  final MessageRepository _repo;
  GetUnreadCountUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute() => _repo.getUnreadCount();
}

class GetSessionMsgUseCase {
  final MessageRepository _repo;
  GetSessionMsgUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute({int? talkerId}) => _repo.getSessionMsg(talkerId: talkerId);
}

class AckSessionMsgUseCase {
  final MessageRepository _repo;
  AckSessionMsgUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<void> execute({int? talkerId, int? ackSeqno}) => _repo.ackSessionMsg(talkerId: talkerId, ackSeqno: ackSeqno);
}

class SendMsgUseCase {
  final MessageRepository _repo;
  SendMsgUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute({
    required int senderUid,
    required int receiverId,
    required Map<String, dynamic> content,
    required int msgType,
  }) => _repo.sendMsg(senderUid: senderUid, receiverId: receiverId, content: content, msgType: msgType);
}

class RemoveSessionUseCase {
  final MessageRepository _repo;
  RemoveSessionUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute({int? talkerId}) => _repo.removeSession(talkerId: talkerId);
}

class GetReplyNotificationsUseCase {
  final MessageRepository _repo;
  GetReplyNotificationsUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute({int? id, int? replyTime}) => _repo.getReplyNotifications(id: id, replyTime: replyTime);
}

class GetLikeNotificationsUseCase {
  final MessageRepository _repo;
  GetLikeNotificationsUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute({int? id, int? likeTime}) => _repo.getLikeNotifications(id: id, likeTime: likeTime);
}

class GetSystemNotificationsUseCase {
  final MessageRepository _repo;
  GetSystemNotificationsUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute() => _repo.getSystemNotifications();
}

class GetSystemAccountNotificationsUseCase {
  final MessageRepository _repo;
  GetSystemAccountNotificationsUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<Map<String, dynamic>> execute() => _repo.getSystemAccountNotifications();
}

class MarkSystemReadUseCase {
  final MessageRepository _repo;
  MarkSystemReadUseCase({MessageRepository? repo}) : _repo = repo ?? MessageRepository();
  Future<void> execute(int cursor) => _repo.markSystemRead(cursor);
}
