import 'package:flutter_test/flutter_test.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/features/search/data/search_repository.dart';


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
  group('SearchRepository', () {
    late SearchRepository searchRepository;
    late TestApiClient testApiClient;

    setUp(() {
      testApiClient = TestApiClient();
      searchRepository = SearchRepository(apiClient: testApiClient);
    });

    group('getHotSearchList', () {
      test('should return hot search list when API succeeds', () async {
        // Arrange
        final mockData = {
          'list': [
            {'keyword': 'Flutter', 'show_name': '1', 'word_type': 1, 'icon': '0'},
            {'keyword': 'Dart', 'show_name': '2', 'word_type': 2, 'icon': '0'},
          ],
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await searchRepository.getHotSearchList();

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
        expect(result.data!.length, 2);
      });

      test('should return error when API fails', () async {
        // Arrange
        testApiClient.setMockResponse(ApiResponse.error(msg: 'Network error'));

        // Act
        final result = await searchRepository.getHotSearchList();

        // Assert
        expect(result.status, false);
        expect(result.msg, 'Network error');
      });
    });

    group('search', () {
      test('should return search results when API succeeds', () async {
        // Arrange
        final mockData = {
          'numResults': 100,
          'numPages': 10,
          'result': [
            {'title': 'Flutter Tutorial', 'bvid': 'BV1xx411c7mD'},
            {'title': 'Dart Basics', 'bvid': 'BV2xx411c7mD'},
          ],
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await searchRepository.search(
          keyword: 'Flutter',
          searchType: 'video',
        );

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
      });
    });

    group('getSearchSuggestions', () {
      test('should return search suggestions when API succeeds', () async {
        // Arrange
        final mockData = {
          'result': [
            {'term': 'Flutter'},
            {'term': 'Flutter Tutorial'},
            {'term': 'Flutter Widget'},
          ],
        };

        testApiClient.setMockResponse(ApiResponse.success(mockData));

        // Act
        final result = await searchRepository.getSearchSuggestions('Flut');

        // Assert
        expect(result.status, true);
        expect(result.data, isNotNull);
        expect(result.data!.length, 3);
      });
    });
  });
}
