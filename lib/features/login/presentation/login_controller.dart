import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:gt3_flutter_plugin/gt3_flutter_plugin.dart';
import 'package:pilipala/features/login/domain/login_use_cases.dart';
import 'package:pilipala/models/login/index.dart';
import 'package:pilipala/utils/login.dart';

/// Controller for the login feature.
///
/// Manages the full login flow: phone input, password/SMS code login,
/// QR code login, and geetest captcha integration.
class LoginController extends GetxController {
  // Dependencies
  late final GetCaptchaUseCase _getCaptcha;
  late final GetWebKeyUseCase _getWebKey;
  late final EncryptPasswordUseCase _encryptPassword;
  late final LoginByPasswordUseCase _loginByPassword;
  late final LoginBySmsCodeUseCase _loginBySmsCode;
  late final SendSmsCodeUseCase _sendSmsCode;
  late final QrCodeLoginUseCase _qrCodeLogin;

  // Form keys
  final GlobalKey mobFormKey = GlobalKey<FormState>();
  final GlobalKey passwordFormKey = GlobalKey<FormState>();
  final GlobalKey msgCodeFormKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController mobTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final TextEditingController msgCodeTextController = TextEditingController();

  // Focus nodes
  final FocusNode mobTextFieldNode = FocusNode();
  final FocusNode passwordTextFieldNode = FocusNode();
  final FocusNode msgCodeTextFieldNode = FocusNode();

  // Page control
  final PageController pageViewController = PageController();
  RxInt currentIndex = 0.obs;

  // Geetest captcha
  final Gt3FlutterPlugin captcha = Gt3FlutterPlugin();

  // SMS countdown
  RxInt seconds = 60.obs;
  Timer? timer;
  RxBool smsCodeSendStatus = false.obs;

  // Login type: 0 = password, 1 = SMS code
  RxInt loginType = 0.obs;

  // Captcha data
  late String captchaKey;

  // Phone number
  late int tel;
  late int webSmsCode;

  // QR code
  RxInt validSeconds = 180.obs;
  Timer? validTimer;
  late String qrcodeKey;

  // Password visibility
  RxBool passwordVisible = false.obs;

  // Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  LoginController({
    GetCaptchaUseCase? getCaptcha,
    GetWebKeyUseCase? getWebKey,
    EncryptPasswordUseCase? encryptPassword,
    LoginByPasswordUseCase? loginByPassword,
    LoginBySmsCodeUseCase? loginBySmsCode,
    SendSmsCodeUseCase? sendSmsCode,
    QrCodeLoginUseCase? qrCodeLogin,
  }) {
    _getCaptcha = getCaptcha ?? GetCaptchaUseCase();
    _getWebKey = getWebKey ?? GetWebKeyUseCase();
    _encryptPassword = encryptPassword ?? EncryptPasswordUseCase();
    _loginByPassword = loginByPassword ?? LoginByPasswordUseCase();
    _loginBySmsCode = loginBySmsCode ?? LoginBySmsCodeUseCase();
    _sendSmsCode = sendSmsCode ?? SendSmsCodeUseCase();
    _qrCodeLogin = qrCodeLogin ?? QrCodeLoginUseCase();
  }

  @override
  void onClose() {
    timer?.cancel();
    validTimer?.cancel();
    mobTextController.dispose();
    passwordTextController.dispose();
    msgCodeTextController.dispose();
    mobTextFieldNode.dispose();
    passwordTextFieldNode.dispose();
    msgCodeTextFieldNode.dispose();
    pageViewController.dispose();
    super.onClose();
  }

  // Page navigation
  void onPageChange(int index) {
    currentIndex.value = index;
  }

  void nextStep() async {
    if ((mobFormKey.currentState as FormState).validate()) {
      await pageViewController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      passwordTextFieldNode.requestFocus();
      (mobFormKey.currentState as FormState).save();
    }
  }

  void previousPage() async {
    passwordTextFieldNode.unfocus();
    await Future.delayed(const Duration(milliseconds: 200));
    pageViewController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void changeLoginType() {
    loginType.value = loginType.value == 0 ? 1 : 0;
    if (loginType.value == 0) {
      passwordTextFieldNode.requestFocus();
    } else {
      msgCodeTextFieldNode.requestFocus();
    }
  }

  // Geetest captcha
  Future<void> requestCaptcha(Function(CaptchaDataModel) onCaptchaReady) async {
    SmartDialog.showLoading(msg: '请求中...');
    var result = await _getCaptcha.execute();
    SmartDialog.dismiss();
    if (result['status']) {
      CaptchaDataModel captchaData = result['data'];
      var registerData = Gt3RegisterData(
        challenge: captchaData.geetest!.challenge,
        gt: captchaData.geetest!.gt!,
        success: true,
      );
      captcha.addEventHandler(
        onShow: (Map<String, dynamic> message) async {
          SmartDialog.dismiss();
        },
        onClose: (Map<String, dynamic> message) async {
          SmartDialog.showToast('取消验证');
        },
        onResult: (Map<String, dynamic> message) async {
          String code = message["code"];
          if (code == "1") {
            SmartDialog.showToast('验证成功');
            captchaData.validate = message['result']['geetest_validate'];
            captchaData.seccode = message['result']['geetest_seccode'];
            captchaData.geetest!.challenge =
                message['result']['geetest_challenge'];
            onCaptchaReady(captchaData);
          }
        },
        onError: (Map<String, dynamic> message) async {
          String code = message["code"];
          debugPrint("Captcha error code: $code");
        },
      );
      captcha.startCaptcha(registerData);
    } else {
      SmartDialog.showToast(result['msg'] ?? '获取验证码失败');
    }
  }

  // Web password login
  void loginByWebPassword() async {
    if (!(passwordFormKey.currentState as FormState).validate()) return;

    requestCaptcha((captchaData) async {
      var webKeyRes = await _getWebKey.execute();
      if (webKeyRes['status']) {
        String rhash = webKeyRes['data']['hash'];
        String key = webKeyRes['data']['key'];
        String passwordEncrypted = _encryptPassword.execute(
          rhash: rhash,
          password: passwordTextController.text,
          publicKeyPem: key,
        );
        var res = await _loginByPassword.execute(
          username: tel,
          password: passwordEncrypted,
          token: captchaData.token!,
          challenge: captchaData.geetest!.challenge!,
          validate: captchaData.validate!,
          seccode: captchaData.seccode!,
        );
        if (res['status']) {
          await LoginUtils.confirmLogin('', null);
        } else {
          SmartDialog.showToast(res['msg'] ?? '登录失败');
          if (res.containsKey('code') && res['code'] == 1) {
            Get.toNamed('/webview', parameters: {
              'url': res['data']['data']['url'],
              'type': 'url',
              'pageTitle': '登录验证',
            });
          }
        }
      } else {
        SmartDialog.showToast(webKeyRes['msg'] ?? '获取密钥失败');
      }
    });
  }

  // Get web SMS code
  void getWebMsgCode() async {
    requestCaptcha((captchaData) async {
      var res = await _sendSmsCode.execute(
        cid: 86,
        tel: tel,
        token: captchaData.token!,
        challenge: captchaData.geetest!.challenge!,
        validate: captchaData.validate!,
        seccode: captchaData.seccode!,
      );
      if (res['status']) {
        captchaKey = res['data']['captcha_key'];
        SmartDialog.showToast('验证码已发送');
        smsCodeSendStatus.value = true;
        startTimer();
      } else {
        SmartDialog.showToast(res['msg'] ?? '发送验证码失败');
      }
    });
  }

  // Login by SMS code
  void loginByCode() async {
    if (!(msgCodeFormKey.currentState as FormState).validate()) return;
    (msgCodeFormKey.currentState as FormState).save();
    var res = await _loginBySmsCode.execute(
      cid: 86,
      tel: tel,
      code: webSmsCode,
      captchaKey: captchaKey,
    );
    if (res['status']) {
      await LoginUtils.confirmLogin('', null);
    } else {
      SmartDialog.showToast(res['msg'] ?? '登录失败');
    }
  }

  // SMS countdown
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value > 0) {
        seconds.value--;
      } else {
        seconds.value = 60;
        smsCodeSendStatus.value = false;
        timer.cancel();
      }
    });
  }

  // QR code login
  Future<Map<String, dynamic>?> getWebQrcode() async {
    var res = await _qrCodeLogin.getQrCode();
    validSeconds.value = 180;
    if (res['status']) {
      qrcodeKey = res['data']['qrcode_key'];
      validTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (validSeconds.value > 0) {
          validSeconds.value--;
          queryWebQrcodeStatus();
        } else {
          getWebQrcode();
          timer.cancel();
        }
      });
      return res;
    } else {
      SmartDialog.showToast(res['msg'] ?? '获取二维码失败');
      return null;
    }
  }

  Future<void> queryWebQrcodeStatus() async {
    var res = await _qrCodeLogin.checkStatus(qrcodeKey);
    if (res['status']) {
      await LoginUtils.confirmLogin('', null);
      validTimer?.cancel();
      Get.back();
    }
  }
}
