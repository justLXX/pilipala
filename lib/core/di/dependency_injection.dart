import 'package:get/get.dart';
import 'package:pilipala/core/network/api_client.dart';
import 'package:pilipala/core/storage/storage_service.dart';
import 'package:pilipala/core/theme/theme_service.dart';

// Home feature
import 'package:pilipala/features/home/data/video_repository.dart';
import 'package:pilipala/features/home/domain/video_use_cases.dart';
import 'package:pilipala/features/home/presentation/home_controller.dart';

// Search feature
import 'package:pilipala/features/search/data/search_repository.dart';
import 'package:pilipala/features/search/domain/search_use_cases.dart';
import 'package:pilipala/features/search/presentation/search_controller.dart';

// User feature
import 'package:pilipala/features/user/data/user_repository.dart';
import 'package:pilipala/features/user/domain/user_use_cases.dart';
import 'package:pilipala/features/user/presentation/user_controller.dart';

// Media feature
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/features/media/presentation/media_controller.dart' as media_ctrl;

// Login feature
import 'package:pilipala/features/login/data/login_repository.dart';
import 'package:pilipala/features/login/domain/login_use_cases.dart';
import 'package:pilipala/features/login/presentation/login_controller.dart' as login_ctrl;

// Dynamics feature
import 'package:pilipala/features/dynamics/data/dynamics_repository.dart' as dynamics_repo;
import 'package:pilipala/features/dynamics/domain/dynamics_use_cases.dart';
import 'package:pilipala/features/dynamics/presentation/dynamics_controller.dart' as dynamics_ctrl;

// Rank feature
import 'package:pilipala/features/rank/data/rank_repository.dart' as rank_repo;
import 'package:pilipala/features/rank/domain/rank_use_cases.dart';
import 'package:pilipala/features/rank/presentation/rank_controller.dart' as rank_ctrl;

class DependencyInjection {
  static void init() {
    // Core services
    Get.lazyPut<StorageService>(() => StorageServiceFactory.createSettingsStorage(),
        tag: 'settings');
    Get.lazyPut<StorageService>(() => StorageServiceFactory.createUserStorage(),
        tag: 'user');
    Get.lazyPut<StorageService>(() => StorageServiceFactory.createLocalCacheStorage(),
        tag: 'localCache');

    // Network
    Get.lazyPut<ApiClient>(() => DioApiClient());

    // Theme
    Get.lazyPut<ThemeService>(() => ThemeService());

    // Home feature
    Get.lazyPut<VideoRepository>(() => VideoRepository());
    Get.lazyPut<GetRecommendedVideosUseCase>(() => GetRecommendedVideosUseCase());
    Get.lazyPut<GetHotVideosUseCase>(() => GetHotVideosUseCase());
    Get.lazyPut<HomeController>(() => HomeController());

    // Search feature
    Get.lazyPut<SearchRepository>(() => SearchRepository());
    Get.lazyPut<GetHotSearchUseCase>(() => GetHotSearchUseCase());
    Get.lazyPut<SearchContentUseCase>(() => SearchContentUseCase());
    Get.lazyPut<GetSearchSuggestionsUseCase>(() => GetSearchSuggestionsUseCase());
    Get.lazyPut<PiliSearchController>(() => PiliSearchController());

    // User feature
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<GetUserInfoUseCase>(() => GetUserInfoUseCase());
    Get.lazyPut<GetUserStatUseCase>(() => GetUserStatUseCase());
    Get.lazyPut<FollowUserUseCase>(() => FollowUserUseCase());
    Get.lazyPut<GetUserCoinsUseCase>(() => GetUserCoinsUseCase());
    Get.lazyPut<GetUserLikesUseCase>(() => GetUserLikesUseCase());
    Get.lazyPut<GetUserSeasonsUseCase>(() => GetUserSeasonsUseCase());
    Get.lazyPut<UserController>(() => UserController());

    // Media feature
    Get.lazyPut<MediaRepository>(() => MediaRepository());
    Get.lazyPut<GetWatchLaterUseCase>(() => GetWatchLaterUseCase());
    Get.lazyPut<GetHistoryUseCase>(() => GetHistoryUseCase());
    Get.lazyPut<GetFavFoldersUseCase>(() => GetFavFoldersUseCase());
    Get.lazyPut<GetFavFolderDetailUseCase>(() => GetFavFolderDetailUseCase());
    Get.lazyPut<media_ctrl.MediaController>(() => media_ctrl.MediaController());

    // Login feature
    Get.lazyPut<LoginRepository>(() => LoginRepository());
    Get.lazyPut<GetCaptchaUseCase>(() => GetCaptchaUseCase());
    Get.lazyPut<GetWebKeyUseCase>(() => GetWebKeyUseCase());
    Get.lazyPut<EncryptPasswordUseCase>(() => EncryptPasswordUseCase());
    Get.lazyPut<LoginByPasswordUseCase>(() => LoginByPasswordUseCase());
    Get.lazyPut<LoginBySmsCodeUseCase>(() => LoginBySmsCodeUseCase());
    Get.lazyPut<SendSmsCodeUseCase>(() => SendSmsCodeUseCase());
    Get.lazyPut<QrCodeLoginUseCase>(() => QrCodeLoginUseCase());
    Get.lazyPut<login_ctrl.LoginController>(() => login_ctrl.LoginController());

    // Dynamics feature
    Get.lazyPut<dynamics_repo.DynamicsRepository>(() => dynamics_repo.DynamicsRepository());
    Get.lazyPut<GetFollowDynamicsUseCase>(() => GetFollowDynamicsUseCase());
    Get.lazyPut<GetFollowUpUseCase>(() => GetFollowUpUseCase());
    Get.lazyPut<LikeDynamicUseCase>(() => LikeDynamicUseCase());
    Get.lazyPut<GetDynamicDetailUseCase>(() => GetDynamicDetailUseCase());
    Get.lazyPut<CreateDynamicUseCase>(() => CreateDynamicUseCase());
    Get.lazyPut<dynamics_ctrl.DynamicsController>(() => dynamics_ctrl.DynamicsController());

    // Rank feature
    Get.lazyPut<rank_repo.RankRepository>(() => rank_repo.RankRepository());
    Get.lazyPut<GetRankVideoListUseCase>(() => GetRankVideoListUseCase());
    Get.lazyPut<rank_ctrl.RankController>(() => rank_ctrl.RankController());
  }
}
