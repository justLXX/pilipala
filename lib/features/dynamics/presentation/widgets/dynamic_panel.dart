import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/dynamics/presentation/dynamics_controller.dart';
import 'action_panel.dart';
import 'author_panel.dart';
import 'content_panel.dart';
import 'forward_panel.dart';

class DynamicPanel extends StatelessWidget {
  final dynamic item;
  final String? source;
  DynamicPanel({required this.item, this.source, Key? key}) : super(key: key);
  final DynamicsController _dynamicsController = Get.put(DynamicsController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: source == 'detail'
          ? const EdgeInsets.fromLTRB(0, 0, 0, 12)
          : const EdgeInsets.fromLTRB(10, 6, 10, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(source == 'detail' ? 0 : 16),
          border: source == 'detail'
              ? null
              : Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                ),
        ),
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(source == 'detail' ? 0 : 16),
          ),
          child: InkWell(
            onTap: () => _dynamicsController.pushDetail(item, 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: AuthorPanel(item: item),
                ),
                if (item.modules!.moduleDynamic!.desc != null ||
                    item.modules!.moduleDynamic!.major != null)
                  Content(item: item, source: source),
                forWard(item, context, _dynamicsController, source),
                const SizedBox(height: 2),
                if (source == null) ActionPanel(item: item),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
