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
import 'package:pilipala/features/live/data/live_repository.dart' as live_repo;
import 'package:pilipala/features/live/domain/live_use_cases.dart';
import 'package:pilipala/features/live/presentation/live_controller.dart' as live_ctrl;
import 'package:pilipala/features/live/presentation/live_room_controller.dart' as live_room_ctrl;
import 'package:pilipala/features/message/data/message_repository.dart' as msg_repo;
import 'package:pilipala/features/message/domain/message_use_cases.dart';
import 'package:pilipala/features/message/presentation/whisper/whisper_controller.dart' as whisper_ctrl;
import 'package:pilipala/features/message/presentation/whisper_detail/whisper_detail_controller.dart' as whisper_detail_ctrl;
import 'package:pilipala/features/message/presentation/reply/message_reply_controller.dart' as reply_ctrl;
import 'package:pilipala/features/message/presentation/at/message_at_controller.dart' as at_ctrl;
import 'package:pilipala/features/message/presentation/like/message_like_controller.dart' as like_ctrl;
import 'package:pilipala/features/message/presentation/system/message_system_controller.dart' as system_ctrl;
import 'package:pilipala/features/setting/data/setting_repository.dart' as setting_repo;
import 'package:pilipala/features/setting/domain/setting_use_cases.dart';
import 'package:pilipala/features/setting/presentation/setting_controller.dart' as setting_ctrl;

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
    Get.lazyPut<AddToWatchLaterUseCase>(() => AddToWatchLaterUseCase());
    Get.lazyPut<RemoveFromWatchLaterUseCase>(() => RemoveFromWatchLaterUseCase());
    Get.lazyPut<PauseHistoryUseCase>(() => PauseHistoryUseCase());
    Get.lazyPut<GetHistoryStatusUseCase>(() => GetHistoryStatusUseCase());
    Get.lazyPut<ClearHistoryUseCase>(() => ClearHistoryUseCase());
    Get.lazyPut<DeleteHistoryUseCase>(() => DeleteHistoryUseCase());
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

/// Bindings for the live feature route.
class LiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<live_repo.LiveRepository>(() => live_repo.LiveRepository());
    Get.lazyPut<GetLiveListUseCase>(() => GetLiveListUseCase());
    Get.lazyPut<GetFollowingLiveUseCase>(() => GetFollowingLiveUseCase());
    Get.lazyPut<live_ctrl.LiveController>(() => live_ctrl.LiveController());
  }
}

/// Bindings for the live room feature route.
class LiveRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<live_repo.LiveRepository>(() => live_repo.LiveRepository());
    Get.lazyPut<GetRoomInfoUseCase>(() => GetRoomInfoUseCase());
    Get.lazyPut<GetRoomInfoH5UseCase>(() => GetRoomInfoH5UseCase());
    Get.lazyPut<GetDanmakuInfoUseCase>(() => GetDanmakuInfoUseCase());
    Get.lazyPut<SendDanmakuUseCase>(() => SendDanmakuUseCase());
    Get.lazyPut<LiveRoomEntryUseCase>(() => LiveRoomEntryUseCase());
    Get.lazyPut<live_room_ctrl.LiveRoomController>(() => live_room_ctrl.LiveRoomController());
  }
}

/// Bindings for the whisper (message list) feature route.
class WhisperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<msg_repo.MessageRepository>(() => msg_repo.MessageRepository());
    Get.lazyPut<GetSessionListUseCase>(() => GetSessionListUseCase());
    Get.lazyPut<GetAccountListUseCase>(() => GetAccountListUseCase());
    Get.lazyPut<GetUnreadCountUseCase>(() => GetUnreadCountUseCase());
    Get.lazyPut<whisper_ctrl.WhisperController>(() => whisper_ctrl.WhisperController());
  }
}

/// Bindings for the whisper detail feature route.
class WhisperDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<msg_repo.MessageRepository>(() => msg_repo.MessageRepository());
    Get.lazyPut<GetSessionMsgUseCase>(() => GetSessionMsgUseCase());
    Get.lazyPut<AckSessionMsgUseCase>(() => AckSessionMsgUseCase());
    Get.lazyPut<SendMsgUseCase>(() => SendMsgUseCase());
    Get.lazyPut<RemoveSessionUseCase>(() => RemoveSessionUseCase());
    Get.lazyPut<whisper_detail_ctrl.WhisperDetailController>(() => whisper_detail_ctrl.WhisperDetailController());
  }
}

/// Bindings for the message reply feature route.
class MessageReplyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<msg_repo.MessageRepository>(() => msg_repo.MessageRepository());
    Get.lazyPut<GetReplyNotificationsUseCase>(() => GetReplyNotificationsUseCase());
    Get.lazyPut<reply_ctrl.MessageReplyController>(() => reply_ctrl.MessageReplyController());
  }
}

/// Bindings for the message at feature route.
class MessageAtBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<at_ctrl.MessageAtController>(() => at_ctrl.MessageAtController());
  }
}

/// Bindings for the message like feature route.
class MessageLikeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<msg_repo.MessageRepository>(() => msg_repo.MessageRepository());
    Get.lazyPut<GetLikeNotificationsUseCase>(() => GetLikeNotificationsUseCase());
    Get.lazyPut<like_ctrl.MessageLikeController>(() => like_ctrl.MessageLikeController());
  }
}

/// Bindings for the message system feature route.
class MessageSystemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<msg_repo.MessageRepository>(() => msg_repo.MessageRepository());
    Get.lazyPut<GetSystemNotificationsUseCase>(() => GetSystemNotificationsUseCase());
    Get.lazyPut<GetSystemAccountNotificationsUseCase>(() => GetSystemAccountNotificationsUseCase());
    Get.lazyPut<MarkSystemReadUseCase>(() => MarkSystemReadUseCase());
    Get.lazyPut<system_ctrl.MessageSystemController>(() => system_ctrl.MessageSystemController());
  }
}

/// Bindings for the setting feature route.
class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<setting_repo.SettingRepository>(() => setting_repo.SettingRepository());
    Get.lazyPut<GetSettingInitDataUseCase>(() => GetSettingInitDataUseCase());
    Get.lazyPut<LogoutUseCase>(() => LogoutUseCase());
    Get.lazyPut<ToggleFeedBackUseCase>(() => ToggleFeedBackUseCase());
    Get.lazyPut<SetDynamicBadgeModeUseCase>(() => SetDynamicBadgeModeUseCase());
    Get.lazyPut<SetDefaultHomePageUseCase>(() => SetDefaultHomePageUseCase());
    Get.lazyPut<setting_ctrl.SettingController>(() => setting_ctrl.SettingController());
  }
}
