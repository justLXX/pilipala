import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:pilipala/utils/navigation_helper.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/common/widgets/stat/danmu.dart';
import 'package:pilipala/common/widgets/stat/view.dart';
import 'package:pilipala/models/bangumi/info.dart';
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/id_utils.dart';
import 'package:pilipala/utils/storage.dart';
import 'bangumi_intro_controller.dart';

class BangumiIntroPanel extends StatefulWidget {
  final int? cid;
  const BangumiIntroPanel({
    Key? key,
    this.cid,
  }) : super(key: key);

  @override
  State<BangumiIntroPanel> createState() => _BangumiIntroPanelState();
}

class _BangumiIntroPanelState extends State<BangumiIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late BangumiIntroController bangumiIntroController;
  late VideoDetailController videoDetailCtr;
  BangumiInfoModel? bangumiDetail;
  late Future _futureBuilderFuture;
  late int cid;
  late String heroTag;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    heroTag = Get.arguments['heroTag'];
    cid = widget.cid!;
    bangumiIntroController = Get.put(BangumiIntroController(), tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    _futureBuilderFuture = bangumiIntroController.queryBangumiIntro();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const SliverToBoxAdapter(child: SizedBox());
          }
          if (snapshot.data['status']) {
            return Obx(
              () => BangumiInfo(
                bangumiDetail: bangumiIntroController.bangumiDetail.value,
                cid: cid,
              ),
            );
          } else {
            return HttpError(
              errMsg: snapshot.data['msg'],
              fn: () => safeBack(),
            );
          }
        } else {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}

class BangumiInfo extends StatefulWidget {
  final BangumiInfoModel? bangumiDetail;
  final int? cid;

  const BangumiInfo({
    Key? key,
    this.bangumiDetail,
    this.cid,
  }) : super(key: key);

  @override
  State<BangumiInfo> createState() => _BangumiInfoState();
}

class _BangumiInfoState extends State<BangumiInfo> {
  late BangumiIntroController bangumiIntroController;
  late VideoDetailController videoDetailCtr;
  final Box<dynamic> localCache = GStrorage.localCache;
  final Box<dynamic> setting = GStrorage.setting;
  late int currentCid;

  @override
  void initState() {
    super.initState();
    final String heroTag = Get.arguments['heroTag'];
    bangumiIntroController = Get.find<BangumiIntroController>(tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    currentCid = widget.cid ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bangumiDetail == null) {
      return const SizedBox();
    }
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            _buildStats(),
            _buildActions(),
            _buildEpisodes(),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Text(
        widget.bangumiDetail!.title ?? '',
        style: Theme.of(context).textTheme.titleMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          StatView(
            view: widget.bangumiDetail!.stat?['view'],
          ),
          const SizedBox(width: 10),
          StatDanMu(
            danmu: widget.bangumiDetail!.stat?['danmaku'],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(
            icon: FaIcon(
              FontAwesomeIcons.thumbsUp,
              size: 20,
              color: bangumiIntroController.hasLike.value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            text: '${widget.bangumiDetail!.stat?['like'] ?? 0}',
            onTap: () => bangumiIntroController.actionLike(),
          ),
          _buildActionItem(
            icon: FaIcon(
              FontAwesomeIcons.coins,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: '${widget.bangumiDetail!.stat?['coin'] ?? 0}',
            onTap: () {},
          ),
          _buildActionItem(
            icon: FaIcon(
              FontAwesomeIcons.star,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: '${widget.bangumiDetail!.stat?['favorite'] ?? 0}',
            onTap: () {},
          ),
          _buildActionItem(
            icon: Icon(
              Icons.share_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: '分享',
            onTap: () => bangumiIntroController.actionShare(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选集',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (widget.bangumiDetail!.episodes != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.bangumiDetail!.episodes!.map((ep) {
                bool isPlaying = ep.id == currentCid;
                return GestureDetector(
                  onTap: () {
                    feedBack();
                    videoDetailCtr.cid = ep.id!;
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${ep.title}',
                        style: TextStyle(
                          color: isPlaying
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '简介',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            widget.bangumiDetail!.evaluate ?? '',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
