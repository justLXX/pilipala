import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 安全的返回导航方法，兼容 macOS 等桌面平台
/// Get.back() 在 macOS 上可能不生效，需要使用 Navigator.of(context).pop()
void safeBack({dynamic result}) {
  final context = Get.context;
  if (context != null && Navigator.of(context).canPop()) {
    Navigator.of(context).pop(result);
  } else {
    // 兜底：如果无法 pop，则跳回首页
    Get.offAllNamed('/');
  }
}
