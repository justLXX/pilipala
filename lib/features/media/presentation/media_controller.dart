import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/user/fav_detail.dart';
import 'package:pilipala/models/video/later.dart';
import 'package:pilipala/models/user/history.dart';
import 'package:pilipala/utils/storage.dart';

/// Controller for the media feature.
///
/// Manages the state for media-related operations including
/// watch later, history, and favorites.
class MediaController extends GetxController {
  // Dependencies
  late final GetWatchLaterUseCase _getWatchLater;
  late final GetHistoryUseCase _getHistory;
  late final GetFavFoldersUseCase _getFavFolders;
  late final GetFavFolderDetailUseCase _getFavFolderDetail;
  late final AddToWatchLaterUseCase _addToWatchLater;
  late final RemoveFromWatchLaterUseCase _removeFromWatchLater;

  // State
  final RxList<MediaVideoItemModel> _watchLaterList = <MediaVideoItemModel>[].obs;
  final RxList<HisListItem> _historyList = <HisListItem>[].obs;
  final RxList<FavFolderItemData> _favFolders = <FavFolderItemData>[].obs;
  final RxList<FavDetailItemData> _favDetailList = <FavDetailItemData>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _selectedTab = 0.obs;

  // Getters
  List<MediaVideoItemModel> get watchLaterList => _watchLaterList;
  List<HisListItem> get historyList => _historyList;
  List<FavFolderItemData> get favFolders => _favFolders;
  List<FavDetailItemData> get favDetailList => _favDetailList;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  int get selectedTab => _selectedTab.value;

  MediaController({
    GetWatchLaterUseCase? getWatchLater,
    GetHistoryUseCase? getHistory,
    GetFavFoldersUseCase? getFavFolders,
    GetFavFolderDetailUseCase? getFavFolderDetail,
    AddToWatchLaterUseCase? addToWatchLater,
    RemoveFromWatchLaterUseCase? removeFromWatchLater,
  }) {
    _getWatchLater = getWatchLater ?? GetWatchLaterUseCase();
    _getHistory = getHistory ?? GetHistoryUseCase();
    _getFavFolders = getFavFolders ?? GetFavFoldersUseCase();
    _getFavFolderDetail = getFavFolderDetail ?? GetFavFolderDetailUseCase();
    _addToWatchLater = addToWatchLater ?? AddToWatchLaterUseCase();
    _removeFromWatchLater = removeFromWatchLater ?? RemoveFromWatchLaterUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    loadWatchLater();
  }

  /// Load watch later list.
  Future<void> loadWatchLater() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final list = await _getWatchLater.execute();
      _watchLaterList.value = list;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load history list.
  Future<void> loadHistory() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final list = await _getHistory.execute();
      _historyList.value = list;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load favorite folders.
  Future<void> loadFavFolders({int? mid}) async {
    _isLoading.value = true;
    _error.value = '';

    // Use provided mid or get from cached userInfo
    final userId = mid ?? _getCurrentUserMid();
    if (userId == null) {
      _error.value = '用户未登录';
      _isLoading.value = false;
      return;
    }

    try {
      final list = await _getFavFolders.execute(mid: userId);
      _favFolders.value = list;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load favorite folder detail.
  Future<void> loadFavFolderDetail({required int mediaId}) async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final list = await _getFavFolderDetail.execute(mediaId: mediaId);
      _favDetailList.value = list;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Add a video to watch later.
  Future<bool> addToWatchLater({required String bvid}) async {
    try {
      await _addToWatchLater.execute(bvid: bvid);
      return true;
    } catch (e) {
      _error.value = e.toString();
      return false;
    }
  }

  /// Remove a video from watch later.
  Future<bool> removeFromWatchLater({required String bvid}) async {
    try {
      await _removeFromWatchLater.execute(bvid: bvid);
      // Remove from local list
      _watchLaterList.removeWhere((item) => item.bvid == bvid);
      return true;
    } catch (e) {
      _error.value = e.toString();
      return false;
    }
  }

  /// Get current user's mid from cached userInfo.
  int? _getCurrentUserMid() {
    final Box userInfoCache = GStrorage.userInfo;
    final userInfo = userInfoCache.get('userInfoCache');
    if (userInfo != null && userInfo['mid'] != null) {
      return userInfo['mid'] as int;
    }
    return null;
  }

  /// Backward-compatible method called by main_page when media tab is selected.
  Future<void> queryFavFolder() async {
    await loadWatchLater();
  }

  /// Change selected tab.
  void changeTab(int index) {
    _selectedTab.value = index;
    switch (index) {
      case 0:
        loadWatchLater();
        break;
      case 1:
        loadHistory();
        break;
      case 2:
        loadFavFolders();
        break;
    }
  }
}
