import 'package:get/get.dart';
import 'package:pilipala/features/bangumi/data/bangumi_repository.dart';

/// Use case for getting bangumi list.
class GetBangumiListUseCase {
  final BangumiRepository _repository;

  GetBangumiListUseCase({BangumiRepository? repository})
      : _repository = repository ?? Get.find<BangumiRepository>();

  Future<Map<String, dynamic>> execute({int page = 1}) async {
    return await _repository.getBangumiList(page: page);
  }
}

/// Use case for getting followed bangumi list.
class GetFollowedBangumiListUseCase {
  final BangumiRepository _repository;

  GetFollowedBangumiListUseCase({BangumiRepository? repository})
      : _repository = repository ?? Get.find<BangumiRepository>();

  Future<Map<String, dynamic>> execute({required int mid}) async {
    return await _repository.getFollowedBangumiList(mid: mid);
  }
}

/// Use case for following a bangumi.
class FollowBangumiUseCase {
  final BangumiRepository _repository;

  FollowBangumiUseCase({BangumiRepository? repository})
      : _repository = repository ?? Get.find<BangumiRepository>();

  Future<Map<String, dynamic>> execute({required int seasonId}) async {
    return await _repository.followBangumi(seasonId: seasonId);
  }
}

/// Use case for unfollowing a bangumi.
class UnfollowBangumiUseCase {
  final BangumiRepository _repository;

  UnfollowBangumiUseCase({BangumiRepository? repository})
      : _repository = repository ?? Get.find<BangumiRepository>();

  Future<Map<String, dynamic>> execute({required int seasonId}) async {
    return await _repository.unfollowBangumi(seasonId: seasonId);
  }
}
