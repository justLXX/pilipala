import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/models/common/theme_type.dart';

/// ThemeService manages application theme settings.
///
/// Provides a centralized way to:
/// - Get/set theme mode
/// - Get/set custom color
/// - Get/set dynamic color preference
class ThemeService extends GetxService {
  static ThemeService get to => Get.find();

  // Reactive theme state
  final Rx<ThemeType> _themeMode = ThemeType.system.obs;
  final Rx<Color> _customColor = const Color.fromARGB(255, 92, 182, 123).obs;
  final RxBool _isDynamicColor = true.obs;

  ThemeType get themeMode => _themeMode.value;
  Color get customColor => _customColor.value;
  bool get isDynamicColor => _isDynamicColor.value;

  /// Initialize theme from storage.
  Future<void> init() async {
    // TODO: Load from storage
    // _themeMode.value = ThemeType.values[setting.get(SettingBoxKey.themeMode, defaultValue: ThemeType.system.code)];
    // _customColor.value = colorThemeTypes[setting.get(SettingBoxKey.customColor, defaultValue: 0)]['color'];
    // _isDynamicColor.value = setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
  }

  /// Set theme mode.
  Future<void> setThemeMode(ThemeType mode) async {
    _themeMode.value = mode;
    // TODO: Save to storage
  }

  /// Set custom theme color.
  Future<void> setCustomColor(Color color) async {
    _customColor.value = color;
    // TODO: Save to storage
  }

  /// Set dynamic color preference.
  Future<void> setDynamicColor(bool enabled) async {
    _isDynamicColor.value = enabled;
    // TODO: Save to storage
  }

  /// Get current color scheme.
  ColorScheme getColorScheme(BuildContext context, Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: _customColor.value,
      brightness: brightness,
    );
  }
}
