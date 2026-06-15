import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 安全的返回导航方法，兼容 macOS 等桌面平台
/// Get.back() 在 macOS 上可能不生效，需要使用 Navigator.of(context).pop()
void safeBack({BuildContext? context, dynamic result}) {
  final currentContext = context ?? Get.context;
  if (currentContext != null) {
    final navigator = Navigator.of(currentContext, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop(result);
      return;
    }
  }

  final navigatorState = Get.key.currentState;
  if (navigatorState != null && navigatorState.canPop()) {
    navigatorState.pop(result);
    return;
  }

  // 兜底：如果无法 pop，则跳回首页
  Get.offAllNamed('/');
}
