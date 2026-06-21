import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'setting_controller.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingController settingController = Get.find<SettingController>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '设置',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          14,
          8,
          14,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        children: [
          _SettingTile(
            icon: Icons.lock_outline,
            title: '隐私设置',
            subtitle: '黑名单、历史记录和隐私偏好',
            onTap: () => Get.toNamed('/privacySetting'),
          ),
          _SettingTile(
            icon: Icons.tune,
            title: '推荐设置',
            subtitle: '首页推荐内容与过滤偏好',
            onTap: () => Get.toNamed('/recommendSetting'),
          ),
          _SettingTile(
            icon: Icons.play_circle_outline,
            title: '播放设置',
            subtitle: '播放器、手势和默认清晰度',
            onTap: () => Get.toNamed('/playSetting'),
          ),
          _SettingTile(
            icon: Icons.palette_outlined,
            title: '外观设置',
            subtitle: '主题、底栏、图片质量与字体',
            onTap: () => Get.toNamed('/styleSetting'),
          ),
          _SettingTile(
            icon: Icons.more_horiz,
            title: '其他设置',
            subtitle: '日志、缓存和实验选项',
            onTap: () => Get.toNamed('/extraSetting'),
          ),
          Obx(
            () => settingController.userLogin.value
                ? _SettingTile(
                    icon: Icons.logout,
                    title: '退出登录',
                    subtitle: '退出当前账号',
                    destructive: true,
                    onTap: () => settingController.loginOut(),
                  )
                : const SizedBox.shrink(),
          ),
          _SettingTile(
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本信息与项目说明',
            onTap: () => Get.toNamed('/about'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: StyleString.lgRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: StyleString.lgRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.42),
              borderRadius: StyleString.lgRadius,
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: StyleString.mdRadius,
                    ),
                    child: Icon(icon, size: 21, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
