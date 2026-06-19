import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart' as features;
import '../../features/dynamics/presentation/dynamics_page.dart'
    as features_dynamics;
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
      size: 21,
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
