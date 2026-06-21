import 'package:flutter/material.dart';

class MediaOverlayBadge extends StatelessWidget {
  const MediaOverlayBadge({
    super.key,
    required this.text,
    this.backgroundColor,
    this.foregroundColor = Colors.white,
  });

  final String text;
  final Color? backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
