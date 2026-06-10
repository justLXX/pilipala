import 'package:get/get.dart';
import 'package:pilipala/features/rank/data/rank_repository.dart';
import 'package:pilipala/models/model_hot_video_item.dart';

/// Use case for fetching the ranking video list of a specific zone.
class GetRankVideoListUseCase {
  final RankRepository _repository;

  GetRankVideoListUseCase({RankRepository? repository})
      : _repository = repository ?? Get.find<RankRepository>();

  /// Execute the use case.
  ///
  /// [rid] - Zone ID (0 = all zones).
  Future<List<HotVideoItemModel>> execute({required int rid}) async {
    final response = await _repository.getRankVideoList(rid: rid);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load rank video list');
  }
}
