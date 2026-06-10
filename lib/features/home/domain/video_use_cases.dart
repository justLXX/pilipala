import 'package:get/get.dart';
import 'package:pilipala/features/home/data/video_repository.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/model_rec_video_item.dart';

/// Use case for getting recommended videos.
///
/// This use case encapsulates the business logic for fetching
/// recommended videos with optional filtering.
class GetRecommendedVideosUseCase {
  final VideoRepository _repository;

  GetRecommendedVideosUseCase({VideoRepository? repository})
      : _repository = repository ?? Get.find<VideoRepository>();

  /// Execute the use case.
  ///
  /// [freshIdx] - Refresh index (0-based counter)
  /// [pageSize] - Number of items per page
  /// [type] - Recommendation type ('web', 'app', 'notLogin')
  Future<List<RecVideoItemModel>> execute({
    int freshIdx = 0,
    int pageSize = 20,
    String type = 'web',
  }) async {
    final response = type == 'app'
        ? await _repository.getRecommendedVideosApp()
        : await _repository.getRecommendedVideos(
            freshIdx: freshIdx,
            pageSize: pageSize,
          );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load recommended videos');
  }
}

/// Use case for getting hot videos.
class GetHotVideosUseCase {
  final VideoRepository _repository;

  GetHotVideosUseCase({VideoRepository? repository})
      : _repository = repository ?? Get.find<VideoRepository>();

  /// Execute the use case.
  Future<List<HotVideoItemModel>> execute({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getHotVideos(
      page: page,
      pageSize: pageSize,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load hot videos');
  }
}

/// Use case for liking a video.
class LikeVideoUseCase {
  final VideoRepository _repository;

  LikeVideoUseCase({VideoRepository? repository})
      : _repository = repository ?? Get.find<VideoRepository>();

  /// Execute the use case.
  Future<void> execute({
    required String bvid,
    required bool like,
  }) async {
    final response = await _repository.likeVideo(
      bvid: bvid,
      like: like,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to like video');
    }
  }
}
