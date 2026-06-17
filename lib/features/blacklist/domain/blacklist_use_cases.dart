import 'package:get/get.dart';
import 'package:pilipala/features/blacklist/data/blacklist_repository.dart';
import 'package:pilipala/models/user/black.dart';

/// Use case for getting blacklist.
class GetBlacklistUseCase {
  final BlacklistRepository _repository;

  GetBlacklistUseCase({BlacklistRepository? repository})
      : _repository = repository ?? Get.find<BlacklistRepository>();

  Future<Map<String, dynamic>> execute({int pn = 1, int ps = 50}) async {
    return await _repository.getBlacklist(pn: pn, ps: ps);
  }
}

/// Use case for removing a user from blacklist.
class RemoveFromBlacklistUseCase {
  final BlacklistRepository _repository;

  RemoveFromBlacklistUseCase({BlacklistRepository? repository})
      : _repository = repository ?? Get.find<BlacklistRepository>();

  Future<Map<String, dynamic>> execute(int mid) async {
    return await _repository.removeFromBlacklist(mid);
  }
}
