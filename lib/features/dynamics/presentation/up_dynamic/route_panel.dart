import 'package:easy_debounce/easy_throttle.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/models/dynamics/up.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:pilipala/features/dynamics/presentation/dynamics_controller.dart';
import 'index.dart';

class UpDynamicsPage extends StatefulWidget {
  final DynamicsController ctr;
  final UpItem upInfo;

  const UpDynamicsPage({super.key, required this.ctr, required this.upInfo});

  @override
  State<UpDynamicsPage> createState() => _UpDynamicsPageState();
}

class _UpDynamicsPageState extends State<UpDynamicsPage>
    with SingleTickerProviderStateMixin {
  static const itemPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 0);
  final PageController pageController = PageController();
  late double contentWidth = 50;
  late List<UpItem> upList;
  late RxInt currentMid = (-1).obs;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    upList = widget.ctr.upData.value.upList!
        .map<UpItem>((element) => element)
        .toList();
    upList.removeAt(0);
    _tabController = TabController(length: upList.length, vsync: this);

    currentMid.value = widget.upInfo.mid!;

    pageController.addListener(() {
      int index = pageController.page!.round();
      int mid = upList[index].mid!;
      if (mid != currentMid.value) {
        currentMid.value = mid;
        _tabController?.animateTo(index,
            duration: Duration.zero, curve: Curves.linear);
        onClickUp(upList[index], index, type: 'pageChange');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      int index =
          upList.indexWhere((element) => element.mid == widget.upInfo.mid);
      pageController.jumpToPage(index);
      onClickUp(widget.upInfo, index);
      _tabController?.animateTo(index,
          duration: Duration.zero, curve: Curves.linear);
      onClickUp(upList[index], index, type: 'pageChange');
    });
  }

  void onClickUp(data, i, {type = 'click'}) {
    if (type == 'click') {
      pageController.jumpToPage(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Text(
          '${widget.upInfo.uname}的动态',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              automaticIndicatorColorAdjustment: false,
              tabAlignment: TabAlignment.start,
              padding: const EdgeInsets.only(left: 12, right: 12),
              indicatorPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: const BoxDecoration(),
              labelPadding: itemPadding,
              indicatorWeight: 1,
              isScrollable: true,
              tabs: upList.map((e) => Tab(child: upItemBuild(e))).toList(),
              onTap: (index) {
                feedBack();
                EasyThrottle.throttle(
                    'follow', const Duration(milliseconds: 200), () {
                  onClickUp(upList[index], index);
                });
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: upList.length,
              controller: pageController,
              itemBuilder: (BuildContext context, int index) {
                return UpDyanmicsPage(upInfo: upList[index], ctr: widget.ctr);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget upItemBuild(data) {
    return Obx(
      () => AnimatedOpacity(
        opacity: currentMid == data.mid ? 1 : 0.3,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: currentMid == data.mid ? 1 : 0.9,
          child: NetworkImgLayer(
            width: contentWidth,
            height: contentWidth,
            src: data.face,
            type: 'avatar',
          ),
        ),
      ),
    );
  }
}
