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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '热搜',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: hotSearchList.map((item) {
            return ActionChip(
              label: Text(item.keyword ?? ''),
              onPressed: () => onTap(item.keyword ?? ''),
            );
          }).toList(),
        ),
      ],
    );
  }
}
