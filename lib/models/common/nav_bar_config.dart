import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart' as features;
import '../../features/dynamics/presentation/dynamics_page.dart'
    as features_dynamics;
import '../../features/rank/presentation/rank_page.dart' as features_rank;
import '../../features/user/presentation/mine/mine_page.dart' as features_mine;

List defaultNavigationBars = [
  {
    'id': 0,
    'icon': const Icon(
      Icons.home_outlined,
      size: 21,
    ),
    'selectIcon': const Icon(
      Icons.home,
      size: 21,
    ),
    'label': "首页",
    'count': 0,
    'page': const features.HomePage(),
  },
  {
    'id': 1,
    'icon': const Icon(
      Icons.trending_up,
      size: 21,
    ),
    'selectIcon': const Icon(
      Icons.trending_up_outlined,
      size: 21,
    ),
    'label': "排行榜",
    'count': 0,
    'page': const features_rank.RankPage(),
  },
  {
    'id': 2,
    'icon': const Icon(
      Icons.motion_photos_on_outlined,
      size: 21,
    ),
    'selectIcon': const Icon(
      Icons.motion_photos_on,
      size: 21,
    ),
    'label': "动态",
    'count': 0,
    'page': const features_dynamics.DynamicsPage(),
  },
  {
    'id': 3,
    'icon': const Icon(
      Icons.person_outline,
      size: 20,
    ),
    'selectIcon': const Icon(
      Icons.person,
      size: 21,
    ),
    'label': "我的",
    'count': 0,
    'page': const features_mine.MinePage(),
  }
];
