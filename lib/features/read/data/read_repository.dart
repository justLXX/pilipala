import 'package:pilipala/http/read.dart';

/// Repository for read (CV article) feature.
/// Handles API calls related to CV articles.
class ReadRepository {
  /// Fetch CV article data.
  Future<Map<String, dynamic>> fetchCvData({
    required String id,
  }) async {
    final res = await ReadHttp.parseArticleCv(id: id);
    return res as Map<String, dynamic>;
  }

  /// Fetch view info for CV article.
  Future<Map<String, dynamic>> fetchViewInfo({
    required String id,
  }) async {
    final res = await ReadHttp.getViewInfo(id: id);
    return res as Map<String, dynamic>;
  }
}
