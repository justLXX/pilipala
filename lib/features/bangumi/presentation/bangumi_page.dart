import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/features/bangumi/presentation/bangumi_controller.dart';
import 'package:pilipala/pages/bangumi/widgets/bangumu_card_v.dart';
import 'package:pilipala/utils/main_stream.dart';

class BangumiPage extends StatefulWidget {
  const BangumiPage({super.key});

  @override
  State<BangumiPage> createState() => _BangumiPageState();
}

class _BangumiPageState extends State<BangumiPage>
    with AutomaticKeepAliveClientMixin {
  final BangumiController _bangumidController = Get.put(BangumiController());
  late Future? _futureBuilderFuture;
  late Future? _futureBuilderFutureFollow;
  late ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    scrollController = _bangumidController.scrollController;
    _futureBuilderFuture = _bangumidController.queryBangumiListFeed();
    _futureBuilderFutureFollow = _bangumidController.queryBangumiFollow();
    scrollController.addListener(
      () async {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle('my-throttler', const Duration(seconds: 1), () {
            _bangumidController.isLoadingMore = true;
            _bangumidController.onLoad();
          });
        }
        handleScrollEvent(scrollController);
      },
    );
  }

  @override
  void dispose() {
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async {
        await _bangumidController.queryBangumiListFeed();
        return _bangumidController.queryBangumiFollow();
      },
      child: CustomScrollView(
        controller: _bangumidController.scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Obx(
              () => Visibility(
                visible: _bangumidController.userLogin.value,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: StyleString.safeSpace, bottom: 10, left: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '最近追番',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _futureBuilderFutureFollow =
                                    _bangumidController.queryBangumiFollow();
                              });
                            },
                            icon: const Icon(
                              Icons.refresh,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.size.width / 3 / 0.75 +
                          MediaQuery.textScalerOf(context).scale(50.0),
                      child: FutureBuilder(
                        future: _futureBuilderFutureFollow,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.data == null) {
                              return const SizedBox();
                            }
                            if (snapshot.data['status']) {
                              return Obx(
                                () => _bangumidController
                                        .bangumiFollowList.isNotEmpty
                                    ? ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _bangumidController
                                            .bangumiFollowList.length,
                                        itemBuilder: (context, index) {
                                          return BangumiCardV(
                                            bangumiItem: _bangumidController
                                                .bangumiFollowList[index],
                                          );
                                        },
                                      )
                                    : const SizedBox(),
                              );
                            } else {
                              return const SizedBox();
                            }
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: StyleString.safeSpace, bottom: 10, left: 16),
              child: Text(
                '番剧',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          FutureBuilder(
            future: _futureBuilderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == null) {
                  return const SliverToBoxAdapter(child: SizedBox());
                }
                if (snapshot.data['status']) {
                  return Obx(
                    () => _bangumidController.bangumiList.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return BangumiCardV(
                                  bangumiItem:
                                      _bangumidController.bangumiList[index],
                                );
                              },
                              childCount:
                                  _bangumidController.bangumiList.length,
                            ),
                          )
                        : const SliverToBoxAdapter(child: SizedBox()),
                  );
                } else {
                  return HttpError(
                    errMsg: snapshot.data['msg'],
                    fn: () {},
                  );
                }
              } else {
                return const SliverToBoxAdapter(child: SizedBox());
              }
            },
          ),
        ],
      ),
    );
  }
}
