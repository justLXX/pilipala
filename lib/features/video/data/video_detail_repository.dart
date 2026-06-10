import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/http/video.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/models/video/play/url.dart';
import 'package:pilipala/models/video/reply/data.dart';

/// VideoDetailRepository provides a clean interface for video detail operations.
class VideoDetailRepository {
  final ApiClient _apiClient;

  VideoDetailRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get video detail information.
  Future<ApiResponse<VideoDetailData>> getVideoDetail({
    String? bvid,
    int? aid,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.videoIntro,
      queryParameters: {
        if (bvid != null) 'bvid': bvid,
        if (aid != null) 'aid': aid,
      },
    );

    if (response.isSuccess && response.data != null) {
      final videoDetail = VideoDetailData.fromJson(response.data!);
      return ApiResponse.success(videoDetail);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get video play URL.
  ///
  /// Delegates to [VideoHttp.videoUrl] to use the legacy implementation
  /// with all required parameters (fnval=4048, WbiSign, etc.).
  Future<ApiResponse<PlayUrlModel>> getVideoPlayUrl({
    required int avid,
    required int cid,
    String? bvid,
    int qn = 80,
  }) async {
    final result = await VideoHttp.videoUrl(
      avid: avid,
      bvid: bvid,
      cid: cid,
      qn: qn,
    );

    if (result['status'] == true && result['data'] != null) {
      return ApiResponse.success(result['data'] as PlayUrlModel);
    }

    return ApiResponse.error(
      msg: result['msg']?.toString() ?? 'Failed to load play URL',
      code: result['code'] ?? -1,
    );
  }

  /// Get video comments.
  Future<ApiResponse<ReplyData>> getVideoComments({
    required int oid,
    int page = 1,
    int pageSize = 20,
    int sort = 1,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.replyList,
      queryParameters: {
        'oid': oid,
        'pn': page,
        'ps': pageSize,
        'sort': sort,
        'type': 1,
      },
    );

    if (response.isSuccess && response.data != null) {
      final replyData = ReplyData.fromJson(response.data!);
      return ApiResponse.success(replyData);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Like a video.
  Future<ApiResponse<void>> likeVideo({
    required String bvid,
    required bool like,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.likeVideo,
      data: {
        'bvid': bvid,
        'like': like ? 1 : 2,
        'csrf': await Request.getCsrf(),
      },
    );

    return response;
  }

  /// Coin a video.
  Future<ApiResponse<void>> coinVideo({
    required String bvid,
    required int multiply,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.coinVideo,
      data: {
        'bvid': bvid,
        'multiply': multiply,
        'csrf': await Request.getCsrf(),
      },
    );

    return response;
  }

  /// Collect (favorite) a video.
  Future<ApiResponse<void>> collectVideo({
    required int aid,
    required List<int> addMediaIds,
    List<int>? delMediaIds,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.favVideo,
      data: {
        'rid': aid,
        'type': 2,
        'add_media_ids': addMediaIds.join(','),
        if (delMediaIds != null) 'del_media_ids': delMediaIds.join(','),
        'csrf': await Request.getCsrf(),
      },
    );

    return response;
  }
}
