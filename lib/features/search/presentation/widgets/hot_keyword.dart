import 'package:flutter/material.dart';
import 'package:pilipala/models/search/hot.dart';

/// HotKeywordWidget displays the hot search keywords.
class HotKeywordWidget extends StatelessWidget {
  final List<HotSearchItem> hotSearchList;
  final Function(String) onTap;

  const HotKeywordWidget({
    super.key,
    required this.hotSearchList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: hotSearchList.map((item) {
        final keyword = item.keyword ?? '';
        return ActionChip(
          side: BorderSide.none,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.58,
                  ),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          label: Text(keyword),
          onPressed: () => onTap(keyword),
        );
      }).toList(),
    );
  }
}
