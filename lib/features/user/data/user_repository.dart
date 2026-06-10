import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/models/user/stat.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/user/fav_detail.dart';
import 'package:pilipala/models/user/history.dart';
import 'package:pilipala/models/video/later.dart';
import 'package:pilipala/models/member/coin.dart';
import 'package:pilipala/models/member/like.dart';
import 'package:pilipala/models/member/seasons.dart';

/// UserRepository provides a clean interface for user-related data operations.
class UserRepository {
  final ApiClient _apiClient;

  UserRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get user information by ID.
  Future<ApiResponse<UserInfoData>> getUserInfo({int? mid}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userInfo,
      queryParameters: mid != null ? {'vmid': mid} : null,
    );

    if (response.isSuccess && response.data != null) {
      final userInfo = UserInfoData.fromJson(response.data!);
      return ApiResponse.success(userInfo);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get current logged-in user info.
  Future<ApiResponse<UserInfoData>> getCurrentUserInfo() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userInfo,
    );

    if (response.isSuccess && response.data != null) {
      final userInfo = UserInfoData.fromJson(response.data!);
      return ApiResponse.success(userInfo);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get user statistics (following, followers, etc.).
  Future<ApiResponse<UserStat>> getUserStat({required int mid}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.userStat,
      queryParameters: {'vmid': mid},
    );

    if (response.isSuccess && response.data != null) {
      final userStat = UserStat.fromJson(response.data!);
      return ApiResponse.success(userStat);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get user's favorite folders.
  Future<ApiResponse<FavFolderData>> getFavFolders({
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
      final favFolderData = FavFolderData.fromJson(response.data!);
      return ApiResponse.success(favFolderData);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get favorite folder details.
  Future<ApiResponse<FavDetailData>> getFavFolderDetail({
    required int mediaId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.mediaList,
      queryParameters: {
        'media_id': mediaId,
        'pn': page,
        'ps': pageSize,
      },
    );

    if (response.isSuccess && response.data != null) {
      final favDetailData = FavDetailData.fromJson(response.data!);
      return ApiResponse.success(favDetailData);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get watch later list.
  Future<ApiResponse<List<MediaVideoItemModel>>> getWatchLaterList() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.seeYouLater,
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['list'] as List?)
              ?.map((e) => MediaVideoItemModel.fromJson(e))
              .toList() ??
          [];
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
      final list = (response.data!['list'] as List?)
              ?.map((e) => HisListItem.fromJson(e))
              .toList() ??
          [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get user's recent coin videos.
  Future<ApiResponse<List<MemberCoinsDataModel>>> getUserCoins({
    required int mid,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.getRecentCoinVideoApi,
      queryParameters: {'vmid': mid},
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['list'] as List?)
              ?.map((e) => MemberCoinsDataModel.fromJson(e))
              .toList() ??
          [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get user's recent liked videos.
  Future<ApiResponse<List<MemberLikeDataModel>>> getUserLikes({
    required int mid,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.getRecentLikeVideoApi,
      queryParameters: {'vmid': mid},
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['list'] as List?)
              ?.map((e) => MemberLikeDataModel.fromJson(e))
              .toList() ??
          [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get user's seasons list.
  Future<ApiResponse<MemberSeasonsDataModel>> getUserSeasons({
    required int mid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.getMemberSeasonsApi,
      queryParameters: {
        'mid': mid,
        'page': page,
        'page_size': pageSize,
      },
    );

    if (response.isSuccess && response.data != null) {
      final seasonsData = MemberSeasonsDataModel.fromJson(response.data!);
      return ApiResponse.success(seasonsData);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Follow a user.
  Future<ApiResponse<void>> followUser({
    required int mid,
    required bool follow,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.relationMod,
      data: {
        'fid': mid,
        'act': follow ? 1 : 2,
        'csrf': await Request.getCsrf(),
      },
    );

    return response;
  }
}
