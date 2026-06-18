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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 372,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
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
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 220,
                  child: topPhoto.isNotEmpty
                      ? NetworkImgLayer(
                          src: topPhoto,
                          width: constraints.maxWidth,
                          height: 220,
                          quality: 40,
                        )
                      : Container(color: colorScheme.surfaceContainer),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface.withAlpha(12),
                        colorScheme.surface.withAlpha(220),
                        colorScheme.surface,
                      ],
                      stops: const [0, 0.55, 0.78],
                    ),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 124, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Hero(
                                  tag: Utils.makeHeroTag(info.mid),
                                  child: Container(
                                    width: 86,
                                    height: 86,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          colorScheme.surfaceContainerHighest,
                                      backgroundImage: info.face == null
                                          ? null
                                          : NetworkImage(info.face!),
                                    ),
                                  ),
                                ),
                                if (info.liveRoom?.liveStatus == 1)
                                  Positioned(
                                    left: 8,
                                    right: 8,
                                    bottom: -8,
                                    child: Container(
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '直播中',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () =>
                                  Get.toNamed('/follow?mid=${info.mid}'),
                              borderRadius: BorderRadius.circular(8),
                              child: _StatItem(
                                label: '关注',
                                value: stat['following'],
                              ),
                            ),
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
                              child: FilledButton(
                                onPressed: onFollow,
                                child: Text(isFollowed ? '已关注' : '关注'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.tonal(
                                onPressed: info.liveRoom?.liveStatus == 1
                                    ? () => Get.toNamed(
                                          '/liveRoom?roomid=${info.liveRoom?.roomId}',
                                        )
                                    : () => Get.toNamed(
                                          '/whisperDetail',
                                          parameters: {
                                            'talkerId': info.mid.toString(),
                                            'name': info.name ?? '',
                                            'face': info.face ?? '',
                                            'mid': info.mid.toString(),
                                            'heroTag':
                                                Utils.makeHeroTag(info.mid),
                                          },
                                        ),
                                child: Text(
                                  info.liveRoom?.liveStatus == 1
                                      ? '进入直播间'
                                      : '发消息',
                                ),
                              ),
                            ),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          Text(
            Utils.numFormat(value),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(
              colorScheme.brightness == Brightness.dark ? 110 : 150,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: colorScheme.primary),
              const SizedBox(width: StyleString.safeSpace / 2),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
