import 'package:get/get.dart';
import 'package:pilipala/features/message/domain/message_use_cases.dart';
import 'package:pilipala/models/msg/reply.dart';

/// Controller for reply notifications.
class MessageReplyController extends GetxController {
  late final GetReplyNotificationsUseCase _getReplies;

  Cursor? cursor;
  RxList<MessageReplyItem> replyItems = <MessageReplyItem>[].obs;

  MessageReplyController({GetReplyNotificationsUseCase? getReplies}) {
    _getReplies = getReplies ?? GetReplyNotificationsUseCase();
  }

  Future queryMessageReply({String type = 'init'}) async {
    if (cursor != null && cursor!.isEnd == true) {
      return {};
    }
    var res = await _getReplies.execute(
      id: type == 'onLoad' ? cursor!.id : null,
      replyTime: type == 'onLoad' ? cursor!.time : null,
    );
    if (res['status']) {
      cursor = res['data'].cursor;
      replyItems.addAll(res['data'].items);
    }
    return res;
  }
}
