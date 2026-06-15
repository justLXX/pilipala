import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'login_controller.dart';

/// LoginPage - 重构版登录页面
///
/// 支持手机号+密码/验证码登录和二维码登录
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginCtr = Get.find<LoginController>();
  Future<Map<String, dynamic>?>? _qrCodeFuture;

  void _refreshQrCode() {
    _loginCtr.validTimer?.cancel();
    setState(() {
      _qrCodeFuture = _loginCtr.getWebQrcode();
    });
  }

  @override
  void dispose() {
    // Controller 的 onClose 会处理 timer 和 controller 的清理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Navigator.of(context).maybePop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Obx(
            () => _loginCtr.currentIndex.value == 0
                ? IconButton(
                    onPressed: () => _back(context),
                    icon: const Icon(Icons.close_outlined),
                  )
                : IconButton(
                    onPressed: () => _loginCtr.previousPage(),
                    icon: const Icon(Icons.arrow_back),
                  ),
          ),
          actions: [
            IconButton(
              tooltip: '浏览器打开',
              onPressed: () {
                Get.offNamed(
                  '/webview',
                  parameters: {
                    'url':
                        'https://passport.bilibili.com/h5-app/passport/login',
                    'type': 'login',
                    'pageTitle': '登录bilibili',
                  },
                );
              },
              icon: const Icon(Icons.language, size: 20),
            ),
            IconButton(
              tooltip: '二维码登录',
              onPressed: () => _showQrCodeDialog(context),
              icon: const Icon(Icons.qr_code, size: 20),
            ),
            const SizedBox(width: 22),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _loginCtr.pageViewController,
          onPageChanged: (int index) => _loginCtr.onPageChange(index),
          children: [
            _buildPhoneInputPage(context),
            _buildLoginPage(context),
          ],
        ),
      ),
    );
  }

  /// 手机号输入页
  Widget _buildPhoneInputPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Form(
        key: _loginCtr.mobFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              '登录',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  height: 2.1,
                  fontSize: 34,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1),
            ),
            Text(
              '请使用您的 BiliBili 账号登录。',
              style: Theme.of(context).textTheme.titleSmall!,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showQrCodeDialog(context),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('扫码登录'),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '或',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: 16, bottom: 15),
              child: TextFormField(
                controller: _loginCtr.mobTextController,
                focusNode: _loginCtr.mobTextFieldNode,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: '输入手机号码',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                validator: (v) {
                  return v!.trim().isNotEmpty ? null : "手机号码不能为空";
                },
                onSaved: (val) => _loginCtr.tel = int.parse(val!),
                onEditingComplete: () {
                  _loginCtr.nextStep();
                },
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _back(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回'),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => _loginCtr.nextStep(),
                  child: const Text('下一步'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 登录方式页 (密码/验证码)
  Widget _buildLoginPage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Obx(
        () => _loginCtr.loginType.value == 0
            ? _buildPasswordForm(context)
            : _buildSmsCodeForm(context),
      ),
    );
  }

  /// 密码登录表单
  Widget _buildPasswordForm(BuildContext context) {
    return Form(
      key: _loginCtr.passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Text(
                '密码登录',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    height: 2.1,
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1),
              ),
              const SizedBox(width: 4),
              IconButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    return Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1);
                  }),
                ),
                onPressed: () => _loginCtr.changeLoginType(),
                icon: const Icon(Icons.swap_vert_outlined),
              )
            ],
          ),
          Text(
            '请输入您的 BiliBili 密码。',
            style: Theme.of(context).textTheme.titleSmall!,
          ),
          Container(
            margin: const EdgeInsets.only(top: 38, bottom: 15),
            child: Obx(() => TextFormField(
                  controller: _loginCtr.passwordTextController,
                  focusNode: _loginCtr.passwordTextFieldNode,
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: _loginCtr.passwordVisible.value,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: '输入密码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _loginCtr.passwordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        _loginCtr.passwordVisible.value =
                            !_loginCtr.passwordVisible.value;
                      },
                    ),
                  ),
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "密码不能为空";
                  },
                )),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _back(context),
                child: const Text('返回'),
              ),
              TextButton(
                onPressed: () => _loginCtr.previousPage(),
                child: const Text('上一步'),
              ),
              const SizedBox(width: 15),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _loginCtr.loginByWebPassword(),
                child: const Text('确认登录'),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// 验证码登录表单
  Widget _buildSmsCodeForm(BuildContext context) {
    return Form(
      key: _loginCtr.msgCodeFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Text(
                '验证码登录',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    height: 2.1,
                    fontSize: 34,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1),
              ),
              const SizedBox(width: 4),
              IconButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    return Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1);
                  }),
                ),
                onPressed: () => _loginCtr.changeLoginType(),
                icon: const Icon(Icons.swap_vert_outlined),
              )
            ],
          ),
          Text(
            '请输入收到的验证码。',
            style: Theme.of(context).textTheme.titleSmall!,
          ),
          Container(
            margin: const EdgeInsets.only(top: 38, bottom: 15),
            child: Stack(
              children: [
                TextFormField(
                  controller: _loginCtr.msgCodeTextController,
                  focusNode: _loginCtr.msgCodeTextFieldNode,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: '输入验证码',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                  ),
                  validator: (v) {
                    return v!.trim().isNotEmpty ? null : "验证码不能为空";
                  },
                  onSaved: (val) => _loginCtr.webSmsCode = int.parse(val!),
                ),
                Obx(() {
                  return Positioned(
                    right: 8,
                    top: 0,
                    child: Center(
                      child: TextButton(
                          onPressed: _loginCtr.smsCodeSendStatus.value
                              ? null
                              : () => _loginCtr.getWebMsgCode(),
                          child: _loginCtr.smsCodeSendStatus.value
                              ? Text('重新获取(${_loginCtr.seconds.value}s)')
                              : const Text('获取验证码')),
                    ),
                  );
                })
              ],
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _back(context),
                child: const Text('返回'),
              ),
              TextButton(
                onPressed: () => _loginCtr.previousPage(),
                child: const Text('上一步'),
              ),
              const SizedBox(width: 15),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _loginCtr.loginByCode(),
                child: const Text('确认登录'),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// 二维码登录弹窗
  void _showQrCodeDialog(BuildContext context) {
    _refreshQrCode();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                const Text('扫码登录'),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _loginCtr.validTimer?.cancel();
                    setDialogState(() {
                      _qrCodeFuture = _loginCtr.getWebQrcode();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            content: SizedBox(
              width: 260,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: FutureBuilder(
                          future: _qrCodeFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.data == null) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '二维码获取失败',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton.icon(
                                        onPressed: () {
                                          setDialogState(() {
                                            _qrCodeFuture =
                                                _loginCtr.getWebQrcode();
                                          });
                                        },
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('重新获取'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              final Map data = snapshot.data as Map;
                              if (data['status'] != true) {
                                return Center(
                                  child: Text(
                                    data['msg']?.toString() ?? '二维码获取失败',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              final url = data['data']?['url']?.toString();
                              if (url == null || url.isEmpty) {
                                return const Center(
                                  child: Text(
                                    '二维码地址为空',
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                );
                              }
                              return QrImageView(
                                data: url,
                                backgroundColor: Colors.white,
                              );
                            }
                            return const Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '请使用哔哩哔哩客户端扫码确认登录',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              Obx(() {
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '有效期: ${_loginCtr.validSeconds.value}s',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                );
              }),
              TextButton.icon(
                onPressed: () async {
                  final data = await _qrCodeFuture;
                  if (data != null) {
                    await _loginCtr.queryWebQrcodeStatus();
                  }
                },
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('检查状态'),
              )
            ],
          );
        });
      },
    ).then((value) {
      _loginCtr.validTimer?.cancel();
    });
  }

  void _back(BuildContext context) {
    _loginCtr.mobTextFieldNode.unfocus();
    _loginCtr.passwordTextFieldNode.unfocus();
    _loginCtr.msgCodeTextFieldNode.unfocus();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed('/');
    }
  }
}
