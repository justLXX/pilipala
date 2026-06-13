// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/presentation/fav_edit/fav_edit_page.dart' as features_fav_edit;
import 'package:pilipala/features/user/presentation/follow_search/follow_search_page.dart' as features_follow_search;
import 'package:pilipala/features/user/presentation/member_article/member_article_page.dart' as features_member_article;
import 'package:pilipala/features/opus/presentation/opus_page.dart' as features_opus;
import 'package:pilipala/features/read/presentation/read_page.dart' as features_read;

import 'package:pilipala/features/about/presentation/about_page.dart' as features_about;
import 'package:pilipala/features/blacklist/presentation/blacklist_page.dart' as features_blacklist;
import 'package:pilipala/features/user/presentation/fan/fan_page.dart' as features_fan;
import 'package:pilipala/features/media/presentation/fav/fav_page.dart' as features_fav;
import 'package:pilipala/features/media/presentation/fav_detail/fav_detail_page.dart' as features_fav_detail;
import 'package:pilipala/features/media/presentation/fav_search/fav_search_page.dart' as features_fav_search;
import 'package:pilipala/features/user/presentation/follow/follow_page.dart' as features_follow;
import 'package:pilipala/features/media/presentation/history/history_page.dart' as features_history;
import 'package:pilipala/features/media/presentation/history_search/history_search_page.dart' as features_history_search;
import '../pages/home/index.dart';
import 'package:pilipala/features/html/presentation/html_page.dart' as features_html;
import 'package:pilipala/features/media/presentation/later/later_page.dart' as features_later;
import 'package:pilipala/features/user/presentation/member_archive/member_archive_page.dart' as features_member_archive;
import 'package:pilipala/features/user/presentation/member_coin/member_coin_page.dart' as features_member_coin;
import 'package:pilipala/features/user/presentation/member_dynamics/member_dynamics_page.dart' as features_member_dynamics;
import 'package:pilipala/features/user/presentation/member_like/member_like_page.dart' as features_member_like;
import 'package:pilipala/features/user/presentation/member_search/member_search_page.dart' as features_member_search;
import 'package:pilipala/features/user/presentation/member_seasons/member_seasons_page.dart' as features_member_seasons;
import '../pages/search_result/index.dart';
import 'package:pilipala/features/media/presentation/subscription/sub_page.dart' as features_subscription;
import 'package:pilipala/features/media/presentation/subscription_detail/sub_detail_page.dart' as features_sub_detail;
import '../pages/video/detail/reply_reply/index.dart';
import '../pages/webview/index.dart';
import '../utils/storage.dart';

// 新重构 features 页面 (使用别名避免命名冲突)
import 'package:pilipala/features/home/presentation/home_page.dart'
    as features_home;
import 'package:pilipala/features/home/presentation/hot_page.dart'
    as features_hot;
import 'package:pilipala/features/login/presentation/login_page.dart'
    as features_login;
import 'package:pilipala/features/main/presentation/main_page.dart'
    as features_main;
import 'package:pilipala/features/video/presentation/video_detail_page.dart'
    as features_video;
import 'package:pilipala/features/search/presentation/search_page.dart'
    as features_search;
import 'package:pilipala/features/user/presentation/member_page.dart'
    as features_member;
import 'package:pilipala/features/dynamics/presentation/dynamics_page.dart'
    as features_dynamics;
import 'package:pilipala/features/dynamics/presentation/dynamic_detail_page.dart'
    as features_dynamic_detail;
import 'package:pilipala/features/media/presentation/media_page.dart'
    as features_media;
import 'package:pilipala/features/live/presentation/live_page.dart'
    as features_live;
import 'package:pilipala/features/live/presentation/live_room_page.dart'
    as features_live_room;
import 'package:pilipala/features/message/presentation/whisper/whisper_page.dart'
    as features_whisper;
import 'package:pilipala/features/message/presentation/whisper_detail/whisper_detail_page.dart'
    as features_whisper_detail;
import 'package:pilipala/features/message/presentation/reply/message_reply_page.dart'
    as features_message_reply;
import 'package:pilipala/features/message/presentation/at/message_at_page.dart'
    as features_message_at;
import 'package:pilipala/features/message/presentation/like/message_like_page.dart'
    as features_message_like;
import 'package:pilipala/features/message/presentation/system/message_system_page.dart'
    as features_message_system;
import 'package:pilipala/features/setting/presentation/setting_page.dart'
    as features_setting;
import 'package:pilipala/features/setting/presentation/privacy_setting_page.dart';
import 'package:pilipala/features/setting/presentation/recommend_setting_page.dart';
import 'package:pilipala/features/setting/presentation/play_setting_page.dart';
import 'package:pilipala/features/setting/presentation/style_setting_page.dart';
import 'package:pilipala/features/setting/presentation/extra_setting_page.dart';
import 'package:pilipala/features/setting/presentation/pages/color_select.dart';
import 'package:pilipala/features/setting/presentation/pages/home_tabbar_set.dart';
import 'package:pilipala/features/setting/presentation/pages/font_size_select.dart';
import 'package:pilipala/features/setting/presentation/pages/display_mode.dart';
import 'package:pilipala/features/setting/presentation/pages/play_speed_set.dart';
import 'package:pilipala/features/setting/presentation/pages/play_gesture_set.dart';
import 'package:pilipala/features/setting/presentation/pages/navigation_bar_set.dart';
import 'package:pilipala/features/setting/presentation/pages/action_menu_set.dart';
import 'package:pilipala/features/setting/presentation/pages/logs.dart';
import '../router/bindings.dart';

Box<dynamic> setting = GStrorage.setting;

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    // ===== 使用新重构 features 页面的路由 =====

    // 首页(推荐) - 新重构版本
    CustomGetPage(
      name: '/home',
      page: () => const features_home.HomePage(),
      binding: HomeBinding(),
    ),
    // 热门 - 新重构版本
    CustomGetPage(
      name: '/hot',
      page: () => const features_hot.HotPage(),
      binding: HomeBinding(),
    ),
    // 视频详情 - 新重构版本
    CustomGetPage(
      name: '/video',
      page: () => const features_video.VideoDetailPage(),
      binding: VideoDetailBinding(),
    ),
    // 搜索页面 - 新重构版本
    CustomGetPage(
      name: '/search',
      page: () => const features_search.SearchPage(),
      binding: SearchBinding(),
    ),
    // 用户中心 - 新重构版本
    CustomGetPage(
      name: '/member',
      page: () => const features_member.MemberPage(),
      binding: UserBinding(),
    ),
    // 登录页面 - 新重构版本
    CustomGetPage(
      name: '/loginPage',
      page: () => const features_login.LoginPage(),
      binding: LoginBinding(),
    ),
    // 动态 - 新重构版本
    CustomGetPage(
      name: '/dynamics',
      page: () => const features_dynamics.DynamicsPage(),
      binding: DynamicsBinding(),
    ),
    // 动态详情 - 新重构版本
    CustomGetPage(
      name: '/dynamicDetail',
      page: () => const features_dynamic_detail.DynamicDetailPage(),
    ),
    // 媒体库 - 新重构版本
    CustomGetPage(
      name: '/media',
      page: () => const features_media.MediaPage(),
      binding: MediaBinding(),
    ),
    // 直播列表 - 新重构版本
    CustomGetPage(
      name: '/live',
      page: () => const features_live.LivePage(),
      binding: LiveBinding(),
    ),
    // 直播间 - 新重构版本
    CustomGetPage(
      name: '/liveRoom',
      page: () => const features_live_room.LiveRoomPage(),
      binding: LiveRoomBinding(),
    ),
    // 消息(私信列表) - 新重构版本
    CustomGetPage(
      name: '/whisper',
      page: () => const features_whisper.WhisperPage(),
      binding: WhisperBinding(),
    ),
    // 私信详情 - 新重构版本
    CustomGetPage(
      name: '/whisperDetail',
      page: () => const features_whisper_detail.WhisperDetailPage(),
      binding: WhisperDetailBinding(),
    ),
    // 回复我的 - 新重构版本
    CustomGetPage(
      name: '/messageReply',
      page: () => const features_message_reply.MessageReplyPage(),
      binding: MessageReplyBinding(),
    ),
    // @我的 - 新重构版本
    CustomGetPage(
      name: '/messageAt',
      page: () => const features_message_at.MessageAtPage(),
      binding: MessageAtBinding(),
    ),
    // 收到的赞 - 新重构版本
    CustomGetPage(
      name: '/messageLike',
      page: () => const features_message_like.MessageLikePage(),
      binding: MessageLikeBinding(),
    ),
    // 系统通知 - 新重构版本
    CustomGetPage(
      name: '/messageSystem',
      page: () => const features_message_system.MessageSystemPage(),
      binding: MessageSystemBinding(),
    ),
    // 设置 - 新重构版本
    CustomGetPage(
      name: '/setting',
      page: () => const features_setting.SettingPage(),
      binding: SettingBinding(),
    ),

    // ===== 以下为旧路由，保持不变 =====

    // 首页(推荐) - 旧版 (兼容)
    CustomGetPage(name: '/', page: () => const HomePage()),
    CustomGetPage(name: '/webview', page: () => const WebviewPage()),
    CustomGetPage(name: '/fav', page: () => const features_fav.FavPage()),
    CustomGetPage(name: '/favDetail', page: () => const features_fav_detail.FavDetailPage()),
    // 稍后再看
    CustomGetPage(name: '/later', page: () => const features_later.LaterPage()),
    // 历史记录
    CustomGetPage(name: '/history', page: () => const features_history.HistoryPage()),
    // 搜索结果 (旧版)
    CustomGetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 关注
    CustomGetPage(name: '/follow', page: () => const features_follow.FollowPage()),
    // 粉丝
    CustomGetPage(name: '/fan', page: () => const features_fan.FansPage()),
    CustomGetPage(name: '/memberSearch', page: () => const features_member_search.MemberSearchPage()),
    // 二级回复
    CustomGetPage(
        name: '/replyReply', page: () => const VideoReplyReplyPanel()),
    // 推荐设置
    CustomGetPage(
        name: '/recommendSetting', page: () => const RecommendSetting()),
    // 播放设置
    CustomGetPage(name: '/playSetting', page: () => const PlaySetting()),
    // 外观设置
    CustomGetPage(name: '/styleSetting', page: () => const StyleSetting()),
    // 隐私设置
    CustomGetPage(name: '/privacySetting', page: () => const PrivacySetting()),
    // 其他设置
    CustomGetPage(name: '/extraSetting', page: () => const ExtraSetting()),
    //
    CustomGetPage(name: '/blackListPage', page: () => const features_blacklist.BlackListPage()),
    CustomGetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    // 首页tabbar
    CustomGetPage(name: '/tabbarSetting', page: () => const TabbarSetPage()),
    CustomGetPage(
        name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 屏幕帧率
    CustomGetPage(
        name: '/displayModeSetting', page: () => const SetDiaplayMode()),
    // 关于
    CustomGetPage(name: '/about', page: () => const features_about.AboutPage()),
    //
    CustomGetPage(name: '/htmlRender', page: () => const features_html.HtmlRenderPage()),
    // 历史记录搜索
    CustomGetPage(
        name: '/historySearch', page: () => const features_history_search.HistorySearchPage()),

    CustomGetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    // 收藏搜索
    CustomGetPage(name: '/favSearch', page: () => const features_fav_search.FavSearchPage()),
    // 用户动态
    CustomGetPage(
        name: '/memberDynamics', page: () => const features_member_dynamics.MemberDynamicsPage()),
    // 用户投稿
    CustomGetPage(
        name: '/memberArchive', page: () => const features_member_archive.MemberArchivePage()),
    // 用户最近投币
    CustomGetPage(name: '/memberCoin', page: () => const features_member_coin.MemberCoinPage()),
    // 用户最近喜欢
    CustomGetPage(name: '/memberLike', page: () => const features_member_like.MemberLikePage()),
    // 用户专栏
    CustomGetPage(
        name: '/memberSeasons', page: () => const features_member_seasons.MemberSeasonsPage()),
    // 日志
    CustomGetPage(name: '/logs', page: () => const LogsPage()),
    // 搜索关注
    CustomGetPage(name: '/followSearch', page: () => const features_follow_search.FollowSearchPage()),
    // 订阅
    CustomGetPage(name: '/subscription', page: () => const features_subscription.SubPage()),
    // 订阅详情
    CustomGetPage(name: '/subDetail', page: () => const features_sub_detail.SubDetailPage()),
    // 播放器手势
    CustomGetPage(
        name: '/playerGestureSet', page: () => const PlayGesturePage()),
    // navigation bar
    CustomGetPage(
        name: '/navbarSetting', page: () => const NavigationBarSetPage()),
    // 操作菜单
    CustomGetPage(
        name: '/actionMenuSet', page: () => const ActionMenuSetPage()),
    // 收藏夹编辑
    CustomGetPage(name: '/favEdit', page: () => const features_fav_edit.FavEditPage()),

    // 专栏
    CustomGetPage(name: '/opus', page: () => const features_opus.OpusPage()),
    CustomGetPage(name: '/read', page: () => const features_read.ReadPage()),
    // 用户专栏
    CustomGetPage(
        name: '/memberArticle', page: () => const features_member_article.MemberArticlePage()),
  ];
}

class CustomGetPage extends GetPage<dynamic> {
  CustomGetPage({
    required super.name,
    required super.page,
    this.fullscreen,
    super.binding,
    super.transitionDuration,
  }) : super(
          curve: Curves.linear,
          transition: Transition.native,
          showCupertinoParallax: false,
          popGesture: false,
          fullscreenDialog: fullscreen != null && fullscreen,
        );
  bool? fullscreen = false;
}
