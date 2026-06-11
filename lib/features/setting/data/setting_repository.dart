import 'package:hive/hive.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/common/dynamic_badge_mode.dart';
import 'package:pilipala/models/common/theme_type.dart';
import 'package:pilipala/utils/login.dart';
import 'package:pilipala/utils/storage.dart';

/// Repository for setting operations (Hive-based, no HTTP).
class SettingRepository {
  final Box _userInfoCache = GStrorage.userInfo;
  final Box _setting = GStrorage.setting;
  final Box _localCache = GStrorage.localCache;

  /// Get cached user info.
  dynamic getUserInfo() => _userInfoCache.get('userInfoCache');

  /// Check if user is logged in.
  bool isUserLoggedIn() => getUserInfo() != null;

  /// Get feedback enabled status.
  bool getFeedBackEnable() =>
      _setting.get(SettingBoxKey.feedBackEnable, defaultValue: false);

  /// Set feedback enabled status.
  Future<void> setFeedBackEnable(bool value) =>
      _setting.put(SettingBoxKey.feedBackEnable, value);

  /// Get toast opacity.
  double getToastOpacity() =>
      _setting.get(SettingBoxKey.defaultToastOp, defaultValue: 1.0);

  /// Get picture quality.
  int getPicQuality() =>
      _setting.get(SettingBoxKey.defaultPicQa, defaultValue: 10);

  /// Get theme type.
  ThemeType getThemeType() => ThemeType.values[_setting.get(
      SettingBoxKey.themeMode,
      defaultValue: ThemeType.system.code)];

  /// Get dynamic badge mode.
  DynamicBadgeMode getDynamicBadgeMode() => DynamicBadgeMode
      .values[_setting.get(SettingBoxKey.dynamicBadgeMode,
          defaultValue: DynamicBadgeMode.number.code)];

  /// Set dynamic badge mode.
  Future<void> setDynamicBadgeMode(DynamicBadgeMode mode) =>
      _setting.put(SettingBoxKey.dynamicBadgeMode, mode.code);

  /// Get default home page index.
  int getDefaultHomePage() =>
      _setting.get(SettingBoxKey.defaultHomePage, defaultValue: 0);

  /// Set default home page.
  Future<void> setDefaultHomePage(int index) =>
      _setting.put(SettingBoxKey.defaultHomePage, index);

  /// Logout: clear cookies, user cache, access key.
  Future<void> logout() async {
    await Request.cookieManager.cookieJar.deleteAll();
    Request.dio.options.headers['cookie'] = '';
    _userInfoCache.put('userInfoCache', null);
    _localCache.put(LocalCacheKey.accessKey, {'mid': -1, 'value': ''});
    await LoginUtils.refreshLoginStatus(false);
  }
}
