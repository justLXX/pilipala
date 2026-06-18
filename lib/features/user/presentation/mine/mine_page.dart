import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/features/media/presentation/media_controller.dart';
import 'package:pilipala/features/media/presentation/media_page.dart';
import 'package:pilipala/features/user/presentation/mine/mine_controller.dart';
import 'package:pilipala/models/common/theme_type.dart';
import 'package:pilipala/models/user/info.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final MineController mineController = Get.put(MineController());
  late final MediaController mediaController;
  late Future _futureBuilderFuture;
  late Future _favFolderFuture;
  late StreamSubscription _mineLoginSubscription;
  late StreamSubscription _mediaLoginSubscription;

  @override
  void initState() {
    super.initState();
    mediaController = Get.isRegistered<MediaController>()
        ? Get.find<MediaController>()
        : Get.put(MediaController());
    _futureBuilderFuture = mineController.queryUserInfo();
    _favFolderFuture = mediaController.queryFavFolder();

    _mineLoginSubscription = mineController.userLogin.listen((status) {
      if (mounted) {
        setState(() {
          _futureBuilderFuture = mineController.queryUserInfo();
        });
      }
    });
    _mediaLoginSubscription = mediaController.userLogin.listen((status) {
      if (mounted) {
        setState(() {
          _favFolderFuture = mediaController.queryFavFolder();
        });
      }
    });
  }

  @override
  void dispose() {
    _mineLoginSubscription.cancel();
    _mediaLoginSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        elevation: 0,
        toolbarHeight: kTextTabBarHeight + 20,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'PLPL',
          style: TextStyle(
            height: 2.8,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            fontFamily: 'Jura-Bold',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => mineController.onChangeTheme(),
            icon: Icon(
              mineController.themeType.value == ThemeType.dark
                  ? CupertinoIcons.sun_max
                  : CupertinoIcons.moon,
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/setting', preventDuplicates: false),
            icon: const Icon(
              CupertinoIcons.slider_horizontal_3,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraint.maxWidth,
                minHeight: constraint.maxHeight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: _futureBuilderFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data == null) {
                              return const SizedBox();
                            }
                            if (snapshot.data['status']) {
                              return Obx(
                                  () => userInfoBuild(mineController, context));
                            } else {
                              return userInfoBuild(mineController, context);
                            }
                          } else {
                            return userInfoBuild(mineController, context);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MediaLibraryContent(
                    mediaController: mediaController,
                    favFolderFuture: _favFolderFuture,
                    onRefreshFavFolder: () {
                      setState(() {
                        _favFolderFuture = mediaController.queryFavFolder();
                      });
                    },
                    bottomPadding: MediaQuery.of(context).padding.bottom +
                        kBottomNavigationBarHeight,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget userInfoBuild(mineCtr, context) {
    return Column(
      children: [
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () => mineCtr.onLogin(),
          child: ClipOval(
            child: Container(
              width: 85,
              height: 85,
              color: Theme.of(context).colorScheme.onInverseSurface,
              child: Center(
                child: mineCtr.userInfo.value.face != null
                    ? NetworkImgLayer(
                        src: mineCtr.userInfo.value.face, width: 85, height: 85)
                    : Image.asset('assets/images/noface.jpeg'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              mineCtr.userInfo.value.uname ?? '点击头像登录',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            Image.asset(
              'assets/images/lv/lv${mineCtr.userInfo.value.levelInfo != null ? mineCtr.userInfo.value.levelInfo!.currentLevel : '0'}.png',
              height: 10,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '硬币: ',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.outline)),
              TextSpan(
                  text: (mineCtr.userInfo.value.money ?? 'pilipala').toString(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
            ]))
          ],
        ),
        const SizedBox(height: 25),
        if (mineCtr.userInfo.value.levelInfo != null) ...[
          LayoutBuilder(
            builder: (context, BoxConstraints box) {
              LevelInfo levelInfo = mineCtr.userInfo.value.levelInfo;
              return SizedBox(
                width: box.maxWidth,
                height: 24,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Theme.of(context).colorScheme.primary,
                        height: 24,
                        constraints: const BoxConstraints(minWidth: 100),
                        width: box.maxWidth *
                            (1 - (levelInfo.currentExp! / levelInfo.nextExp!)),
                        child: Center(
                          child: Text(
                            '${levelInfo.currentExp!}/${levelInfo.nextExp!}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 23,
                      left: 0,
                      bottom: 0,
                      child: Container(
                        width: box.maxWidth *
                            (mineCtr.userInfo.value.levelInfo!.currentExp! /
                                mineCtr.userInfo.value.levelInfo!.nextExp!),
                        height: 1,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              TextStyle style = TextStyle(
                  fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold);
              return SizedBox(
                height: constraints.maxWidth / 3 * 0.6,
                child: GridView.count(
                  primary: false,
                  padding: const EdgeInsets.all(0),
                  crossAxisCount: 3,
                  childAspectRatio: 1.67,
                  children: <Widget>[
                    InkWell(
                      onTap: () => mineCtr.pushDynamic(),
                      borderRadius: StyleString.mdRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                                (mineCtr.userStat.value.dynamicCount ?? '-')
                                    .toString(),
                                key: ValueKey<String>(mineCtr
                                    .userStat.value.dynamicCount
                                    .toString()),
                                style: style),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '动态',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => mineCtr.pushFollow(),
                      borderRadius: StyleString.mdRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                                (mineCtr.userStat.value.following ?? '-')
                                    .toString(),
                                key: ValueKey<String>(mineCtr
                                    .userStat.value.following
                                    .toString()),
                                style: style),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '关注',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => mineCtr.pushFans(),
                      borderRadius: StyleString.mdRadius,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return ScaleTransition(
                                  scale: animation, child: child);
                            },
                            child: Text(
                                (mineCtr.userStat.value.follower ?? '-')
                                    .toString(),
                                key: ValueKey<String>(
                                    mineCtr.userStat.value.follower.toString()),
                                style: style),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '粉丝',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
