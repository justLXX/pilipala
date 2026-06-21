import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/utils.dart';

class SetSwitchItem extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final String? setKey;
  final bool? defaultVal;
  final Function? callFn;
  final bool? needReboot;

  const SetSwitchItem({
    this.title,
    this.subTitle,
    this.setKey,
    this.defaultVal,
    this.callFn,
    this.needReboot,
    Key? key,
  }) : super(key: key);

  @override
  State<SetSwitchItem> createState() => _SetSwitchItemState();
}

class _SetSwitchItemState extends State<SetSwitchItem> {
  // ignore: non_constant_identifier_names
  Box Setting = GStrorage.setting;
  late bool val;

  @override
  void initState() {
    super.initState();
    val = Setting.get(widget.setKey, defaultValue: widget.defaultVal ?? false);
  }

  void switchChange(value) async {
    val = value ?? !val;
    await Setting.put(widget.setKey, val);
    if (widget.setKey == SettingBoxKey.autoUpdate && value == true) {
      Utils.checkUpdata();
    }
    if (widget.callFn != null) {
      widget.callFn!.call(val);
    }
    if (widget.needReboot != null && widget.needReboot!) {
      SmartDialog.showToast('重启生效');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    TextStyle subTitleStyle = Theme.of(context)
        .textTheme
        .labelMedium!
        .copyWith(color: Theme.of(context).colorScheme.outline);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Material(
        color: Colors.transparent,
        borderRadius: StyleString.lgRadius,
        child: InkWell(
          enableFeedback: true,
          onTap: () => switchChange(null),
          borderRadius: StyleString.lgRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.38),
              borderRadius: StyleString.lgRadius,
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title!, style: titleStyle),
                        if (widget.subTitle != null) ...[
                          const SizedBox(height: 3),
                          Text(widget.subTitle!, style: subTitleStyle),
                        ],
                      ],
                    ),
                  ),
                  Transform.scale(
                    alignment: Alignment.centerRight,
                    scale: 0.8,
                    child: Switch(
                      thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                          (Set<WidgetState> states) {
                        if (states.isNotEmpty &&
                            states.first == WidgetState.selected) {
                          return const Icon(Icons.done);
                        }
                        return null;
                      }),
                      value: val,
                      onChanged: (val) => switchChange(val),
                    ),
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
