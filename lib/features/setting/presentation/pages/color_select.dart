import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/models/common/color_type.dart';
import 'package:pilipala/utils/storage.dart';

class ColorSelectPage extends StatefulWidget {
  const ColorSelectPage({super.key});

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  final ColorSelectController ctr = Get.put(ColorSelectController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('选择应用主题'),
      ),
      body: Obx(
        () => RadioGroup<int>(
          groupValue: ctr.type.value,
          onChanged: (int? value) {
            if (value != null) {
              ctr.type.value = value;
              ctr.setting.put(SettingBoxKey.dynamicColor, value == 0);
            }
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              _ThemeModeTile(
                value: 0,
                selected: ctr.type.value == 0,
                title: '动态取色',
                subtitle: '跟随系统壁纸生成应用主色',
              ),
              const SizedBox(height: 8),
              _ThemeModeTile(
                value: 1,
                selected: ctr.type.value == 1,
                title: '指定颜色',
                subtitle: '手动选择一套固定主题色',
              ),
              Builder(
                builder: (context) {
                  final type = ctr.type.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: type == 1
                        ? Padding(
                            key: const ValueKey('color-grid'),
                            padding: const EdgeInsets.only(top: 16),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.42),
                                borderRadius: StyleString.lgRadius,
                                border: Border.all(
                                  color: colorScheme.outlineVariant
                                      .withValues(alpha: 0.28),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 18,
                                  runSpacing: 18,
                                  children: ctr.colorThemes.map(
                                    (e) {
                                      final index = ctr.colorThemes.indexOf(e);
                                      final color = e['color'] as Color;
                                      return _ColorThemeItem(
                                        label: e['label'] as String,
                                        color: color,
                                        selected:
                                            ctr.currentColor.value == index,
                                        onTap: () {
                                          ctr.currentColor.value = index;
                                          ctr.setting.put(
                                            SettingBoxKey.customColor,
                                            index,
                                          );
                                          Get.forceAppUpdate();
                                        },
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.value,
    required this.selected,
    required this.title,
    required this.subtitle,
  });

  final int value;
  final bool selected;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RadioListTile<int>(
      value: value,
      shape: RoundedRectangleBorder(
        borderRadius: StyleString.mdRadius,
      ),
      tileColor: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.48)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.36),
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.48),
      title: Text(title),
      subtitle: Text(subtitle),
      selected: selected,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _ColorThemeItem extends StatelessWidget {
  const _ColorThemeItem({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black;

    return InkWell(
      onTap: onTap,
      borderRadius: StyleString.mdRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: SizedBox(
          width: 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: selected ? 3 : 1,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.done,
                    color: foreground,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? colorScheme.onSurface : colorScheme.outline,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColorSelectController extends GetxController {
  Box setting = GStrorage.setting;
  RxBool dynamicColor = true.obs;
  RxInt type = 0.obs;
  late final List<Map<String, dynamic>> colorThemes;
  RxInt currentColor = 0.obs;

  @override
  void onInit() {
    colorThemes = colorThemeTypes;
    // 默认使用动态取色
    dynamicColor.value =
        setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
    type.value = dynamicColor.value ? 0 : 1;
    currentColor.value =
        setting.get(SettingBoxKey.customColor, defaultValue: 0);
    super.onInit();
  }
}
