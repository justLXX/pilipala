import 'package:flutter/material.dart';

enum TabType { live, rcmd, hot, bangumi }

extension TabTypeDesc on TabType {
  String get description => ['直播', '推荐', '热门', '番剧'][index];
  String get id => ['live', 'rcmd', 'hot', 'bangumi'][index];
}

/// 基础 tab 配置（纯数据，不含 Controller/Page 引用）
List tabsConfig = [
  {
    'icon': const Icon(
      Icons.live_tv_outlined,
      size: 15,
    ),
    'label': '直播',
    'type': TabType.live,
  },
  {
    'icon': const Icon(
      Icons.thumb_up_off_alt_outlined,
      size: 15,
    ),
    'label': '推荐',
    'type': TabType.rcmd,
  },
  {
    'icon': const Icon(
      Icons.whatshot_outlined,
      size: 15,
    ),
    'label': '热门',
    'type': TabType.hot,
  },
  {
    'icon': const Icon(
      Icons.play_circle_outlined,
      size: 15,
    ),
    'label': '番剧',
    'type': TabType.bangumi,
  },
];
