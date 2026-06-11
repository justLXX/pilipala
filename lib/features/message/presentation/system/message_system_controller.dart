import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/message/domain/message_use_cases.dart';
import 'package:pilipala/models/msg/system.dart';

/// Controller for system notifications.
class MessageSystemController extends GetxController {
  late final GetSystemNotificationsUseCase _getSystem;
  late final GetSystemAccountNotificationsUseCase _getSystemAccount;
  late final MarkSystemReadUseCase _markRead;

  RxList<MessageSystemModel> systemItems = <MessageSystemModel>[].obs;

  MessageSystemController({
    GetSystemNotificationsUseCase? getSystem,
    GetSystemAccountNotificationsUseCase? getSystemAccount,
    MarkSystemReadUseCase? markRead,
  }) {
    _getSystem = getSystem ?? GetSystemNotificationsUseCase();
    _getSystemAccount = getSystemAccount ?? GetSystemAccountNotificationsUseCase();
    _markRead = markRead ?? MarkSystemReadUseCase();
  }

  Future<void> queryAndProcessMessages({String type = 'init'}) async {
    var results = await Future.wait([
      queryMessageSystem(type: type),
      queryMessageSystemAccount(type: type),
    ]);
    var systemRes = results[0];
    var accountRes = results[1];
    if (systemRes['status'] || accountRes['status']) {
      List<MessageSystemModel> combinedData = [
        ...systemRes['data'],
        ...accountRes['data']
      ];
      combinedData.sort((a, b) => b.cursor!.compareTo(a.cursor!));
      systemItems.addAll(combinedData);
      systemItems.refresh();
      if (systemItems.isNotEmpty) {
        systemMarkRead(systemItems.first.cursor!);
      }
    } else {
      SmartDialog.showToast(systemRes['msg'] ?? accountRes['msg']);
    }
    return systemRes;
  }

  Future queryMessageSystem({String type = 'init'}) async {
    return await _getSystem.execute();
  }

  Future queryMessageSystemAccount({String type = 'init'}) async {
    return await _getSystemAccount.execute();
  }

  void systemMarkRead(int cursor) async {
    await _markRead.execute(cursor);
  }
}
