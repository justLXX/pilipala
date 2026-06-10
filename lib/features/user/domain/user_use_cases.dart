import 'package:get/get.dart';
import 'package:pilipala/features/user/data/user_repository.dart';
import 'package:pilipala/models/user/info.dart';
import 'package:pilipala/models/user/stat.dart';
import 'package:pilipala/models/member/coin.dart';
import 'package:pilipala/models/member/like.dart';
import 'package:pilipala/models/member/seasons.dart';

/// Use case for getting user information.
class GetUserInfoUseCase {
  final UserRepository _repository;

  GetUserInfoUseCase({UserRepository? repository})
      : _repository = repository ?? Get.find<UserRepository>();

  /// Execute the use case.
  Future<UserInfoData> execute({int? mid}) async {
    final response = await _repository.getUserInfo(mid: mid);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load user info');
  }
}

/// Use case for getting user statistics.
class GetUserStatUseCase {
  final UserRepository _repository;

  GetUserStatUseCase({UserRepository? repository})
      : _repository = repository ?? Get.find<UserRepository>();

  /// Execute the use case.
  Future<UserStat> execute({required int mid}) async {
    final response = await _repository.getUserStat(mid: mid);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load user stats');
  }
}

/// Use case for following/unfollowing a user.
class FollowUserUseCase {
  final UserRepository _repository;

  FollowUserUseCase({UserRepository? repository})
      : _repository = repository ?? Get.find<UserRepository>();

  /// Execute the use case.
  Future<void> execute({
    required int mid,
    required bool follow,
  }) async {
    final response = await _repository.followUser(
      mid: mid,
      follow: follow,
    );

    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to follow user');
    }
  }
}

/// Use case for getting user's recent coin videos.
class GetUserCoinsUseCase {
  final UserRepository _repository;

  GetUserCoinsUseCase({UserRepository? repository})
      : _repository = repository ?? Get.find<UserRepository>();

  /// Execute the use case.
  Future<List<MemberCoinsDataModel>> execute({required int mid}) async {
    final response = await _repository.getUserCoins(mid: mid);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load user coins');
  }
}

/// Use case for getting user's recent liked videos.
class GetUserLikesUseCase {
  final UserRepository _repository;

  GetUserLikesUseCase({UserRepository? repository})
      : _repository = repository ?? Get.find<UserRepository>();

  /// Execute the use case.
  Future<List<MemberLikeDataModel>> execute({required int mid}) async {
    final response = await _repository.getUserLikes(mid: mid);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load user likes');
  }
}

/// Use case for getting user's seasons.
class GetUserSeasonsUseCase {
  final UserRepository _repository;

  GetUserSeasonsUseCase({UserRepository? repository})
      : _repository = repository ?? Get.find<UserRepository>();

  /// Execute the use case.
  Future<MemberSeasonsDataModel> execute({
    required int mid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getUserSeasons(
      mid: mid,
      page: page,
      pageSize: pageSize,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load user seasons');
  }
}
