import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/rank/presentation/rank_controller.dart';
import 'package:pilipala/features/rank/presentation/widgets/rank_zone_tab.dart';
import 'package:pilipala/utils/feed_back.dart';
import 'package:universal_platform/universal_platform.dart';

/// Ranking page — displays zone-based video rankings via a TabBar.
///
/// This is the migrated version using the new features/ architecture.
/// It replaces `lib/pages/rank/view.dart`.
class RankPage extends StatefulWidget {
  const RankPage({Key? key}) : super(key: key);

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage>
    with AutomaticKeepAliveClientMixin {
  late final RankController _rankController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _rankController = Get.find<RankController>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: (!kIsWeb && UniversalPlatform.isAndroid)
            ? SystemUiOverlayStyle(
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
              )
            : Theme.of(context).brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          const _SafeAreaSpacer(),
          if (_rankController.tabs.length > 1) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: Align(
                alignment: Alignment.center,
                child: TabBar(
                  controller: _rankController.tabController,
                  tabs: [
                    for (var tab in _rankController.tabs)
                      Tab(text: tab['label'] as String)
                  ],
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  enableFeedback: true,
                  splashBorderRadius: BorderRadius.circular(10),
                  tabAlignment: TabAlignment.center,
                  onTap: (value) {
                    feedBack();
                    if (_rankController.initialIndex.value == value) {
                      _rankController.animateToTop();
                    }
                    _rankController.initialIndex.value = value;
                  },
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
          ],
          Expanded(
            child: TabBarView(
              controller: _rankController.tabController,
              children: [
                for (var tab in _rankController.tabs)
                  RankZoneTab(rid: tab['rid'] as int)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Spacer that accounts for the device safe-area top padding.
class _SafeAreaSpacer extends StatelessWidget implements PreferredSizeWidget {
  const _SafeAreaSpacer();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;
    return Container(
      width: MediaQuery.of(context).size.width,
      height: top,
      color: Colors.transparent,
    );
  }
}
