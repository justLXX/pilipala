import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:pilipala/models/github/latest.dart';

/// AboutRepository provides a clean interface for about-related data operations.
class AboutRepository {
  /// Fetch the latest release info from GitHub API.
  Future<Map<String, dynamic>> getLatestRelease() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/guozhigq/pilipala/releases/latest'),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'PiliPala-App',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': true,
          'data': LatestDataModel.fromJson(data),
        };
      }
      return {'status': false, 'msg': '获取更新信息失败: ${response.statusCode}'};
    } catch (e) {
      return {'status': false, 'msg': '获取更新信息失败: $e'};
    }
  }
}
