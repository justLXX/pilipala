import 'package:get/get.dart';
import 'package:pilipala/features/login/data/login_repository.dart';

/// Use case for getting captcha.
class GetCaptchaUseCase {
  final LoginRepository _repository;

  GetCaptchaUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  Future<Map<String, dynamic>> execute() async {
    return await _repository.getCaptcha();
  }
}

/// Use case for web password login.
class LoginByPasswordUseCase {
  final LoginRepository _repository;

  LoginByPasswordUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  Future<Map<String, dynamic>> execute({
    required int username,
    required String password,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    return await _repository.loginByWebPwd(
      username: username,
      password: password,
      token: token,
      challenge: challenge,
      validate: validate,
      seccode: seccode,
    );
  }
}

/// Use case for SMS code login.
class LoginBySmsCodeUseCase {
  final LoginRepository _repository;

  LoginBySmsCodeUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  Future<Map<String, dynamic>> execute({
    int? cid,
    required int tel,
    required int code,
    required String captchaKey,
  }) async {
    return await _repository.loginByWebSmsCode(
      cid: cid,
      tel: tel,
      code: code,
      captchaKey: captchaKey,
    );
  }
}

/// Use case for sending SMS code.
class SendSmsCodeUseCase {
  final LoginRepository _repository;

  SendSmsCodeUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  Future<Map<String, dynamic>> execute({
    int? cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    return await _repository.sendWebSmsCode(
      cid: cid,
      tel: tel,
      token: token,
      challenge: challenge,
      validate: validate,
      seccode: seccode,
    );
  }
}

/// Use case for QR code login.
class QrCodeLoginUseCase {
  final LoginRepository _repository;

  QrCodeLoginUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  Future<Map<String, dynamic>> getQrCode() async {
    return await _repository.getQrCode();
  }

  Future<Map<String, dynamic>> checkStatus(String qrcodeKey) async {
    return await _repository.checkQrCodeStatus(qrcodeKey);
  }
}

/// Use case for getting web key (RSA public key).
class GetWebKeyUseCase {
  final LoginRepository _repository;

  GetWebKeyUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  Future<Map<String, dynamic>> execute() async {
    return await _repository.getWebKey();
  }
}

/// Use case for password encryption.
class EncryptPasswordUseCase {
  final LoginRepository _repository;

  EncryptPasswordUseCase({LoginRepository? repository})
      : _repository = repository ?? Get.find<LoginRepository>();

  String execute({
    required String rhash,
    required String password,
    required String publicKeyPem,
  }) {
    return _repository.encryptPassword(rhash, password, publicKeyPem);
  }
}
