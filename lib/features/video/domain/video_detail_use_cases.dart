import 'package:get/get.dart';
import 'package:pilipala/features/video/data/video_detail_repository.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/models/video/play/url.dart';
import 'package:pilipala/models/video/reply/data.dart';

/// Use case for getting video detail.
class GetVideoDetailUseCase {
  final VideoDetailRepository _repository;

  GetVideoDetailUseCase({VideoDetailRepository? repository})
      : _repository = repository ?? Get.find<VideoDetailRepository>();

  /// Execute the use case.
  Future<VideoDetailData> execute({String? bvid, int? aid}) async {
    final response = await _repository.getVideoDetail(
      bvid: bvid,
      aid: aid,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load video detail');
  }
}

/// Use case for getting video play URL.
class GetVideoPlayUrlUseCase {
  final VideoDetailRepository _repository;

  GetVideoPlayUrlUseCase({VideoDetailRepository? repository})
      : _repository = repository ?? Get.find<VideoDetailRepository>();

  /// Execute the use case.
  Future<PlayUrlModel> execute({
    required int avid,
    required int cid,
    String? bvid,
    int qn = 80,
  }) async {
    final response = await _repository.getVideoPlayUrl(
      avid: avid,
      cid: cid,
      bvid: bvid,
      qn: qn,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load play URL');
  }
}

/// Use case for getting video comments.
class GetVideoCommentsUseCase {
  final VideoDetailRepository _repository;

  GetVideoCommentsUseCase({VideoDetailRepository? repository})
      : _repository = repository ?? Get.find<VideoDetailRepository>();

  /// Execute the use case.
  Future<ReplyData> execute({
    required int oid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getVideoComments(
      oid: oid,
      page: page,
      pageSize: pageSize,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load comments');
  }
}

/// Use case for liking/unliking a video.
class LikeVideoUseCase {
  final VideoDetailRepository _repository;

  LikeVideoUseCase({VideoDetailRepository? repository})
      : _repository = repository ?? Get.find<VideoDetailRepository>();

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

/// Use case for collecting/uncollecting a video.
class CollectVideoUseCase {
  final VideoDetailRepository _repository;

  CollectVideoUseCase({VideoDetailRepository? repository})
      : _repository = repository ?? Get.find<VideoDetailRepository>();

  /// Execute the use case.
  Future<void> execute({
    required int aid,
    required List<int> addMediaIds,
    List<int>? delMediaIds,
  }) async {
    final response = await _repository.collectVideo(
      aid: aid,
      addMediaIds: addMediaIds,
      delMediaIds: delMediaIds,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to collect video');
    }
  }
}

/// Use case for coining a video.
class CoinVideoUseCase {
  final VideoDetailRepository _repository;

  CoinVideoUseCase({VideoDetailRepository? repository})
      : _repository = repository ?? Get.find<VideoDetailRepository>();

  /// Execute the use case.
  Future<void> execute({
    required String bvid,
    required int multiply,
  }) async {
    final response = await _repository.coinVideo(
      bvid: bvid,
      multiply: multiply,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to coin video');
    }
  }
}
