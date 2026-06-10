import 'package:flutter/material.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/utils/utils.dart';

/// HeaderControlWidget displays the video title, description, and stats.
/// Supports expand/collapse for the description area.
class HeaderControlWidget extends StatefulWidget {
  final VideoDetailData videoDetail;
  final dynamic playUrl;

  const HeaderControlWidget({
    super.key,
    required this.videoDetail,
    this.playUrl,
  });

  @override
  State<HeaderControlWidget> createState() => _HeaderControlWidgetState();
}

class _HeaderControlWidgetState extends State<HeaderControlWidget> {
  bool _expanded = false;

  /// Check whether the description text exceeds [maxLines] at the given [maxWidth].
  bool _isTextOverflowing(String text, TextStyle? style, double maxWidth, int maxLines) {
    if (maxWidth <= 0) return false;
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }

  @override
  void didUpdateWidget(covariant HeaderControlWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset expanded state when video detail changes
    if (widget.videoDetail != oldWidget.videoDetail) {
      _expanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = widget.videoDetail;
    final theme = Theme.of(context);
    final outlineColor = theme.colorScheme.outline;
    final descStyle = theme.textTheme.bodySmall?.copyWith(
      color: outlineColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            detail.title ?? '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: _expanded ? null : 2,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),

        // Stats row
        if (detail.stat != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Text(
                  Utils.numFormat(detail.stat!.view ?? 0),
                  style: TextStyle(fontSize: 12, color: outlineColor),
                ),
                const SizedBox(width: 10),
                Text(
                  '${Utils.numFormat(detail.stat!.danmaku ?? 0)}弹幕',
                  style: TextStyle(fontSize: 12, color: outlineColor),
                ),
                const SizedBox(width: 10),
                if (detail.pubdate != null)
                  Text(
                    Utils.dateFormat(detail.pubdate, formatType: 'detail'),
                    style: TextStyle(fontSize: 12, color: outlineColor),
                  ),
              ],
            ),
          ),

        // Description (collapsible)
        if (detail.desc != null && detail.desc!.isNotEmpty)
          LayoutBuilder(
            builder: (context, constraints) {
              final isOverflowing = _isTextOverflowing(
                detail.desc!,
                descStyle,
                constraints.maxWidth - 32, // subtract horizontal padding
                3,
              );

              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: isOverflowing
                    ? () => setState(() => _expanded = !_expanded)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.desc!,
                        style: descStyle,
                        maxLines: _expanded ? null : 3,
                        overflow: _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      if (isOverflowing) ...[
                        const SizedBox(height: 4),
                        Text(
                          _expanded ? '收起' : '展开更多',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 8),
      ],
    );
  }
}
