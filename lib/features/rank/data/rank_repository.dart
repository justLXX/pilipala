import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/wbi_sign.dart';

/// RankRepository provides data access for the ranking feature.
///
/// Wraps the Bilibili ranking API (`/x/web-interface/ranking/v2`) and
/// applies user-level blacklist filtering before returning results.
class RankRepository {
  final ApiClient _apiClient;

  RankRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Fetch the ranking video list for the given zone [rid].
  ///
  /// - `rid = 0` means "全站" (all zones).
  /// - Other rid values correspond to specific content zones (e.g. 1005 = 动画).
  ///
  /// Returns an [ApiResponse] containing a list of [HotVideoItemModel].
  Future<ApiResponse<List<HotVideoItemModel>>> getRankVideoList({
    required int rid,
  }) async {
    final Map<String, dynamic> signedParams = await WbiSign().makSign({
      'rid': rid,
      'type': 'all',
    });
    debugPrint('🔐 Rank WBI signed params: $signedParams');

    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.getRankApi,
      queryParameters: signedParams,
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
        if (item['owner'] != null &&
            !blackMidsList.contains(item['owner']['mid'])) {
          items.add(HotVideoItemModel.fromJson(item));
        }
      }
      return ApiResponse.success(items);
    }

    return ApiResponse.error(msg: response.msg);
  }
}
