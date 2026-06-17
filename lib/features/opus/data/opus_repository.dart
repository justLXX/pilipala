import 'package:get/get.dart';
import 'package:pilipala/http/read.dart';
import 'package:pilipala/models/read/opus.dart';

/// Repository for opus (column article) feature.
/// Handles API calls related to column articles.
class OpusRepository {
  /// Fetch opus article data.
  Future<Map<String, dynamic>> fetchOpusData({
    required String id,
  }) async {
    final res = await ReadHttp.parseArticleOpus(id: id);
    return res as Map<String, dynamic>;
  }
}
