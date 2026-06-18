import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/features/user/presentation/member_controller.dart';
import 'package:pilipala/features/user/presentation/widgets/coins.dart';
import 'package:pilipala/features/user/presentation/widgets/likes.dart';
import 'package:pilipala/features/user/presentation/widgets/seasons.dart';
import 'package:pilipala/models/member/info.dart';
import 'package:pilipala/utils/utils.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  late MemberController _memberController;
  late Future _futureBuilderFuture;
  late int mid;
  late String heroTag;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _futureBuilderFuture = _memberController.loadMember();
  }

  @override
  void dispose() {
    Get.delete<MemberController>(tag: heroTag);
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _futureBuilderFuture = _memberController.loadMember();
    });
    await _futureBuilderFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == null || snapshot.data['status'] != true) {
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Text(
                      '个人空间',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  HttpError(
                    errMsg: _memberController.error.value,
                    fn: _onRefresh,
                  ),
                ],
              );
            }
            return Obx(
              () {
                final MemberInfoModel? info =
                    _memberController.memberInfo.value;
                if (info == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return CustomScrollView(
                  controller: _memberController.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    _MemberHeader(
                      info: info,
                      stat: _memberController.memberStat,
                      onFollow: _memberController.toggleFollow,
                    ),
                    SliverToBoxAdapter(
                      child: _MemberEntrances(mid: mid, info: info),
                    ),
                    SliverToBoxAdapter(
                      child: SeasonsWidget(
                        mid: mid,
                        seasons: _memberController.seasons,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: CoinsWidget(
                        mid: mid,
                        coins: _memberController.coins,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: LikesWidget(
                        mid: mid,
                        likes: _memberController.likes,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({
    required this.info,
    required this.stat,
    required this.onFollow,
  });

  final MemberInfoModel info;
  final Map stat;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    final String topPhoto = info.topPhoto ?? '';
    final String name = info.name ?? '';
    final String encodedName = Uri.encodeComponent(name);
    final bool isFollowed = info.isFollowed ?? false;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 350,
      title: Text(
        name,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: [
        IconButton(
          onPressed: () =>
              Get.toNamed('/memberSearch?mid=${info.mid}&uname=$encodedName'),
          icon: const Icon(Icons.search_outlined),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (topPhoto.isNotEmpty)
                  NetworkImgLayer(
                    src: topPhoto,
                    width: constraints.maxWidth,
                    height: 180,
                  )
                else
                  Container(
                      color: Theme.of(context).colorScheme.surfaceContainer),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.surface.withAlpha(20),
                        Theme.of(context).colorScheme.surface,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 118, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Hero(
                              tag: Utils.makeHeroTag(info.mid),
                              child: CircleAvatar(
                                radius: 42,
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                backgroundImage: info.face == null
                                    ? null
                                    : NetworkImage(info.face!),
                              ),
                            ),
                            const Spacer(),
                            _StatItem(label: '关注', value: stat['following']),
                            _StatItem(label: '粉丝', value: stat['follower']),
                            _StatItem(
                                label: '动态', value: stat['dynamic_count']),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (info.level != null) ...[
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/images/lv/lv${min(info.level!, 6)}.png',
                                height: 16,
                              ),
                            ],
                            if (info.vip?.status == 1) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  info.vip?.label?['text'] ?? '大会员',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if ((info.official?['title'] ?? '')
                            .toString()
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${info.official?['desc'] ?? '认证'}：${info.official?['title']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            info.sign ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: onFollow,
                                child: Text(isFollowed ? '已关注' : '关注'),
                              ),
                            ),
                            if (info.liveRoom?.liveStatus == 1) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => Get.toNamed(
                                      '/liveRoom?roomid=${info.liveRoom?.roomId}'),
                                  child: const Text('进入直播间'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: label == '关注'
          ? () => Get.toNamed('/follow?mid=${Get.parameters['mid']}')
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          children: [
            Text(
              Utils.numFormat(value),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

class _MemberEntrances extends StatelessWidget {
  const _MemberEntrances({required this.mid, required this.info});

  final int mid;
  final MemberInfoModel info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          _EntranceButton(
            icon: Icons.dynamic_feed_outlined,
            label: '动态',
            onTap: () => Get.toNamed('/memberDynamics?mid=$mid'),
          ),
          const SizedBox(width: 12),
          _EntranceButton(
            icon: Icons.video_library_outlined,
            label: '投稿',
            onTap: () => Get.toNamed('/memberArchive?mid=$mid'),
          ),
          const SizedBox(width: 12),
          _EntranceButton(
            icon: Icons.article_outlined,
            label: '专栏',
            onTap: () => Get.toNamed(
              '/memberArticle?mid=$mid&name=${Uri.encodeComponent(info.name ?? '')}',
            ),
          ),
        ],
      ),
    );
  }
}

class _EntranceButton extends StatelessWidget {
  const _EntranceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19),
              const SizedBox(width: StyleString.safeSpace / 2),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
