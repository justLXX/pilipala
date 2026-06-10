// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'dart:convert';

/// API 请求日志拦截器
/// 输出每个接口的请求地址、响应状态码、业务 code/message 以及数据摘要
class ApiLogInterceptor extends Interceptor {
  /// 排除的 URL 匹配模式（如心跳、流媒体等高频接口）
  final String excludePattern;

  ApiLogInterceptor({
    this.excludePattern =
        r'heartbeat|seg\.so|online/total|datapb|\.m3u8|\.flv|live_url',
  });

  bool _shouldExclude(String url) => RegExp(excludePattern).hasMatch(url);

  String _shortUrl(String url) {
    if (url.length > 120) return '${url.substring(0, 120)}...';
    return url;
  }

  String _formatData(dynamic data) {
    try {
      final String raw = data is String ? data : const JsonEncoder.withIndent('  ').convert(data);
      return raw;
    } catch (_) {
      return data.toString();
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_shouldExclude(options.uri.toString())) {
      print('┌──────── API Request ────────');
      print('│ ${options.method} ${_shortUrl(options.uri.toString())}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final String url = response.requestOptions.uri.toString();
    if (!_shouldExclude(url)) {
      final int? statusCode = response.statusCode;
      dynamic data = response.data;

      String bizCode = '-';
      String bizMsg = '-';
      if (data is Map<String, dynamic>) {
        bizCode = data['code']?.toString() ?? '-';
        bizMsg = data['message']?.toString() ?? '-';
      }

      print('├──────── API Response ───────');
      print('│ ${response.requestOptions.method} ${_shortUrl(url)}');
      print('│ HTTP $statusCode | code=$bizCode | msg=$bizMsg');
      print('│ data:');
      print(_formatData(data));
      print('└─────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String url = err.requestOptions.uri.toString();
    if (!_shouldExclude(url)) {
      print('├──────── API Error ──────────');
      print('│ ${err.requestOptions.method} ${_shortUrl(url)}');
      print('│ type: ${err.type}');
      print('│ message: ${err.message}');
      if (err.response != null) {
        print('│ HTTP ${err.response?.statusCode}');
        print('│ data:');
        print(_formatData(err.response?.data));
      }
      print('└─────────────────────────────');
    }
    handler.next(err);
  }
}
