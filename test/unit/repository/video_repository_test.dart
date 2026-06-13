import 'package:flutter_test/flutter_test.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/features/home/data/video_repository.dart';


/// Manual mock implementation of ApiClient for testing.
class TestApiClient implements ApiClient {
  ApiResponse<Map<String, dynamic>>? _mockResponse;
  Exception? _mockError;

  void setMockResponse(ApiResponse<Map<String, dynamic>> response) {
    _mockResponse = response;
    _mockError = null;
  }

  void setMockError(Exception error) {
    _mockError = error;
    _mockResponse = null;
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic options,
  }) async {
    if (_mockError != null) throw _mockError!;
    return ApiResponse<T>(
      status: _mockResponse!.status,
      data: _mockResponse!.data as T?,
      code: _mockResponse!.code,
      msg: _mockResponse!.msg,
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    dynamic options,
  }) async {
    if (_mockError != null) throw _mockError!;
    return ApiResponse<T>(
      status: _mockResponse!.status,
      data: _mockResponse!.data as T?,
      code: _mockResponse!.code,
      msg: _mockResponse!.msg,
    );
  }
}

void main() {
  group('VideoRepository', () {
    late VideoRepository videoRepository;
    late TestApiClient testApiClient;

    setUp(() {
      testApiClient = TestApiClient();
      videoRepository = VideoRepository(apiClient: testApiClient);
    });

    group('getRecommendedVideos', () {
      test('should return list of recommended videos when API succeeds', () async {
        // Arrange
        final mockData = {
          'list': [
            {'id': 1, 'bvid': 'BV1xx411c7mD', 'title': 'Video 1', 'owner': {'mid': 1, 'name': 'User1', 'face': ''}, 'stat': {'view': 100, 'like': 10, 'danmu': 5}},
            {'id': 2, 'bvid': 'BV2xx411c7mD', 'title': 'Video 2', 'owner': {'mid': 2, 'name': 'User2', 'face': ''}, 'stat': {'view': 200, 'like': 20, 'danmu': 10}},
          ],
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await videoRepository.getRecommendedVideos();

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
      });

      test('should return error when API fails', () async {
        // Arrange
        testApiClient.setMockResponse(ApiResponse.error(msg: 'Network error'));

        // Act
        final result = await videoRepository.getRecommendedVideos();

        // Assert
        expect(result.status, false);
        expect(result.msg, 'Network error');
      });
    });

    group('getHotVideos', () {
      test('should return list of hot videos when API succeeds', () async {
        // Arrange
        final mockData = {
          'list': [
            {'aid': 1, 'bvid': 'BV1xx411c7mD', 'title': 'Hot Video 1', 'owner': {'mid': 1, 'name': 'User1', 'face': ''}, 'stat': {'aid': 1, 'view': 100, 'danmaku': 5, 'reply': 2, 'favorite': 10, 'coin': 3, 'share': 1, 'now_rank': 0, 'his_rank': 0, 'like': 10, 'dislike': 0, 'vt': 0, 'vv': 0}, 'dimension': {'width': 1920, 'height': 1080, 'rotate': 0}},
            {'aid': 2, 'bvid': 'BV2xx411c7mD', 'title': 'Hot Video 2', 'owner': {'mid': 2, 'name': 'User2', 'face': ''}, 'stat': {'aid': 2, 'view': 200, 'danmaku': 10, 'reply': 4, 'favorite': 20, 'coin': 6, 'share': 2, 'now_rank': 0, 'his_rank': 0, 'like': 20, 'dislike': 0, 'vt': 0, 'vv': 0}, 'dimension': {'width': 1920, 'height': 1080, 'rotate': 0}},
          ],
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await videoRepository.getHotVideos();

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
      });
    });

    group('getVideoDetail', () {
      test('should return video detail when API succeeds', () async {
        // Arrange
        final mockData = {
          'bvid': 'BV1xx411c7mD',
          'aid': 12345,
          'cid': 12345,
          'title': 'Test Video',
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await videoRepository.getVideoDetail(bvid: 'BV1xx411c7mD');

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
      });
    });
  });
}
