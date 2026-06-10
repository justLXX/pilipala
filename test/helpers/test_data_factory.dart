import 'package:pilipala/models/model_hot_video_item.dart' as hot;
import 'package:pilipala/models/model_rec_video_item.dart' as rec;
import 'package:pilipala/models/user/info.dart';

/// Test data factory for creating mock data.
class TestDataFactory {
  // ==================== Video Data ====================

  /// Create a test hot video item.
  static hot.HotVideoItemModel createHotVideo({
    int? aid,
    String? bvid,
    String? title,
    int? duration,
    int? view,
    int? like,
  }) {
    return hot.HotVideoItemModel(
      aid: aid ?? 12345,
      bvid: bvid ?? 'BV1xx411c7mD',
      title: title ?? 'Test Video Title',
      duration: duration ?? 120,
      stat: hot.Stat(
        view: view ?? 1000,
        like: like ?? 100,
      ),
    );
  }

  /// Create a test recommended video item.
  static rec.RecVideoItemModel createRecVideo({
    int? id,
    String? bvid,
    String? title,
    int? duration,
  }) {
    return rec.RecVideoItemModel(
      id: id ?? 12345,
      bvid: bvid ?? 'BV1xx411c7mD',
      title: title ?? 'Test Video Title',
      duration: duration ?? 120,
    );
  }

  // ==================== User Data ====================

  /// Create a test user info.
  static UserInfoData createUser({
    int? mid,
    String? uname,
    String? face,
    int? level,
  }) {
    return UserInfoData(
      mid: mid ?? 12345,
      uname: uname ?? 'TestUser',
      face: face ?? 'https://example.com/face.jpg',
      levelInfo: LevelInfo(currentLevel: level ?? 5),
    );
  }

  // ==================== API Response Data ====================

  /// Create a success API response.
  static Map<String, dynamic> createSuccessResponse(dynamic data) {
    return {
      'code': 0,
      'message': '0',
      'ttl': 1,
      'data': data,
    };
  }

  /// Create an error API response.
  static Map<String, dynamic> createErrorResponse({
    int code = -1,
    String message = 'Error',
  }) {
    return {
      'code': code,
      'message': message,
      'ttl': 1,
      'data': null,
    };
  }
}
