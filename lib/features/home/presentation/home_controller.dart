import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/home/domain/video_use_cases.dart';
import 'package:pilipala/http/api.dart';
import 'package:pilipala/http/init.dart';
import 'package:pilipala/models/model_hot_video_item.dart';
import 'package:pilipala/models/model_rec_video_item.dart';
import 'package:pilipala/utils/storage.dart';

/// Controller for the home/recommendation feature.
class HomeController extends GetxController {
  // Dependencies
  late final GetRecommendedVideosUseCase _getRecommendedVideos;
  late final GetHotVideosUseCase _getHotVideos;

  // State - recommended
  final RxList<RecVideoItemModel> _videoList = <RecVideoItemModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;
  final RxString _currentType = 'web'.obs;

  // State - hot
  final RxList<HotVideoItemModel> _hotVideoList = <HotVideoItemModel>[].obs;
  final RxBool _isHotLoading = false.obs;
  final RxBool _isHotLoadingMore = false.obs;
  final RxString _hotError = ''.obs;

  // Login state (compatible with legacy)
  final RxBool _userLogin = false.obs;
  final RxString _userFace = ''.obs;
  final Box _userInfoCache = GStrorage.userInfo;
  dynamic _userInfo;

  /// Default search word (used by search bar and extra_setting_page).
  RxString defaultSearch = ''.obs;

  int _currentPage = 0;
  int _hotPage = 1;
  static const int _pageSize = 20;

  // Getters
  List<RecVideoItemModel> get videoList => _videoList;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get error => _error.value;
  String get currentType => _currentType.value;

  List<HotVideoItemModel> get hotVideoList => _hotVideoList;
  bool get isHotLoading => _isHotLoading.value;
  bool get isHotLoadingMore => _isHotLoadingMore.value;
  String get hotError => _hotError.value;

  // Legacy compatibility getters
  RxBool get userLogin => _userLogin;
  RxString get userFace => _userFace;

  HomeController({
    GetRecommendedVideosUseCase? getRecommendedVideos,
    GetHotVideosUseCase? getHotVideos,
  }) {
    _getRecommendedVideos =
        getRecommendedVideos ?? GetRecommendedVideosUseCase();
    _getHotVideos = getHotVideos ?? GetHotVideosUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize login state (check if box is closed and reopen if needed)
    _ensureUserInfoBoxOpen();
    // Load default search word
    final Box setting = GStrorage.setting;
    if (setting.get(SettingBoxKey.enableSearchWord, defaultValue: true)) {
      searchDefault();
    }
    // loadVideos() 由 RcmdPage.initState() 调用，避免重复请求
  }

  /// Ensure userInfo box is open before accessing.
  void _ensureUserInfoBoxOpen() {
    Box userInfoCache = _userInfoCache;
    if (!userInfoCache.isOpen) {
      // If box is closed, skip login state initialization
      // The box will be reopened by the next login or app restart
      _userLogin.value = false;
      _userFace.value = '';
      return;
    }
    _userInfo = userInfoCache.get('userInfoCache');
    _userLogin.value = _userInfo != null;
    _userFace.value = _userInfo != null ? _userInfo.face : '';
  }

  /// Update login status (legacy compatibility).
  void updateLoginStatus(bool val) async {
    if (!_userInfoCache.isOpen) {
      _userLogin.value = val;
      return;
    }
    _userInfo = await _userInfoCache.get('userInfoCache');
    _userLogin.value = val;
    if (val) return;
    _userFace.value = _userInfo != null ? _userInfo.face : '';
  }

  /// Load initial video list.
  Future<void> loadVideos() async {
    _isLoading.value = true;
    _error.value = '';
    _currentPage = 0;

    try {
      final videos = await _getRecommendedVideos.execute(
        freshIdx: _currentPage,
        pageSize: _pageSize,
        type: _currentType.value,
      );

      _videoList.value = videos;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh video list.
  Future<void> refreshVideos() async {
    await loadVideos();
  }

  /// Load more videos.
  Future<void> loadMore() async {
    if (_isLoadingMore.value) return;

    _isLoadingMore.value = true;
    _currentPage++;

    try {
      final videos = await _getRecommendedVideos.execute(
        freshIdx: _currentPage,
        pageSize: _pageSize,
        type: _currentType.value,
      );

      _videoList.addAll(videos);
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoadingMore.value = false;
    }
  }

  /// Load hot videos.
  Future<void> loadHotVideos() async {
    _isHotLoading.value = true;
    _hotError.value = '';
    _hotPage = 1;

    try {
      final videos = await _getHotVideos.execute(
        page: _hotPage,
        pageSize: _pageSize,
      );

      _hotVideoList.value = videos;
    } catch (e) {
      _hotError.value = e.toString();
    } finally {
      _isHotLoading.value = false;
    }
  }

  /// Refresh hot videos.
  Future<void> refreshHotVideos() async {
    await loadHotVideos();
  }

  /// Load more hot videos.
  Future<void> loadMoreHot() async {
    if (_isHotLoadingMore.value) return;

    _isHotLoadingMore.value = true;
    _hotPage++;

    try {
      final videos = await _getHotVideos.execute(
        page: _hotPage,
        pageSize: _pageSize,
      );

      _hotVideoList.addAll(videos);
    } catch (e) {
      _hotError.value = e.toString();
    } finally {
      _isHotLoadingMore.value = false;
    }
  }

  /// Load default search word from API.
  void searchDefault() async {
    try {
      var res = await Request().get(Api.searchDefault);
      if (res.data is Map && res.data['code'] == 0) {
        defaultSearch.value = res.data['data']['name'] ?? '';
      }
    } catch (_) {}
  }
}
