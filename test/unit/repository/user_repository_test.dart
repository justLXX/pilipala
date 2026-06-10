import 'package:flutter_test/flutter_test.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/features/user/data/user_repository.dart';
import 'package:pilipala/models/user/info.dart';

import '../../helpers/test_data_factory.dart';

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
  group('UserRepository', () {
    late UserRepository userRepository;
    late TestApiClient testApiClient;

    setUp(() {
      testApiClient = TestApiClient();
      userRepository = UserRepository(apiClient: testApiClient);
    });

    group('getUserInfo', () {
      test('should return user info when API succeeds', () async {
        // Arrange
        final mockData = {
          'mid': 12345,
          'uname': 'TestUser',
          'face': 'https://example.com/face.jpg',
          'level_info': {'current_level': 5},
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await userRepository.getUserInfo(mid: 12345);

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
        expect(result.data!.mid, 12345);
      });

      test('should return error when API fails', () async {
        // Arrange
        testApiClient.setMockResponse(ApiResponse.error(msg: 'User not found'));

        // Act
        final result = await userRepository.getUserInfo(mid: 12345);

        // Assert
        expect(result.status, false);
        expect(result.msg, 'User not found');
      });
    });

    group('getUserStat', () {
      test('should return user statistics when API succeeds', () async {
        // Arrange
        final mockData = {
          'following': 100,
          'follower': 200,
          'dynamic_count': 50,
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await userRepository.getUserStat(mid: 12345);

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
      });
    });

    group('followUser', () {
      test('should follow user when API succeeds', () async {
        // Arrange
        testApiClient.setMockResponse(ApiResponse.success({}));

        // Act
        final result = await userRepository.followUser(mid: 12345, follow: true);

        // Assert
        expect(result.status, true);
      });
    });
  });
}
