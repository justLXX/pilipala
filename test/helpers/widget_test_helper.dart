import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Widget test helper for wrapping widgets with necessary dependencies.
class WidgetTestHelper {
  /// Wrap a widget with MaterialApp and GetX.
  static Widget wrapWithMaterial(Widget child) {
    return GetMaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Wrap a widget with GetMaterialApp.
  static Widget wrapWithGetX(Widget child) {
    return GetMaterialApp(
      home: Scaffold(body: child),
    );
  }

  /// Wait for async operations to complete.
  static Future<void> pumpAndSettle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  /// Set screen size for testing.
  static Future<void> setScreenSize(
    WidgetTester tester, {
    double width = 375,
    double height = 812,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.physicalSize = Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
    });
  }
}
