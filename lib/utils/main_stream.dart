import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import 'package:pilipala/features/main/presentation/main_controller.dart';

void handleScrollEvent(ScrollController scrollController) {
  StreamController<bool> mainStream =
      Get.find<MainController>().bottomBarStream;

  // searchBarStream 仅存在于旧版 HomeController
  // 当前使用 features 首页，无此属性，安全置空
  StreamController<bool>? searchBarStream;

  EasyThrottle.throttle(
    'stream-throttler',
    const Duration(milliseconds: 300),
    () {
      try {
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          mainStream.add(true);
          searchBarStream?.add(true);
        } else if (direction == ScrollDirection.reverse) {
          mainStream.add(false);
          searchBarStream?.add(false);
        }
      } catch (_) {}
    },
  );
}
