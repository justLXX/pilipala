import 'package:pilipala/features/setting/data/setting_repository.dart';
import 'package:pilipala/models/common/dynamic_badge_mode.dart';

class GetSettingInitDataUseCase {
  final SettingRepository _repo;
  GetSettingInitDataUseCase({SettingRepository? repo})
      : _repo = repo ?? SettingRepository();

  Map<String, dynamic> execute() {
    return {
      'userInfo': _repo.getUserInfo(),
      'userLogin': _repo.isUserLoggedIn(),
      'feedBackEnable': _repo.getFeedBackEnable(),
      'toastOpacity': _repo.getToastOpacity(),
      'picQuality': _repo.getPicQuality(),
      'themeType': _repo.getThemeType(),
      'dynamicBadgeType': _repo.getDynamicBadgeMode(),
      'defaultHomePage': _repo.getDefaultHomePage(),
    };
  }
}

class LogoutUseCase {
  final SettingRepository _repo;
  LogoutUseCase({SettingRepository? repo})
      : _repo = repo ?? SettingRepository();
  Future<void> execute() => _repo.logout();
}

class ToggleFeedBackUseCase {
  final SettingRepository _repo;
  ToggleFeedBackUseCase({SettingRepository? repo})
      : _repo = repo ?? SettingRepository();
  Future<void> execute(bool value) => _repo.setFeedBackEnable(value);
}

class SetDynamicBadgeModeUseCase {
  final SettingRepository _repo;
  SetDynamicBadgeModeUseCase({SettingRepository? repo})
      : _repo = repo ?? SettingRepository();
  Future<void> execute(DynamicBadgeMode mode) =>
      _repo.setDynamicBadgeMode(mode);
}

class SetDefaultHomePageUseCase {
  final SettingRepository _repo;
  SetDefaultHomePageUseCase({SettingRepository? repo})
      : _repo = repo ?? SettingRepository();
  Future<void> execute(int index) => _repo.setDefaultHomePage(index);
}
