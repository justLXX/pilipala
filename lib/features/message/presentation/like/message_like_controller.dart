import 'package:get/get.dart';
import 'package:pilipala/features/message/domain/message_use_cases.dart';
import 'package:pilipala/models/msg/like.dart';

/// Controller for like notifications.
class MessageLikeController extends GetxController {
  late final GetLikeNotificationsUseCase _getLikes;

  Cursor? cursor;
  RxList<MessageLikeItem> likeItems = <MessageLikeItem>[].obs;

  MessageLikeController({GetLikeNotificationsUseCase? getLikes}) {
    _getLikes = getLikes ?? GetLikeNotificationsUseCase();
  }

  Future queryMessageLike({String type = 'init'}) async {
    if (cursor != null && cursor!.isEnd == true) {
      return {};
    }
    var res = await _getLikes.execute(
      id: type == 'onLoad' ? cursor!.id : null,
      likeTime: type == 'onLoad' ? cursor!.time : null,
    );
    if (res['status']) {
      cursor = res['data'].total.cursor;
      likeItems.addAll(res['data'].total.items);
    }
    return res;
  }

  Future expandedUsersAvatar(i) async {
    likeItems[i].isExpand = !likeItems[i].isExpand;
    likeItems.refresh();
  }
}
