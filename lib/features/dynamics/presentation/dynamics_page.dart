import 'dart:async';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/common/skeleton/dynamic_card.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/no_data.dart';
import 'package:pilipala/models/dynamics/result.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/main_stream.dart';
import 'package:pilipala/utils/responsive.dart';
import 'package:pilipala/utils/route_push.dart';
import 'package:pilipala/utils/storage.dart';

import 'package:pilipala/features/user/presentation/mine/mine_controller.dart';
import 'package:pilipala/features/dynamics/presentation/dynamics_controller.dart';
import 'package:pilipala/features/dynamics/presentation/widgets/dynamic_panel.dart';
import 'package:pilipala/features/dynamics/presentation/up_dynamic/route_panel.dart';
import 'package:pilipala/features/dynamics/presentation/widgets/up_panel.dart';

class DynamicsPage extends StatefulWidget {
  const DynamicsPage({super.key});

  @override
  State<DynamicsPage> createState() => _DynamicsPageState();
}

class _DynamicsPageState extends State<DynamicsPage>
    with AutomaticKeepAliveClientMixin {
  final DynamicsController _dynamicsController = Get.put(DynamicsController());
  final MineController mineController = Get.put(MineController());
  late Future _futureBuilderFuture;
  late Future _futureBuilderFutureUp;
  Box userInfoCache = GStrorage.userInfo;
  late ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _dynamicsController.queryFollowDynamic();
    _futureBuilderFutureUp = _dynamicsController.queryFollowUp();
    scrollController = _dynamicsController.scrollController;
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'queryFollowDynamic', const Duration(seconds: 1), () {
            _dynamicsController.queryFollowDynamic(type: 'onLoad');
          });
        }
        handleScrollEvent(scrollController);
      },
    );

    _dynamicsController.userLogin.listen((status) {
      if (mounted) {
        setState(() {
          _futureBuilderFuture = _dynamicsController.queryFollowDynamic();
          _futureBuilderFutureUp = _dynamicsController.queryFollowUp();
        });
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: SizedBox(
          height: 34,
          child: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    if (_dynamicsController.mid.value != -1 &&
                        _dynamicsController.upInfo.value.uname != null) {
                      return SizedBox(
                        height: 36,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text(
                              '${_dynamicsController.upInfo.value.uname!}的动态',
                              key: ValueKey<String>(
                                  _dynamicsController.upInfo.value.uname!),
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .fontSize,
                              )),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  }),
                  Obx(
                    () => _dynamicsController.userLogin.value
                        ? Visibility(
                            visible: _dynamicsController.mid.value == -1,
                            child: Theme(
                              data: ThemeData(
                                splashColor:
                                    Colors.transparent, // 点击时的水波纹颜色设置为透明
                                highlightColor:
                                    Colors.transparent, // 点击时的背景高亮颜色设置为透明
                              ),
                              child: CustomSlidingSegmentedControl<int>(
                                initialValue:
                                    _dynamicsController.initialValue.value,
                                children: {
                                  0: _DynamicTypeTab(
                                    label: '全部',
                                    selected: _dynamicsController
                                            .initialValue.value ==
                                        0,
                                  ),
                                  1: _DynamicTypeTab(
                                    label: '投稿',
                                    selected: _dynamicsController
                                            .initialValue.value ==
                                        1,
                                  ),
                                  2: _DynamicTypeTab(
                                    label: '番剧',
                                    selected: _dynamicsController
                                            .initialValue.value ==
                                        2,
                                  ),
                                  3: _DynamicTypeTab(
                                    label: '专栏',
                                    selected: _dynamicsController
                                            .initialValue.value ==
                                        3,
                                  ),
                                },
                                padding: 10.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.52),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                thumbDecoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                onValueChanged: (v) {
                                  feedBack();
                                  _dynamicsController.onSelectType(v);
                                },
                              ),
                            ),
                          )
                        : Text('动态',
                            style: Theme.of(context).textTheme.titleMedium),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _dynamicsController.onRefresh(),
        child: CustomScrollView(
          controller: _dynamicsController.scrollController,
          slivers: [
            FutureBuilder(
              future: _futureBuilderFutureUp,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  Map data = snapshot.data;
                  if (data['status']) {
                    return Obx(
                      () => UpPanel(
                        upData: _dynamicsController.upData.value,
                        onClickUpCb: (data) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpDynamicsPage(
                                  ctr: _dynamicsController, upInfo: data),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    );
                  }
                } else {
                  return const SliverToBoxAdapter(
                      child: SizedBox(
                    height: 90,
                    child: UpPanelSkeleton(),
                  ));
                }
              },
            ),
            FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data == null) {
                    return const SliverToBoxAdapter(child: SizedBox());
                  }
                  Map? data = snapshot.data;
                  if (data != null && data['status']) {
                    List<DynamicItemModel> list =
                        _dynamicsController.dynamicsList;
                    return Obx(
                      () {
                        if (list.isEmpty) {
                          if (_dynamicsController.isLoadingDynamic.value) {
                            return skeleton();
                          } else {
                            return const NoData();
                          }
                        } else {
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return _centerContent(
                                  context,
                                  DynamicPanel(item: list[index]),
                                );
                              },
                              childCount: list.length,
                            ),
                          );
                        }
                      },
                    );
                  } else {
                    return HttpError(
                      errMsg: data?['msg'] ?? '请求异常',
                      btnText: data?['code'] == -101 ? '去登录' : null,
                      fn: () {
                        if (data?['code'] == -101) {
                          RoutePush.loginRedirectPush();
                        } else {
                          setState(() {
                            _futureBuilderFuture =
                                _dynamicsController.queryFollowDynamic();
                            _futureBuilderFutureUp =
                                _dynamicsController.queryFollowUp();
                          });
                        }
                      },
                    );
                  }
                } else {
                  // 骨架屏
                  return skeleton();
                }
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40))
          ],
        ),
      ),
    );
  }

  Widget skeleton() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _centerContent(context, const DynamicCardSkeleton());
      }, childCount: 5),
    );
  }

  Widget _centerContent(BuildContext context, Widget child) {
    return Center(
      child: SizedBox(
        width: Responsive.dynamicsContentWidth(context),
        child: child,
      ),
    );
  }
}

class _DynamicTypeTab extends StatelessWidget {
  const _DynamicTypeTab({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fontSize = Theme.of(context).textTheme.labelMedium?.fontSize;
    return SizedBox(
      height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: selected ? 16 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}
