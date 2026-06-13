import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/user/fav_detail.dart';
import 'package:pilipala/models/video/later.dart';
import 'package:pilipala/models/user/history.dart';

/// MediaRepository provides a clean interface for media-related data operations.
class MediaRepository {
  final ApiClient _apiClient;

  MediaRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get watch later list.
  Future<ApiResponse<List<MediaVideoItemModel>>> getWatchLaterList() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.seeYouLater,
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['list'] as List?)
          ?.map((e) => MediaVideoItemModel.fromJson(e))
          .toList() ?? [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get history list.
  Future<ApiResponse<List<HisListItem>>> getHistoryList({
    int? max,
    int? viewAt,
    String? business,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.historyList,
      queryParameters: {
        if (max != null) 'max': max,
        if (viewAt != null) 'view_at': viewAt,
        if (business != null) 'business': business,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      final list = (data['list'] as List?)
          ?.map((e) => HisListItem.fromJson(e))
          .toList() ?? [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get favorite folders.
  Future<ApiResponse<List<FavFolderItemData>>> getFavFolders({
    required int mid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userFavFolder,
      queryParameters: {
        'up_mid': mid,
        'pn': page,
        'ps': pageSize,
      },
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['list'] as List?)
          ?.map((e) => FavFolderItemData.fromJson(e))
          .toList() ?? [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get favorite folder detail.
  Future<ApiResponse<List<FavDetailItemData>>> getFavFolderDetail({
    required int mediaId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userFavFolderDetail,
      queryParameters: {
        'media_id': mediaId,
        'pn': page,
        'ps': pageSize,
      },
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['medias'] as List?)
          ?.map((e) => FavDetailItemData.fromJson(e))
          .toList() ?? [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Add video to watch later.
  Future<ApiResponse<void>> addToWatchLater({
    required String bvid,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.toViewLater,
      data: {
        'bvid': bvid,
        'csrf': await _getCsrf(),
      },
    );

    return response;
  }

  /// Remove video from watch later.
  Future<ApiResponse<void>> removeFromWatchLater({
    required String bvid,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.toViewDel,
      data: {
        'bvid': bvid,
        'csrf': await _getCsrf(),
      },
    );

    return response;
  }

  /// Pause/resume history.
  Future<ApiResponse<void>> pauseHistory({required bool pause}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.pauseHistory,
      data: {
        'switch': pause,
        'csrf': await _getCsrf(),
      },
    );
    return response;
  }

  /// Get history pause status.
  Future<ApiResponse<bool>> getHistoryStatus() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.historyStatus,
    );
    if (response.isSuccess && response.data != null) {
      return ApiResponse.success(response.data!['data'] as bool);
    }
    return ApiResponse.error(msg: response.msg);
  }

  /// Clear all history.
  Future<ApiResponse<void>> clearHistory() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.clearHistory,
      data: {
        'csrf': await _getCsrf(),
      },
    );
    return response;
  }

  /// Delete single history item.
  Future<ApiResponse<void>> deleteHistory({required String kid}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.delHistory,
      data: {
        'kid': kid,
        'csrf': await _getCsrf(),
      },
    );
    return response;
  }

  /// Get favorite folder detail with keyword search.
  Future<ApiResponse<Map<String, dynamic>>> getFavFolderDetailSearch({
    required int mediaId,
    int page = 1,
    int pageSize = 20,
    String? keyword,
    int? type,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userFavFolderDetail,
      queryParameters: {
        'media_id': mediaId,
        'pn': page,
        'ps': pageSize,
        if (keyword != null) 'keyword': keyword,
        if (type != null) 'type': type,
      },
    );
    return response;
  }

  /// Delete favorite folder.
  Future<ApiResponse<void>> deleteFavFolder({required int mediaId}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.delFavFolder,
      data: {
        'media_id': mediaId,
        'csrf': await _getCsrf(),
      },
    );
    return response;
  }

  /// Cancel video from favorite.
  Future<ApiResponse<void>> cancelFavVideo({
    required int aid,
    required String mediaIds,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.favVideo,
      data: {
        'aid': aid,
        'del_media_ids': mediaIds,
        'csrf': await _getCsrf(),
      },
    );
    return response;
  }

  /// Search history.
  Future<ApiResponse<Map<String, dynamic>>> searchHistory({
    required int pn,
    required String keyword,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.searchHistory,
      queryParameters: {
        'pn': pn,
        'keyword': keyword,
      },
    );
    return response;
  }

  /// Get subscription folder list.
  Future<ApiResponse<Map<String, dynamic>>> getSubFolder({
    required int mid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userSubFolder,
      queryParameters: {
        'mid': mid,
        'pn': page,
        'ps': pageSize,
      },
    );
    return response;
  }

  /// Cancel subscription.
  Future<ApiResponse<void>> cancelSubscription({required int seasonId}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.cancelSub,
      data: {
        'season_id': seasonId,
        'csrf': await _getCsrf(),
      },
    );
    return response;
  }

  /// Get subscription season list.
  Future<ApiResponse<Map<String, dynamic>>> getSeasonList({
    required int seasonId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userSeasonList,
      queryParameters: {
        'season_id': seasonId,
        'pn': page,
        'ps': pageSize,
      },
    );
    return response;
  }

  /// Get subscription resource list.
  Future<ApiResponse<Map<String, dynamic>>> getResourceList({
    required int seasonId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userResourceList,
      queryParameters: {
        'season_id': seasonId,
        'pn': page,
        'ps': pageSize,
      },
    );
    return response;
  }

  /// Get CSRF token for POST requests.
  Future<String> _getCsrf() async {
    return await Request.getCsrf();
  }
}
