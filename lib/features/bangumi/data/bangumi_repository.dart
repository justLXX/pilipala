import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/models/bangumi/list.dart';

/// BangumiRepository provides a clean interface for bangumi-related data operations.
class BangumiRepository {
  final ApiClient _apiClient;

  BangumiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get bangumi list with pagination.
  Future<Map<String, dynamic>> getBangumiList({int page = 1}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.bangumiList,
      queryParameters: {'pn': page},
    );

    if (response.isSuccess && response.data != null) {
      final data = BangumiListDataModel.fromJson(response.data!);
      return {
        'status': true,
        'data': data,
      };
    }
    return {'status': false, 'msg': response.msg ?? '获取番剧列表失败'};
  }

  /// Get followed bangumi list.
  Future<Map<String, dynamic>> getFollowedBangumiList({
    required int mid,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.bangumiFollow,
      queryParameters: {'mid': mid},
    );

    if (response.isSuccess && response.data != null) {
      final data = BangumiListDataModel.fromJson(response.data!);
      return {
        'status': true,
        'data': data,
      };
    }
    return {'status': false, 'msg': response.msg ?? '获取追番列表失败'};
  }

  /// Follow a bangumi.
  Future<Map<String, dynamic>> followBangumi({
    required int seasonId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.bangumiAdd,
      data: {
        'season_id': seasonId,
        'csrf': await _getCsrf(),
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      if (data['code'] == 0) {
        return {'status': true, 'msg': '追番成功'};
      }
      return {'status': false, 'msg': data['message'] ?? '追番失败'};
    }
    return {'status': false, 'msg': response.msg ?? '追番失败'};
  }

  /// Unfollow a bangumi.
  Future<Map<String, dynamic>> unfollowBangumi({
    required int seasonId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.bangumiDel,
      data: {
        'season_id': seasonId,
        'csrf': await _getCsrf(),
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      if (data['code'] == 0) {
        return {'status': true, 'msg': '取消追番成功'};
      }
      return {'status': false, 'msg': data['message'] ?? '取消追番失败'};
    }
    return {'status': false, 'msg': response.msg ?? '取消追番失败'};
  }

  /// Get CSRF token from cookies.
  Future<String> _getCsrf() async {
    // TODO: Implement CSRF token retrieval from cookies
    return '';
  }
}
