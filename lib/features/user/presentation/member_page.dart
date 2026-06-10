import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/features/user/presentation/user_controller.dart';
import 'package:pilipala/features/user/presentation/widgets/profile.dart';
import 'package:pilipala/features/user/presentation/widgets/seasons.dart';
import 'package:pilipala/features/user/presentation/widgets/coins.dart';
import 'package:pilipala/features/user/presentation/widgets/likes.dart';

/// MemberPage displays the user profile page.
///
/// This is the migrated version using the new architecture.
class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage>
    with SingleTickerProviderStateMixin {
  late String heroTag;
  late UserController _userController;
  late Future _futureBuilderFuture;
  late Future _memberSeasonsFuture;
  late Future _memberCoinsFuture;
  late Future _memberLikeFuture;
  final ScrollController _extendNestCtr = ScrollController();
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    _userController = Get.find<UserController>();
    _futureBuilderFuture = _userController.loadUserInfo(mid: mid);
    _memberSeasonsFuture = _userController.loadUserStat(mid: mid);
    _memberCoinsFuture = _userController.loadUserCoins(mid: mid);
    _memberLikeFuture = _userController.loadUserLikes(mid: mid);
    _userController.loadUserSeasons(mid: mid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Obx(
              () {
                if (_userController.userInfo != null) {
                  return CustomScrollView(
                    controller: _extendNestCtr,
                    slivers: [
                      SliverToBoxAdapter(
                        child: ProfileWidget(
                          userInfo: _userController.userInfo!,
                          userStat: _userController.userStat,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SeasonsWidget(
                          seasons: _userController.userSeasons,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: CoinsWidget(
                          coins: _userController.userCoins,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: LikesWidget(
                          likes: _userController.userLikes,
                        ),
                      ),
                    ],
                  );
                } else if (_userController.error.isNotEmpty) {
                  return HttpError(
                    errMsg: _userController.error,
                    fn: () {
                      setState(() {
                        _futureBuilderFuture =
                            _userController.loadUserInfo(mid: mid);
                      });
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
