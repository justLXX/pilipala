import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/about/domain/about_use_cases.dart';
import 'package:pilipala/models/github/latest.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pilipala/utils/utils.dart';

class AboutController extends GetxController {
  RxString currentVersion = ''.obs;
  RxString remoteVersion = ''.obs;
  LatestDataModel? remoteAppInfo;
  RxBool isUpdate = false.obs;
  RxBool isLoading = true.obs;
  LatestDataModel? data;

  final CheckUpdateUseCase _checkUpdateUseCase = Get.find<CheckUpdateUseCase>();
  final GetCurrentVersionUseCase _getCurrentVersionUseCase =
      Get.find<GetCurrentVersionUseCase>();

  @override
  void onInit() {
    super.onInit();
    loadAppInfo();
  }

  Future<void> loadAppInfo() async {
    getCurrentApp();
    await getRemoteApp();
  }

  Future<void> getCurrentApp() async {
    currentVersion.value = await _getCurrentVersionUseCase.execute();
  }

  Future<void> getRemoteApp() async {
    isLoading.value = true;
    final result = await _checkUpdateUseCase.execute(currentVersion.value);
    isLoading.value = false;

    if (result['status'] == true) {
      data = result['data'];
      remoteAppInfo = data;
      remoteVersion.value = result['remoteVersion'] ?? '';
      isUpdate.value = result['needUpdate'] ?? false;
    } else {
      SmartDialog.showToast(result['msg'] ?? '获取远程版本失败，请检查网络');
    }
  }

  Future<void> onUpdate() async {
    if (data != null) {
      Utils.matchVersion(data!);
    }
  }

  void githubUrl() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala'),
      mode: LaunchMode.externalApplication,
    );
  }

  void githubRelease() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala/releases'),
      mode: LaunchMode.externalApplication,
    );
  }

  void panDownload() {
    Clipboard.setData(
      const ClipboardData(text: 'pili'),
    );
    SmartDialog.showToast(
      '已复制提取码：pili',
      displayTime: const Duration(milliseconds: 500),
    ).then(
      (value) => launchUrl(
        Uri.parse('https://www.123pan.com/s/9sVqVv-flu0A.html'),
        mode: LaunchMode.externalApplication,
      ),
    );
  }

  void feedback() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala/issues'),
      mode: LaunchMode.externalApplication,
    );
  }

  void qqChannel() {
    Clipboard.setData(
      const ClipboardData(text: '616150809'),
    );
    SmartDialog.showToast('已复制QQ群号');
  }

  void tgChannel() {
    Clipboard.setData(
      const ClipboardData(text: 'https://t.me/+lm_oOVmF0RJiODk1'),
    );
    SmartDialog.showToast(
      '已复制，即将在浏览器打开',
      displayTime: const Duration(milliseconds: 500),
    ).then(
      (value) => launchUrl(
        Uri.parse('https://t.me/+lm_oOVmF0RJiODk1'),
        mode: LaunchMode.externalApplication,
      ),
    );
  }

  void aPay() {
    try {
      launchUrl(
        Uri.parse(
            'alipayqr://platformapi/startapp?saId=10000007&qrcode=https://qr.alipay.com/fkx14623ddwl1ping3ddd73'),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print(e);
    }
  }

  void webSiteUrl() {
    launchUrl(
      Uri.parse('https://pilipalanet.mysxl.cn'),
      mode: LaunchMode.externalApplication,
    );
  }

  void qimiao() {
    launchUrl(
      Uri.parse('https://www.magicalapk.com/home'),
      mode: LaunchMode.externalApplication,
    );
  }

  void logs() {
    Get.toNamed('/logs');
  }
}
