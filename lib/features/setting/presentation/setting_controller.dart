import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/main/presentation/main_controller.dart';
import 'package:pilipala/features/setting/domain/setting_use_cases.dart';
import 'package:pilipala/models/common/dynamic_badge_mode.dart';
import 'package:pilipala/models/common/nav_bar_config.dart';
import 'package:pilipala/models/common/theme_type.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/storage.dart';

import 'widgets/select_dialog.dart';

class SettingController extends GetxController {
  late final GetSettingInitDataUseCase _getInitData;
  late final LogoutUseCase _logout;
  late final ToggleFeedBackUseCase _toggleFeedBack;
  late final SetDynamicBadgeModeUseCase _setDynamicBadge;
  late final SetDefaultHomePageUseCase _setDefaultHomePage;

  RxBool userLogin = false.obs;
  RxBool feedBackEnable = false.obs;
  RxDouble toastOpacity = (1.0).obs;
  RxInt picQuality = 10.obs;
  Rx<ThemeType> themeType = ThemeType.system.obs;
  var userInfo;
  Rx<DynamicBadgeMode> dynamicBadgeType = DynamicBadgeMode.number.obs;
  RxInt defaultHomePage = 0.obs;

  SettingController({
    GetSettingInitDataUseCase? getInitData,
    LogoutUseCase? logout,
    ToggleFeedBackUseCase? toggleFeedBack,
    SetDynamicBadgeModeUseCase? setDynamicBadge,
    SetDefaultHomePageUseCase? setDefaultHomePage,
  }) {
    _getInitData = getInitData ?? GetSettingInitDataUseCase();
    _logout = logout ?? LogoutUseCase();
    _toggleFeedBack = toggleFeedBack ?? ToggleFeedBackUseCase();
    _setDynamicBadge = setDynamicBadge ?? SetDynamicBadgeModeUseCase();
    _setDefaultHomePage = setDefaultHomePage ?? SetDefaultHomePageUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    final data = _getInitData.execute();
    userInfo = data['userInfo'];
    userLogin.value = data['userLogin'];
    feedBackEnable.value = data['feedBackEnable'];
    toastOpacity.value = data['toastOpacity'];
    picQuality.value = data['picQuality'];
    themeType.value = data['themeType'];
    dynamicBadgeType.value = data['dynamicBadgeType'];
    defaultHomePage.value = data['defaultHomePage'];
  }

  loginOut() async {
    SmartDialog.show(
      useSystem: true,
      animationType: SmartAnimationType.centerFade_otherSlide,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('确认要退出登录吗'),
          actions: [
            TextButton(
              onPressed: () => SmartDialog.dismiss(),
              child: const Text('点错了'),
            ),
            TextButton(
              onPressed: () async {
                await _logout.execute();
                SmartDialog.dismiss().then((value) => Get.back());
              },
              child: const Text('确认'),
            )
          ],
        );
      },
    );
  }

  // 开启关闭震动反馈
  onOpenFeedBack() {
    feedBack();
    feedBackEnable.value = !feedBackEnable.value;
    _toggleFeedBack.execute(feedBackEnable.value);
  }

  // 设置动态未读标记
  setDynamicBadgeMode(BuildContext context) async {
    DynamicBadgeMode? result = await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog<DynamicBadgeMode>(
          title: '动态未读标记',
          value: dynamicBadgeType.value,
          values: DynamicBadgeMode.values.map((e) {
            return {'title': e.description, 'value': e};
          }).toList(),
        );
      },
    );
    if (result != null) {
      dynamicBadgeType.value = result;
      await _setDynamicBadge.execute(result);
      try {
        MainController mainController = Get.find<MainController>();
        mainController.dynamicBadgeType.value =
            DynamicBadgeMode.values[result.code];
        if (mainController.dynamicBadgeType.value != DynamicBadgeMode.hidden) {
          mainController.getUnreadDynamic();
        }
      } catch (_) {}
      SmartDialog.showToast('设置成功');
    }
  }

  // 设置默认启动页
  seteDefaultHomePage(BuildContext context) async {
    int? result = await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog<int>(
            title: '首页启动页',
            value: defaultHomePage.value,
            values: defaultNavigationBars.map((e) {
              return {'title': e['label'], 'value': e['id']};
            }).toList());
      },
    );
    if (result != null) {
      defaultHomePage.value = result;
      await _setDefaultHomePage.execute(result);
      SmartDialog.showToast('设置成功，重启生效');
    }
  }
}
