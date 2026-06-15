import 'package:flutter/material.dart';

class Responsive {
  static bool isExpanded(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= 720;
  }

  static bool isCompact(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < 600;
  }

  static int videoGridCount(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1400) {
      return 3;
    }
    if (width >= 720) {
      return 2;
    }
    return 1;
  }

  static double constrainedContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) {
      return 1100;
    }
    if (width >= 720) {
      return width - 48;
    }
    return width;
  }

  static double dynamicsContentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) {
      return 760;
    }
    if (width >= 720) {
      return width - 96;
    }
    return width;
  }

  static double videoPlayerWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) {
      return 1040;
    }
    if (width >= 720) {
      return width - 48;
    }
    return width;
  }
}
