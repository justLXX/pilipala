import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/common/constants.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/common/widgets/stat/danmu.dart';
import 'package:pilipala/common/widgets/stat/view.dart';
import 'package:pilipala/models/video_detail_res.dart';
import 'package:pilipala/features/video/presentation/introduction/intro_controller.dart';
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/utils/id_utils.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/utils.dart';
import 'package:pilipala/utils/navigation_helper.dart';

class VideoIntroPanel extends StatefulWidget {
  final String bvid;
  final String? cid;

  const VideoIntroPanel({super.key, required this.bvid, this.cid});

  @override
  State<VideoIntroPanel> createState() => _VideoIntroPanelState();
}

class _VideoIntroPanelState extends State<VideoIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late String heroTag;
  late VideoIntroController videoIntroController;
  VideoDetailData? videoDetail;
  late Future? _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    heroTag = Get.arguments['heroTag'];
    videoIntroController =
        Get.put(VideoIntroController(bvid: widget.bvid), tag: heroTag);
    _futureBuilderFuture = videoIntroController.queryVideoIntro();
    videoIntroController.videoDetail.listen((value) {
      videoDetail = value;
    });
  }

  @override
  void dispose() {
    videoIntroController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: _futureBuilderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const SliverToBoxAdapter(child: SizedBox());
          }
          if (snapshot.data['status']) {
            return Obx(
              () => VideoInfo(
                videoDetail: videoIntroController.videoDetail.value,
                heroTag: heroTag,
                bvid: widget.bvid,
              ),
            );
          } else {
            return HttpError(
              errMsg: snapshot.data['msg'],
              btnText: snapshot.data['code'] == -404 ||
                      snapshot.data['code'] == 62002
                  ? '返回上一页'
                  : null,
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

class VideoInfo extends StatefulWidget {
  final VideoDetailData? videoDetail;
  final String? heroTag;
  final String bvid;

  const VideoInfo({
    Key? key,
    this.videoDetail,
    this.heroTag,
    required this.bvid,
  }) : super(key: key);

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> {
  late String heroTag;
  late final VideoIntroController videoIntroController;
  late final VideoDetailController videoDetailCtr;
  final Box<dynamic> localCache = GStrorage.localCache;
  final Box<dynamic> setting = GStrorage.setting;
  late final dynamic owner;
  late int mid;
  late String memberHeroTag;
  bool isProcessing = false;
  RxBool isExpand = false.obs;
  late ExpandableController _expandableCtr;

  @override
  void initState() {
    super.initState();
    heroTag = widget.heroTag!;
    videoIntroController = Get.find<VideoIntroController>(tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    owner = widget.videoDetail!.owner;
    mid = owner != null ? owner!.mid : 0;
    memberHeroTag = Utils.makeHeroTag(mid);
    _expandableCtr = ExpandableController(initialExpanded: false);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            _buildStats(),
            _buildOwner(),
            _buildActions(),
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
        widget.videoDetail!.title!,
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
            view: widget.videoDetail!.stat!.view,
          ),
          const SizedBox(width: 10),
          StatDanMu(
            danmu: widget.videoDetail!.stat!.danmaku,
          ),
          const SizedBox(width: 10),
          Text(
            Utils.dateFormat(widget.videoDetail!.pubdate!),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(
                '/member?mid=$mid',
                arguments: {'face': owner!.face},
              );
            },
            child: Hero(
              tag: memberHeroTag,
              child: NetworkImgLayer(
                src: owner!.face,
                width: 36,
                height: 36,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner!.name!,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${videoIntroController.follower.value} 粉丝',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          if (videoIntroController.userLogin)
            Obx(
              () => TextButton(
                onPressed: () => videoIntroController.actionFollow(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Text(
                  videoIntroController.followStatus['attribute'] != null &&
                          videoIntroController.followStatus['attribute'] != 0
                      ? '已关注'
                      : '关注',
                ),
              ),
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
          Obx(
            () => _buildActionItem(
              icon: FaIcon(
                FontAwesomeIcons.thumbsUp,
                size: 20,
                color: videoIntroController.hasLike.value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              text: Utils.numFormat(widget.videoDetail!.stat!.like),
              onTap: () => videoIntroController.actionLike(),
            ),
          ),
          _buildActionItem(
            icon: FaIcon(
              FontAwesomeIcons.coins,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: Utils.numFormat(widget.videoDetail!.stat!.coin),
            onTap: () {},
          ),
          _buildActionItem(
            icon: FaIcon(
              FontAwesomeIcons.star,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: Utils.numFormat(widget.videoDetail!.stat!.favorite),
            onTap: () {},
          ),
          _buildActionItem(
            icon: Icon(
              Icons.share_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            text: '分享',
            onTap: () => videoIntroController.actionShare(),
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

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: ExpandablePanel(
        controller: _expandableCtr,
        header: Text(
          '简介',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        collapsed: Text(
          widget.videoDetail!.desc!,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        expanded: Text(
          widget.videoDetail!.desc!,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        theme: const ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          tapBodyToExpand: true,
          tapBodyToCollapse: true,
        ),
      ),
    );
  }
}
