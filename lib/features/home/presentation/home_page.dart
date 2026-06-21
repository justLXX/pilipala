import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/network_img_layer.dart';
import 'package:pilipala/features/home/presentation/home_controller.dart';
import 'package:pilipala/features/home/presentation/hot_page.dart';
import 'package:pilipala/features/home/presentation/rcmd_page.dart';
import 'package:pilipala/utils/storage.dart';

/// HomePage displays the home page with tabs.
///
/// This is the migrated version using the new architecture.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final HomeController _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = Get.find<HomeController>();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const ClampingScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              forceElevated: innerBoxIsScrolled,
              toolbarHeight: 62,
              titleSpacing: 14,
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: GestureDetector(
                onTap: () {
                  final keyword = _homeController.defaultSearch.value;
                  Get.toNamed(
                    '/search',
                    parameters:
                        keyword.isNotEmpty ? {'hintKeyword': keyword} : null,
                  );
                },
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search,
                          size: 20,
                          color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Obx(
                          () => Text(
                            _homeController.defaultSearch.value.isEmpty
                                ? '搜索视频、UP 主或番剧'
                                : _homeController.defaultSearch.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () {
                      if (!_homeController.userLogin.value) {
                        Get.toNamed('/loginPage', preventDuplicates: false);
                        return;
                      }
                      final userInfo = GStrorage.userInfo.get('userInfoCache');
                      final mid = userInfo?.mid;
                      if (mid != null) {
                        Get.toNamed('/member?mid=$mid');
                      }
                    },
                    child: Obx(
                      () => ClipOval(
                        child: _homeController.userFace.value.isEmpty
                            ? Image.asset(
                                'assets/images/noface.jpeg',
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                              )
                            : NetworkImgLayer(
                                src: _homeController.userFace.value,
                                width: 38,
                                height: 38,
                                type: 'avatar',
                              ),
                      ),
                    ),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor: Theme.of(context).colorScheme.outline,
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      _HomeTab(text: '推荐'),
                      _HomeTab(text: '热门'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            RcmdPage(),
            HotPage(),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 36,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text(text),
      ),
    );
  }
}
