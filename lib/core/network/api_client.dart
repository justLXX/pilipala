import 'package:dio/dio.dart';
import 'package:pilipala/http/api_log_interceptor.dart';
import 'package:pilipala/http/init.dart';

/// ApiClient provides a clean interface for HTTP requests.
///
/// This abstraction wraps the Request singleton and provides:
/// - Type-safe request methods
/// - Consistent error handling
/// - Testable interface
abstract class ApiClient {
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  });
}

/// Standardized API response wrapper.
///
/// All API responses follow this format:
/// ```
/// {
///   'status': bool,    // Business status
///   'data': T,         // Response data
///   'code': int,       // HTTP status code
///   'msg': String?     // Error message
/// }
/// ```
class ApiResponse<T> {
  final bool status;
  final T? data;
  final int code;
  final String? msg;

  ApiResponse({
    required this.status,
    this.data,
    required this.code,
    this.msg,
  });

  /// Creates a success response.
  factory ApiResponse.success(T data, {int code = 200}) {
    return ApiResponse(status: true, data: data, code: code);
  }

  /// Creates an error response.
  factory ApiResponse.error({String? msg, int code = -1}) {
    return ApiResponse(status: false, code: code, msg: msg);
  }

  bool get isSuccess => status && code == 200;
  bool get isError => !status || code != 200;
}

/// Implementation of ApiClient using Dio.
class DioApiClient implements ApiClient {
  final Dio _dio;

  DioApiClient({Dio? dio}) : _dio = dio ?? Request.dio {
    // 为 ApiClient 实例也添加日志拦截器（如果尚未添加）
    final hasLogInterceptor =
        _dio.interceptors.any((i) => i is ApiLogInterceptor);
    if (!hasLogInterceptor) {
      _dio.interceptors.add(ApiLogInterceptor());
    }
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final code = data['code'] as int? ?? -1;
        final message = data['message'] as String?;

        if (code == 0) {
          return ApiResponse.success(data['data'] as T, code: 200);
        } else {
          return ApiResponse.error(msg: message ?? 'Unknown error', code: code);
        }
      }

      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return ApiResponse.error(
        msg: e.message ?? 'Network error',
        code: e.response?.statusCode ?? -1,
      );
    } catch (e) {
      return ApiResponse.error(msg: e.toString());
    }
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: options,
      );

      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        final code = responseData['code'] as int? ?? -1;
        final message = responseData['message'] as String?;

        if (code == 0) {
          return ApiResponse.success(responseData['data'] as T, code: 200);
        } else {
          return ApiResponse.error(
            msg: message ?? 'Unknown error',
            code: code,
          );
        }
      }

      return ApiResponse.success(response.data as T);
    } on DioException catch (e) {
      return ApiResponse.error(
        msg: e.message ?? 'Network error',
        code: e.response?.statusCode ?? -1,
      );
    } catch (e) {
      return ApiResponse.error(msg: e.toString());
    }
  }
}
