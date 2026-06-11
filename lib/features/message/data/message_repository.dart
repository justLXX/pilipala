import 'package:pilipala/http/msg.dart';

/// MessageRepository wraps all message-related HTTP calls.
class MessageRepository {
  /// Fetch the session (conversation) list.
  Future<Map<String, dynamic>> getSessionList({int? endTs}) async {
    return await MsgHttp.sessionList(endTs: endTs);
  }

  /// Fetch account info for a batch of user IDs.
  Future<Map<String, dynamic>> getAccountList(String mids) async {
    return await MsgHttp.accountList(mids);
  }

  /// Fetch unread message counts.
  Future<Map<String, dynamic>> getUnreadCount() async {
    return await MsgHttp.unread();
  }

  /// Fetch messages within a session.
  Future<Map<String, dynamic>> getSessionMsg({int? talkerId}) async {
    return await MsgHttp.sessionMsg(talkerId: talkerId);
  }

  /// Acknowledge (mark read) session messages.
  Future<void> ackSessionMsg({int? talkerId, int? ackSeqno}) async {
    await MsgHttp.ackSessionMsg(talkerId: talkerId, ackSeqno: ackSeqno);
  }

  /// Send a private message.
  Future<Map<String, dynamic>> sendMsg({
    required int senderUid,
    required int receiverId,
    required Map<String, dynamic> content,
    required int msgType,
  }) async {
    return await MsgHttp.sendMsg(
      senderUid: senderUid,
      receiverId: receiverId,
      content: content,
      msgType: msgType,
    );
  }

  /// Remove a session.
  Future<Map<String, dynamic>> removeSession({int? talkerId}) async {
    return await MsgHttp.removeSession(talkerId: talkerId);
  }

  /// Fetch reply notifications.
  Future<Map<String, dynamic>> getReplyNotifications({int? id, int? replyTime}) async {
    return await MsgHttp.messageReply(id: id, replyTime: replyTime);
  }

  /// Fetch like notifications.
  Future<Map<String, dynamic>> getLikeNotifications({int? id, int? likeTime}) async {
    return await MsgHttp.messageLike(id: id, likeTime: likeTime);
  }

  /// Fetch system notifications.
  Future<Map<String, dynamic>> getSystemNotifications() async {
    return await MsgHttp.messageSystem();
  }

  /// Fetch system account notifications.
  Future<Map<String, dynamic>> getSystemAccountNotifications() async {
    return await MsgHttp.messageSystemAccount();
  }

  /// Mark system notification as read.
  Future<void> markSystemRead(int cursor) async {
    await MsgHttp.systemMarkRead(cursor);
  }
}
