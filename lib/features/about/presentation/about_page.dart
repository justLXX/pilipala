import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/about/presentation/about_controller.dart';
import 'package:pilipala/utils/cache_manage.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final AboutController _aboutController = Get.put(AboutController());
  String cacheSize = '';

  @override
  void initState() {
    super.initState();
    getCacheSize();
  }

  Future<void> getCacheSize() async {
    final res = await CacheManage().loadApplicationCache();
    setState(() => cacheSize = res);
  }

  @override
  Widget build(BuildContext context) {
    final Color outline = Theme.of(context).colorScheme.outline;
    TextStyle subTitleStyle =
        TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.outline);
    return Scaffold(
      appBar: AppBar(
        title: Text('关于', style: Theme.of(context).textTheme.titleMedium),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo/logo_android_2.png',
              width: 150,
            ),
            Text(
              'PiliPala',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Obx(
              () => Badge(
                isLabelVisible: _aboutController.isLoading.value
                    ? false
                    : _aboutController.isUpdate.value,
                label: const Text('New'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: FilledButton.tonal(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                onTap: () => _aboutController.githubRelease(),
                                title: const Text('Github下载'),
                              ),
                              ListTile(
                                onTap: () => _aboutController.panDownload(),
                                title: const Text('网盘下载'),
                              ),
                              ListTile(
                                onTap: () => _aboutController.webSiteUrl(),
                                title: const Text('官网下载'),
                              ),
                              ListTile(
                                onTap: () => _aboutController.qimiao(),
                                title: const Text('奇妙应用'),
                              ),
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).padding.bottom +
                                          20)
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      'V${_aboutController.currentVersion.value}',
                      style: subTitleStyle.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              onTap: () => _aboutController.githubUrl(),
              title: const Text('开源地址'),
              trailing: Text(
                'github.com/guozhigq/pilipala',
                style: subTitleStyle,
              ),
            ),
            ListTile(
              onTap: () => _aboutController.webSiteUrl(),
              title: const Text('访问官网'),
              trailing: Text(
                'https://pilipalanet.mysxl.cn',
                style: subTitleStyle,
              ),
            ),
            ListTile(
              onTap: () => _aboutController.panDownload(),
              title: const Text('网盘下载'),
              trailing: Text(
                '提取码：pili',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            ListTile(
              onTap: () => _aboutController.feedback(),
              title: const Text('问题反馈'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: outline,
              ),
            ),
            ListTile(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          onTap: () => _aboutController.qqChanel(),
                          title: const Text('QQ群'),
                          trailing: Text(
                            '616150809',
                            style: subTitleStyle,
                          ),
                        ),
                        ListTile(
                          onTap: () => _aboutController.tgChanel(),
                          title: const Text('TG频道'),
                          trailing: Text(
                            'https://t.me/+lm_oOVmF0RJiODk1',
                            style: subTitleStyle,
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 20)
                      ],
                    );
                  },
                );
              },
              title: const Text('交流社区'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: outline,
              ),
            ),
            ListTile(
              onTap: () => _aboutController.aPay(),
              title: const Text('赞助'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
            ),
            ListTile(
              onTap: () => _aboutController.logs(),
              title: const Text('错误日志'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: outline),
            ),
            ListTile(
              onTap: () async {
                var cleanStatus = await CacheManage().clearCacheAll();
                if (cleanStatus) {
                  getCacheSize();
                }
              },
              title: const Text('清除缓存'),
              subtitle: Text('图片及网络缓存 $cacheSize', style: subTitleStyle),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 20)
          ],
        ),
      ),
    );
  }
}
