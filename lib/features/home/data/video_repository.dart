import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/model_rec_video_item.dart';
import 'package:pilipala/utils/recommend_filter.dart';
import 'package:pilipala/utils/storage.dart';

/// VideoRepository provides a clean interface for video-related data operations.
///
/// This repository abstracts the HTTP layer and provides:
/// - Type-safe data access
/// - Consistent error handling
/// - Testable interface
class VideoRepository {
  final ApiClient _apiClient;

  VideoRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get recommended videos (Web API).
  Future<ApiResponse<List<RecVideoItemModel>>> getRecommendedVideos({
    int freshIdx = 0,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.recommendListWeb,
      queryParameters: {
        'version': 1,
        'feed_version': 'V3',
        'homepage_ver': 1,
        'ps': pageSize,
        'fresh_idx': freshIdx,
        'brush': freshIdx,
        'fresh_type': 4,
      },
    );

    if (response.isSuccess && response.data != null) {
      final rawList = response.data!['item'] as List?;
      if (rawList == null) {
        return ApiResponse.success([]);
      }

      final Box setting = GStrorage.setting;
      final List<int> blackMidsList =
          setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);

      final List<RecVideoItemModel> items = [];
      for (final item in rawList) {
        // 过滤掉 live/ad 及拉黑用户
        if (item['goto'] == 'av' && item['owner'] != null) {
          if (!blackMidsList.contains(item['owner']['mid'])) {
            final videoItem = RecVideoItemModel.fromJson(item);
            if (!RecommendFilter.filter(videoItem)) {
              items.add(videoItem);
            }
          }
        }
      }
      return ApiResponse.success(items);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get recommended videos (App API).
  Future<ApiResponse<List<RecVideoItemModel>>> getRecommendedVideosApp({
    String? idx,
    bool flush = false,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.recommendListApp,
      queryParameters: {
        if (idx != null) 'idx': idx,
        'flush': flush ? 1 : 0,
      },
    );

    if (response.isSuccess && response.data != null) {
      final rawList = response.data!['items'] as List?;
      if (rawList == null) {
        return ApiResponse.success([]);
      }

      final Box setting = GStrorage.setting;
      final List<int> blackMidsList =
          setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);
      final bool enableRcmdDynamic =
          setting.get(SettingBoxKey.enableRcmdDynamic, defaultValue: true);

      final List<RecVideoItemModel> items = [];
      for (final item in rawList) {
        // 过滤推广/广告视频
        if (item['card_goto'] == 'ad_av' ||
            item['card_goto'] == 'ad' ||
            item['goto'] == 'ad' ||
            item['goto'] == 'ad_av' ||
            item['goto'] == 'ad_web' ||
            item['ad_info'] != null) {
          continue;
        }
        // 过滤动态图片（可配置）
        if (!enableRcmdDynamic && item['card_goto'] == 'picture') {
          continue;
        }
        // 过滤拉黑用户
        if (item['args'] != null &&
            blackMidsList.contains(item['args']['up_mid'])) {
          continue;
        }
        final videoItem = RecVideoItemModel.fromJson(item);
        if (!RecommendFilter.filter(videoItem)) {
          items.add(videoItem);
        }
      }
      return ApiResponse.success(items);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get hot videos.
  Future<ApiResponse<List<HotVideoItemModel>>> getHotVideos({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.hotList,
      queryParameters: {
        'pn': page,
        'ps': pageSize,
      },
    );

    if (response.isSuccess && response.data != null) {
      final rawList = response.data!['list'] as List?;
      if (rawList == null) {
        return ApiResponse.success([]);
      }

      final Box setting = GStrorage.setting;
      final List<int> blackMidsList =
          setting.get(SettingBoxKey.blackMidsList, defaultValue: [-1]);

      final List<HotVideoItemModel> items = [];
      for (final item in rawList) {
        // 过滤推广/广告视频
        if (item['is_ad'] == true ||
            item['is_ad'] == 1 ||
            item['ad_type'] != null ||
            item['goto'] == 'ad' ||
            item['goto'] == 'ad_av' ||
            item['goto'] == 'ad_web') {
          continue;
        }
        if (item['owner'] != null &&
            !blackMidsList.contains(item['owner']['mid'])) {
          items.add(HotVideoItemModel.fromJson(item));
        }
      }
      return ApiResponse.success(items);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get video detail.
  Future<ApiResponse<Map<String, dynamic>>> getVideoDetail({
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

    return response;
  }

  /// Get video play URL.
  Future<ApiResponse<Map<String, dynamic>>> getVideoPlayUrl({
    required int avid,
    required int cid,
    int qn = 80,
    int fnval = 16,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.videoUrl,
      queryParameters: {
        'avid': avid,
        'cid': cid,
        'qn': qn,
        'fnval': fnval,
      },
    );

    return response;
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
}
