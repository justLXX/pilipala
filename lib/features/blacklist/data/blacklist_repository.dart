import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/models/user/black.dart';

/// BlacklistRepository provides a clean interface for blacklist-related data operations.
class BlacklistRepository {
  final ApiClient _apiClient;

  BlacklistRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get blacklist with pagination.
  Future<Map<String, dynamic>> getBlacklist({
    int pn = 1,
    int ps = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.blackLst,
      queryParameters: {
        'pn': pn,
        'ps': ps,
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = BlackListDataModel.fromJson(response.data!);
      return {
        'status': true,
        'data': data,
      };
    }
    return {'status': false, 'msg': response.msg ?? '获取黑名单失败'};
  }

  /// Remove a user from blacklist.
  Future<Map<String, dynamic>> removeFromBlacklist(int mid) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.removeBlack,
      data: {
        'act': 6, // Remove from blacklist
        'fids': mid,
        'csrf': await _getCsrf(),
      },
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      if (data['code'] == 0) {
        return {'status': true, 'msg': '已移除'};
      }
      return {'status': false, 'msg': data['message'] ?? '移除失败'};
    }
    return {'status': false, 'msg': response.msg ?? '移除失败'};
  }

  /// Get CSRF token from cookies.
  Future<String> _getCsrf() async {
    // TODO: Implement CSRF token retrieval from cookies
    return '';
  }
}
