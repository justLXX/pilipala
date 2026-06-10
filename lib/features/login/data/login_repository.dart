import 'package:dio/dio.dart' as dio;
import 'package:encrypt/encrypt.dart';
import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/constants.dart';
import 'package:pilipala/models/login/index.dart';
import 'package:pilipala/utils/login.dart';

/// LoginRepository provides a clean interface for login-related data operations.
class LoginRepository {
  final ApiClient _apiClient;

  LoginRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  /// Get captcha for login (极验验证码).
  Future<Map<String, dynamic>> getCaptcha() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.getCaptcha,
    );

    if (response.isSuccess && response.data != null) {
      return {
        'status': true,
        'data': CaptchaDataModel.fromJson(response.data!),
      };
    }
    return {'status': false, 'msg': response.msg ?? '获取验证码失败'};
  }

  /// Get web key (salt hash & PubKey for password encryption).
  Future<Map<String, dynamic>> getWebKey() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.getWebKey,
      queryParameters: {
        'disable_rcmd': 0,
        'local_id': LoginUtils.generateBuvid(),
      },
    );

    if (response.isSuccess && response.data != null) {
      return {'status': true, 'data': response.data};
    }
    return {'status': false, 'msg': response.msg ?? '获取密钥失败'};
  }

  /// Login with web password (RSA encrypted).
  Future<Map<String, dynamic>> loginByWebPwd({
    required int username,
    required String password,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.loginInByWebPwd,
      data: dio.FormData.fromMap({
        'username': username,
        'password': password,
        'keep': 0,
        'token': token,
        'challenge': challenge,
        'validate': validate,
        'seccode': seccode,
        'source': 'main-fe-header',
        'go_url': HttpString.baseUrl,
      }),
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!;
      if (data['status'] == 0) {
        return {'status': true, 'data': data};
      } else {
        return {
          'status': false,
          'code': 1,
          'data': data,
          'msg': data['message'] ?? '登录失败',
        };
      }
    }
    return {
      'status': false,
      'msg': response.msg ?? '登录失败',
    };
  }

  /// Login by web SMS code.
  Future<Map<String, dynamic>> loginByWebSmsCode({
    int? cid,
    required int tel,
    required int code,
    required String captchaKey,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.webSmsLogin,
      data: dio.FormData.fromMap({
        'cid': cid,
        'tel': tel,
        'code': code,
        'source': 'main_mini',
        'keep': 0,
        'captcha_key': captchaKey,
        'go_url': HttpString.baseUrl,
      }),
    );

    if (response.isSuccess && response.data != null) {
      return {'status': true, 'data': response.data};
    }
    return {
      'status': false,
      'msg': response.msg ?? '登录失败',
    };
  }

  /// Send web SMS code.
  Future<Map<String, dynamic>> sendWebSmsCode({
    int? cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      Api.webSmsCode,
      data: dio.FormData.fromMap({
        'cid': cid,
        'tel': tel,
        'source': 'main_web',
        'token': token,
        'challenge': challenge,
        'validate': validate,
        'seccode': seccode,
      }),
    );

    if (response.isSuccess && response.data != null) {
      return {'status': true, 'data': response.data};
    }
    return {
      'status': false,
      'msg': response.msg ?? '发送验证码失败',
    };
  }

  /// Get login QR code.
  Future<Map<String, dynamic>> getQrCode() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.qrCodeApi,
    );

    if (response.isSuccess && response.data != null) {
      return {'status': true, 'data': response.data};
    }
    return {
      'status': false,
      'msg': response.msg ?? '获取二维码失败',
    };
  }

  /// Check QR code login status.
  Future<Map<String, dynamic>> checkQrCodeStatus(String qrcodeKey) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Api.loginInByQrcode,
      queryParameters: {'qrcode_key': qrcodeKey},
    );

    if (response.isSuccess) {
      final data = response.data;
      if (data != null && data['code'] == 0) {
        return {'status': true, 'data': data};
      }
    }
    return {'status': false, 'msg': response.msg ?? '二维码已过期'};
  }

  /// Encrypt password with RSA public key.
  String encryptPassword(String rhash, String password, String publicKeyPem) {
    dynamic publicKey = RSAKeyParser().parse(publicKeyPem);
    return Encrypter(RSA(publicKey: publicKey))
        .encrypt(rhash + password)
        .base64;
  }
}
