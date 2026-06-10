import 'package:get/get.dart';
import 'package:pilipala/features/user/domain/user_use_cases.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/models/user/stat.dart';
import 'package:pilipala/models/member/coin.dart';
import 'package:pilipala/models/member/like.dart';
import 'package:pilipala/models/member/seasons.dart';

/// Controller for the user feature.
///
/// Manages the state for user-related operations including
/// user info, statistics, and follow/unfollow actions.
class UserController extends GetxController {
  // Dependencies
  late final GetUserInfoUseCase _getUserInfo;
  late final GetUserStatUseCase _getUserStat;
  late final FollowUserUseCase _followUser;
  late final GetUserCoinsUseCase _getUserCoins;
  late final GetUserLikesUseCase _getUserLikes;
  late final GetUserSeasonsUseCase _getUserSeasons;

  // State
  final Rx<UserInfoData?> _userInfo = Rx<UserInfoData?>(null);
  final Rx<UserStat?> _userStat = Rx<UserStat?>(null);
  final RxList<MemberCoinsDataModel> _userCoins = <MemberCoinsDataModel>[].obs;
  final RxList<MemberLikeDataModel> _userLikes = <MemberLikeDataModel>[].obs;
  final RxList<MemberSeasonsList> _userSeasons = <MemberSeasonsList>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isFollowing = false.obs;
  final RxString _error = ''.obs;

  // Getters
  UserInfoData? get userInfo => _userInfo.value;
  UserStat? get userStat => _userStat.value;
  List<MemberCoinsDataModel> get userCoins => _userCoins;
  List<MemberLikeDataModel> get userLikes => _userLikes;
  List<MemberSeasonsList> get userSeasons => _userSeasons;
  bool get isLoading => _isLoading.value;
  bool get isFollowing => _isFollowing.value;
  String get error => _error.value;

  UserController({
    GetUserInfoUseCase? getUserInfo,
    GetUserStatUseCase? getUserStat,
    FollowUserUseCase? followUser,
    GetUserCoinsUseCase? getUserCoins,
    GetUserLikesUseCase? getUserLikes,
    GetUserSeasonsUseCase? getUserSeasons,
  }) {
    _getUserInfo = getUserInfo ?? GetUserInfoUseCase();
    _getUserStat = getUserStat ?? GetUserStatUseCase();
    _followUser = followUser ?? FollowUserUseCase();
    _getUserCoins = getUserCoins ?? GetUserCoinsUseCase();
    _getUserLikes = getUserLikes ?? GetUserLikesUseCase();
    _getUserSeasons = getUserSeasons ?? GetUserSeasonsUseCase();
  }

  /// Load user information.
  Future<void> loadUserInfo({int? mid}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final userInfo = await _getUserInfo.execute(mid: mid);
      _userInfo.value = userInfo;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load user statistics.
  Future<void> loadUserStat({required int mid}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final userStat = await _getUserStat.execute(mid: mid);
      _userStat.value = userStat;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Follow or unfollow a user.
  Future<void> toggleFollow({required int mid}) async {
    try {
      await _followUser.execute(
        mid: mid,
        follow: !_isFollowing.value,
      );
      _isFollowing.value = !_isFollowing.value;
    } catch (e) {
      _error.value = e.toString();
    }
  }

  /// Load user's recent coin videos.
  Future<void> loadUserCoins({required int mid}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final coins = await _getUserCoins.execute(mid: mid);
      _userCoins.value = coins;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load user's recent liked videos.
  Future<void> loadUserLikes({required int mid}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final likes = await _getUserLikes.execute(mid: mid);
      _userLikes.value = likes;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load user's seasons.
  Future<void> loadUserSeasons({required int mid}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final seasons = await _getUserSeasons.execute(mid: mid);
      _userSeasons.value = seasons.seasonsList ?? [];
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }
}
