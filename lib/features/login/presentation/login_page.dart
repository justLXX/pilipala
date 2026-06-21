import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController _loginCtr = Get.find<LoginController>();
  Future<Map<String, dynamic>?>? _qrCodeFuture;

  @override
  void initState() {
    super.initState();
    _refreshQrCode();
  }

  @override
  void dispose() {
    _loginCtr.validTimer?.cancel();
    super.dispose();
  }

  void _refreshQrCode() {
    _loginCtr.validTimer?.cancel();
    setState(() {
      _qrCodeFuture = _loginCtr.getWebQrcode();
    });
  }

  void _openWebLogin() {
    _loginCtr.validTimer?.cancel();
    Get.offNamed(
      '/webview',
      parameters: {
        'url': 'https://passport.bilibili.com/h5-app/passport/login',
        'type': 'login',
        'pageTitle': '登录bilibili',
      },
    );
  }

  void _back(BuildContext context) {
    _loginCtr.validTimer?.cancel();
    _loginCtr.mobTextFieldNode.unfocus();
    _loginCtr.passwordTextFieldNode.unfocus();
    _loginCtr.msgCodeTextFieldNode.unfocus();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.offAllNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _back(context);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => _back(context),
            icon: const Icon(Icons.close_outlined),
          ),
          title: const Text('登录'),
          actions: [
            TextButton.icon(
              onPressed: _openWebLogin,
              icon: const Icon(Icons.language, size: 18),
              label: const Text('网页登录'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '扫码登录',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请使用哔哩哔哩客户端扫码确认登录',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 28),
                    _QrCodeCard(
                      future: _qrCodeFuture,
                      onRefresh: _refreshQrCode,
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => Text(
                        '二维码有效期：${_loginCtr.validSeconds.value}s',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: _openWebLogin,
                      icon: const Icon(Icons.language, size: 18),
                      label: const Text('使用网页登录'),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _refreshQrCode,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('刷新二维码'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrCodeCard extends StatelessWidget {
  const _QrCodeCard({
    required this.future,
    required this.onRefresh,
  });

  final Future<Map<String, dynamic>?>? future;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.42),
        borderRadius: StyleString.lgRadius,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(StyleString.imgRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: FutureBuilder<Map<String, dynamic>?>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data;
                  if (data == null || data['status'] != true) {
                    return _QrError(
                      message: data?['msg']?.toString() ?? '二维码获取失败',
                      onRefresh: onRefresh,
                    );
                  }
                  final url = data['data']?['url']?.toString();
                  if (url == null || url.isEmpty) {
                    return _QrError(
                      message: '二维码地址为空',
                      onRefresh: onRefresh,
                    );
                  }
                  return QrImageView(
                    data: url,
                    backgroundColor: Colors.white,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrError extends StatelessWidget {
  const _QrError({
    required this.message,
    required this.onRefresh,
  });

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xDD000000)),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('重新获取'),
          ),
        ],
      ),
    );
  }
}
