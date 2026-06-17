import 'package:get/get.dart';

import '../data/main_repository.dart';

/// GetUnreadDynamicUseCase - 获取未读动态数量
class GetUnreadDynamicUseCase {
  final MainRepository _repository;

  GetUnreadDynamicUseCase({MainRepository? repository})
      : _repository = repository ?? Get.find<MainRepository>();
  Future<Map<String, dynamic>> execute() async {
    return await _repository.getUnreadDynamic();
  }
}
