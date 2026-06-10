import 'package:get/get.dart';
import 'package:pilipala/features/home/data/video_repository.dart' as home_repo;
import 'package:pilipala/features/login/data/login_repository.dart' as login_repo;
import 'package:pilipala/features/search/data/search_repository.dart';
import 'package:pilipala/features/user/data/user_repository.dart' as user_repo;
import 'package:pilipala/features/home/domain/video_use_cases.dart'
    hide LikeVideoUseCase;
import 'package:pilipala/features/login/domain/login_use_cases.dart';
import 'package:pilipala/features/search/domain/search_use_cases.dart';
import 'package:pilipala/features/user/domain/user_use_cases.dart';
import 'package:pilipala/features/home/presentation/home_controller.dart'
    as home_ctrl;
import 'package:pilipala/features/login/presentation/login_controller.dart'
    as login_ctrl;
import 'package:pilipala/features/video/presentation/video_detail_controller.dart';
import 'package:pilipala/features/search/presentation/search_controller.dart';
import 'package:pilipala/features/user/presentation/user_controller.dart';
import 'package:pilipala/features/media/data/media_repository.dart' as media_repo;
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/features/media/presentation/media_controller.dart' as media_ctrl;
import 'package:pilipala/features/dynamics/data/dynamics_repository.dart' as dynamics_repo;
import 'package:pilipala/features/dynamics/domain/dynamics_use_cases.dart';
import 'package:pilipala/features/dynamics/presentation/dynamics_controller.dart' as dynamics_ctrl;
import 'package:pilipala/features/rank/data/rank_repository.dart' as rank_repo;
import 'package:pilipala/features/rank/domain/rank_use_cases.dart';
import 'package:pilipala/features/rank/presentation/rank_controller.dart' as rank_ctrl;

/// Bindings for the home feature route.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<home_repo.VideoRepository>(() => home_repo.VideoRepository());
    Get.lazyPut<GetRecommendedVideosUseCase>(
        () => GetRecommendedVideosUseCase());
    Get.lazyPut<GetHotVideosUseCase>(() => GetHotVideosUseCase());
    Get.lazyPut<home_ctrl.HomeController>(() => home_ctrl.HomeController());
  }
}

/// Bindings for the login feature route.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<login_repo.LoginRepository>(
        () => login_repo.LoginRepository());
    Get.lazyPut<GetCaptchaUseCase>(() => GetCaptchaUseCase());
    Get.lazyPut<GetWebKeyUseCase>(() => GetWebKeyUseCase());
    Get.lazyPut<EncryptPasswordUseCase>(() => EncryptPasswordUseCase());
    Get.lazyPut<LoginByPasswordUseCase>(() => LoginByPasswordUseCase());
    Get.lazyPut<LoginBySmsCodeUseCase>(() => LoginBySmsCodeUseCase());
    Get.lazyPut<SendSmsCodeUseCase>(() => SendSmsCodeUseCase());
    Get.lazyPut<QrCodeLoginUseCase>(() => QrCodeLoginUseCase());
    Get.lazyPut<login_ctrl.LoginController>(() => login_ctrl.LoginController());
  }
}

/// Bindings for the video detail feature route.
/// 注意：VideoDetailController 由页面自行使用 Get.put + tag 注册，
/// 此处不再注册，避免同路由跳转时 controller 冲突。
class VideoDetailBinding extends Bindings {
  @override
  void dependencies() {}
}

/// Bindings for the search feature route.
class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchRepository>(() => SearchRepository());
    Get.lazyPut<GetHotSearchUseCase>(() => GetHotSearchUseCase());
    Get.lazyPut<SearchContentUseCase>(() => SearchContentUseCase());
    Get.lazyPut<GetSearchSuggestionsUseCase>(
        () => GetSearchSuggestionsUseCase());
    Get.lazyPut<PiliSearchController>(() => PiliSearchController());
  }
}

/// Bindings for the user feature route.
class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<user_repo.UserRepository>(() => user_repo.UserRepository());
    Get.lazyPut<GetUserInfoUseCase>(() => GetUserInfoUseCase());
    Get.lazyPut<GetUserStatUseCase>(() => GetUserStatUseCase());
    Get.lazyPut<FollowUserUseCase>(() => FollowUserUseCase());
    Get.lazyPut<GetUserCoinsUseCase>(() => GetUserCoinsUseCase());
    Get.lazyPut<GetUserLikesUseCase>(() => GetUserLikesUseCase());
    Get.lazyPut<GetUserSeasonsUseCase>(() => GetUserSeasonsUseCase());
    Get.lazyPut<UserController>(() => UserController());
  }
}

/// Bindings for the media feature route.
class MediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<media_repo.MediaRepository>(() => media_repo.MediaRepository());
    Get.lazyPut<GetWatchLaterUseCase>(() => GetWatchLaterUseCase());
    Get.lazyPut<GetHistoryUseCase>(() => GetHistoryUseCase());
    Get.lazyPut<GetFavFoldersUseCase>(() => GetFavFoldersUseCase());
    Get.lazyPut<GetFavFolderDetailUseCase>(() => GetFavFolderDetailUseCase());
    Get.lazyPut<media_ctrl.MediaController>(() => media_ctrl.MediaController());
  }
}

/// Bindings for the dynamics feature route.
class DynamicsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<dynamics_repo.DynamicsRepository>(() => dynamics_repo.DynamicsRepository());
    Get.lazyPut<GetFollowDynamicsUseCase>(() => GetFollowDynamicsUseCase());
    Get.lazyPut<GetFollowUpUseCase>(() => GetFollowUpUseCase());
    Get.lazyPut<LikeDynamicUseCase>(() => LikeDynamicUseCase());
    Get.lazyPut<GetDynamicDetailUseCase>(() => GetDynamicDetailUseCase());
    Get.lazyPut<CreateDynamicUseCase>(() => CreateDynamicUseCase());
    Get.lazyPut<dynamics_ctrl.DynamicsController>(() => dynamics_ctrl.DynamicsController());
  }
}

/// Bindings for the rank feature route.
class RankBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<rank_repo.RankRepository>(() => rank_repo.RankRepository());
    Get.lazyPut<GetRankVideoListUseCase>(() => GetRankVideoListUseCase());
    Get.lazyPut<rank_ctrl.RankController>(() => rank_ctrl.RankController());
  }
}
