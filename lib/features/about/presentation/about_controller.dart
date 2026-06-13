import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pilipala/http/index.dart';
import 'package:pilipala/models/github/latest.dart';
import 'package:pilipala/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends GetxController {
  RxString currentVersion = ''.obs;
  RxString remoteVersion = ''.obs;
  late LatestDataModel remoteAppInfo;
  RxBool isUpdate = false.obs;
  RxBool isLoading = true.obs;
  late LatestDataModel data;

  @override
  void onInit() {
    super.onInit();
    getCurrentApp();
    getRemoteApp();
  }

  Future getCurrentApp() async {
    var result = await PackageInfo.fromPlatform();
    currentVersion.value = result.version;
  }

  Future getRemoteApp() async {
    var result = await Request().get(Api.latestApp, extra: {'ua': 'pc'});
    isLoading.value = false;
    if (result.data == null || result.data.isEmpty) {
      SmartDialog.showToast('获取远程版本失败，请检查网络');
      return;
    }
    data = LatestDataModel.fromJson(result.data);
    remoteAppInfo = data;
    remoteVersion.value = data.tagName!;
    isUpdate.value =
        Utils.needUpdate(currentVersion.value, remoteVersion.value);
  }

  Future onUpdate() async {
    Utils.matchVersion(data);
  }

  githubUrl() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala'),
      mode: LaunchMode.externalApplication,
    );
  }

  githubRelease() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala/releases'),
      mode: LaunchMode.externalApplication,
    );
  }

  panDownload() {
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

  feedback() {
    launchUrl(
      Uri.parse('https://github.com/guozhigq/pilipala/issues'),
      mode: LaunchMode.externalApplication,
    );
  }

  qqChanel() {
    Clipboard.setData(
      const ClipboardData(text: '616150809'),
    );
    SmartDialog.showToast('已复制QQ群号');
  }

  tgChanel() {
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

  aPay() {
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

  webSiteUrl() {
    launchUrl(
      Uri.parse('https://pilipalanet.mysxl.cn'),
      mode: LaunchMode.externalApplication,
    );
  }

  qimiao() {
    launchUrl(
      Uri.parse('https://www.magicalapk.com/home'),
      mode: LaunchMode.externalApplication,
    );
  }

  logs() {
    Get.toNamed('/logs');
  }
}
