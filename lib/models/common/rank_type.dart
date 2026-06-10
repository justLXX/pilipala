enum RandType {
  all,
  animation,
  music,
  dance,
  game,
  knowledge,
  technology,
  sport,
  car,
  food,
  animal,
  madness,
  fashion,
  entertainment,
  film
}

extension RankTypeDesc on RandType {
  String get description => [
        '全站',
        '动画',
        '音乐',
        '舞蹈',
        '游戏',
        '知识',
        '科技',
        '运动',
        '汽车',
        '美食',
        '动物圈',
        '鬼畜',
        '时尚',
        '娱乐',
        '影视'
      ][index];

  String get id => [
        'all',
        'animation',
        'music',
        'dance',
        'game',
        'knowledge',
        'technology',
        'sport',
        'car',
        'food',
        'animal',
        'madness',
        'fashion',
        'entertainment',
        'film'
      ][index];
}

/// Tab configuration for the ranking feature.
///
/// Each entry maps a zone label to its Bilibili zone `rid`.
/// `rid = 0` represents the "全站" (all zones) ranking.
List rankTabConfigs = [
  {'label': '全站', 'type': RandType.all, 'rid': 0},
  {'label': '动画', 'type': RandType.animation, 'rid': 1005},
  {'label': '音乐', 'type': RandType.music, 'rid': 1003},
  {'label': '舞蹈', 'type': RandType.dance, 'rid': 1004},
  {'label': '游戏', 'type': RandType.game, 'rid': 1008},
  {'label': '知识', 'type': RandType.knowledge, 'rid': 1010},
  {'label': '科技', 'type': RandType.technology, 'rid': 1012},
  {'label': '运动', 'type': RandType.sport, 'rid': 1018},
  {'label': '汽车', 'type': RandType.car, 'rid': 1013},
  {'label': '美食', 'type': RandType.food, 'rid': 1020},
  {'label': '动物圈', 'type': RandType.animal, 'rid': 1024},
  {'label': '鬼畜', 'type': RandType.madness, 'rid': 1007},
  {'label': '时尚', 'type': RandType.fashion, 'rid': 1014},
  {'label': '娱乐', 'type': RandType.entertainment, 'rid': 1002},
  {'label': '影视', 'type': RandType.film, 'rid': 1001},
];

/// Backward-compatible alias for [rankTabConfigs].
///
/// Kept so that legacy `lib/pages/rank/` code continues to compile.
// ignore: non_constant_identifier_names
List get tabsConfig => rankTabConfigs;
