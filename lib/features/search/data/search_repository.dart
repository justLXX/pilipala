import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/models/search/hot.dart';
import 'package:pilipala/models/search/result.dart';
import 'package:pilipala/utils/storage.dart';

/// SearchRepository provides a clean interface for search-related data operations.
class SearchRepository {
  final ApiClient _apiClient;

  SearchRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  List<dynamic> _getBlackMidsList() {
    try {
      return GStrorage.setting.get(
        SettingBoxKey.blackMidsList,
        defaultValue: [-1],
      );
    } catch (_) {
      return [-1];
    }
  }

  /// Get hot search list.
  Future<ApiResponse<List<HotSearchItem>>> getHotSearchList() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.hotSearchList,
    );

    if (response.isSuccess && response.data != null) {
      final list = (response.data!['list'] as List?)
              ?.map((e) => HotSearchItem.fromJson(e))
              .toList() ??
          [];
      return ApiResponse.success(list);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Search for content.
  Future<ApiResponse<SearchVideoModel>> search({
    required String keyword,
    required String searchType,
    int page = 1,
    int pageSize = 20,
    String order = 'totalrank',
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.searchByType,
      queryParameters: {
        'keyword': keyword,
        'search_type': searchType,
        'page': page,
        'pagesize': pageSize,
        if (order.isNotEmpty) 'order': order,
      },
    );

    if (response.isSuccess && response.data != null) {
      final resultList = response.data!['result'];
      if (resultList is List) {
        final blackMidsList = _getBlackMidsList();
        response.data!['result'] = resultList.map((item) {
          if (item is! Map) return item;
          return <String, dynamic>{
            ...item,
            'available': !blackMidsList.contains(item['mid']),
          };
        }).toList();
      }
      final result = SearchVideoModel.fromJson(response.data!);
      return ApiResponse.success(result);
    }

    return ApiResponse.error(msg: response.msg);
  }

  /// Get search suggestions.
  Future<ApiResponse<List<String>>> getSearchSuggestions(String keyword) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.searchSuggest,
      queryParameters: {'term': keyword},
    );

    if (response.isSuccess && response.data != null) {
      final suggestions = (response.data!['result'] as List?)
              ?.map((e) => e['term'] as String)
              .toList() ??
          [];
      return ApiResponse.success(suggestions);
    }

    return ApiResponse.error(msg: response.msg);
  }
}
