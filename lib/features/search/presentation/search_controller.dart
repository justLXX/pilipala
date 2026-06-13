import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:hive/hive.dart';
import 'package:pilipala/features/search/domain/search_use_cases.dart';
import 'package:pilipala/http/search.dart';
import 'package:pilipala/models/search/hot.dart';
import 'package:pilipala/models/search/result.dart';
import 'package:pilipala/utils/storage.dart';
import 'package:pilipala/utils/utils.dart';
import 'package:pilipala/utils/navigation_helper.dart';

/// Controller for the search feature.
///
/// Manages the state for search operations including
/// hot search, search results, search suggestions, and search history.
class PiliSearchController extends GetxController {
  // Dependencies
  late final GetHotSearchUseCase _getHotSearch;
  late final SearchContentUseCase _searchContent;
  late final GetSearchSuggestionsUseCase _getSearchSuggestions;

  // Text input
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();
  final RxString _inputText = ''.obs;

  // State
  final RxList<HotSearchItem> _hotSearchList = <HotSearchItem>[].obs;
  final RxList<SearchVideoItemModel> _searchResults =
      <SearchVideoItemModel>[].obs;
  final RxList<String> _suggestions = <String>[].obs;
  final RxList<String> _searchHistory = <String>[].obs;
  final RxString _keyword = ''.obs;
  final RxString _searchType = 'video'.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _error = ''.obs;

  // Pagination
  final RxInt _currentPage = 1.obs;
  final RxBool _hasMore = true.obs;
  int? _numPages;

  // Search history persistence
  final Box _historyBox = GStrorage.historyword;
  List _historyCacheList = [];

  // Debouncer for search suggestions
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 250));

  // Getters
  List<HotSearchItem> get hotSearchList => _hotSearchList;
  List<SearchVideoItemModel> get searchResults => _searchResults;
  List<String> get suggestions => _suggestions;
  List<String> get searchHistory => _searchHistory;
  String get keyword => _keyword.value;
  String get searchType => _searchType.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get hasMore => _hasMore.value;
  String get error => _error.value;
  String get inputText => _inputText.value;

  PiliSearchController({
    GetHotSearchUseCase? getHotSearch,
    SearchContentUseCase? searchContent,
    GetSearchSuggestionsUseCase? getSearchSuggestions,
  }) {
    _getHotSearch = getHotSearch ?? GetHotSearchUseCase();
    _searchContent = searchContent ?? SearchContentUseCase();
    _getSearchSuggestions =
        getSearchSuggestions ?? GetSearchSuggestionsUseCase();
  }

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    loadHotSearch();

    // Handle incoming parameters (e.g. from other pages)
    if (Get.parameters.keys.isNotEmpty) {
      if (Get.parameters['keyword'] != null) {
        performSearch(Get.parameters['keyword']!);
      }
    }
  }

  @override
  void onClose() {
    searchFocusNode.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  // ==================== Search History ====================

  /// Load search history from Hive storage.
  void loadHistory() {
    _historyCacheList = _historyBox.get('cacheList') ?? [];
    _searchHistory.value = List<String>.from(_historyCacheList);
  }

  /// Save a keyword to search history and persist to Hive.
  void saveToHistory(String keyword) {
    if (keyword.isEmpty) return;

    // Remove duplicate if exists
    _historyCacheList =
        _historyCacheList.where((e) => e != keyword).toList();
    // Insert at the beginning
    _historyCacheList.insert(0, keyword);
    // Limit history to 20 items
    if (_historyCacheList.length > 20) {
      _historyCacheList = _historyCacheList.sublist(0, 20);
    }

    _searchHistory.value = List<String>.from(_historyCacheList);
    _searchHistory.refresh();
    _historyBox.put('cacheList', _historyCacheList);
  }

  /// Remove a single keyword from search history.
  void removeHistory(String keyword) {
    _historyCacheList =
        _historyCacheList.where((e) => e != keyword).toList();
    _searchHistory.value = List<String>.from(_historyCacheList);
    _searchHistory.refresh();
    _historyBox.put('cacheList', _historyCacheList);
  }

  /// Clear all search history.
  void clearHistory() {
    _searchHistory.value = [];
    _historyCacheList = [];
    _searchHistory.refresh();
    _historyBox.put('cacheList', []);
  }

  // ==================== Hot Search ====================

  /// Load hot search list.
  Future<void> loadHotSearch() async {
    _isLoading.value = true;
    _error.value = '';

    try {
      final hotSearch = await _getHotSearch.execute();
      _hotSearchList.value = hotSearch;
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  // ==================== Search Suggestions ====================

  /// Load search suggestions with debounce.
  void onInputChanged(String text) {
    _inputText.value = text;

    if (text.isEmpty) {
      _suggestions.clear();
      return;
    }

    _debouncer.call(() => _loadSuggestions(text));
  }

  /// Internal method to load suggestions (called after debounce).
  Future<void> _loadSuggestions(String keyword) async {
    if (keyword.isEmpty) {
      _suggestions.clear();
      return;
    }

    try {
      final suggestions = await _getSearchSuggestions.execute(keyword);
      _suggestions.value = suggestions;
    } catch (e) {
      // Silently fail for suggestions - not critical
      _suggestions.clear();
    }
  }

  /// Load suggestions without debounce (for external calls).
  Future<void> loadSuggestions(String keyword) async {
    if (keyword.isEmpty) {
      _suggestions.clear();
      return;
    }

    try {
      final suggestions = await _getSearchSuggestions.execute(keyword);
      _suggestions.value = suggestions;
    } catch (e) {
      _suggestions.clear();
    }
  }

  // ==================== Search Execution ====================

  /// Perform a search with the given keyword.
  Future<void> performSearch(String keyword) async {
    if (keyword.isEmpty) return;

    _isLoading.value = true;
    _error.value = '';
    _keyword.value = keyword;
    _currentPage.value = 1;
    _hasMore.value = true;
    _suggestions.clear();
    _inputText.value = keyword;

    // Save to search history
    saveToHistory(keyword);

    // Update text field
    textEditingController.text = keyword;
    textEditingController.selection = TextSelection.fromPosition(
      TextPosition(offset: keyword.length),
    );

    // Unfocus the search field
    searchFocusNode.unfocus();

    try {
      final results = await _searchContent.execute(
        keyword: keyword,
        searchType: _searchType.value,
        page: 1,
      );
      _searchResults.value = results.list ?? [];
      _numPages = results.numPages;

      // Check if there are more pages
      if (_numPages != null && _currentPage.value >= _numPages!) {
        _hasMore.value = false;
      }
      if (results.list == null || results.list!.isEmpty) {
        _hasMore.value = false;
      }
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Load more search results (next page).
  Future<void> loadMore() async {
    if (_isLoadingMore.value || !_hasMore.value || _keyword.value.isEmpty) {
      return;
    }

    _isLoadingMore.value = true;

    try {
      _currentPage.value++;
      final results = await _searchContent.execute(
        keyword: _keyword.value,
        searchType: _searchType.value,
        page: _currentPage.value,
      );

      final newItems = results.list ?? [];
      _searchResults.addAll(newItems);
      _numPages = results.numPages;

      // Check if there are more pages
      if (_numPages != null && _currentPage.value >= _numPages!) {
        _hasMore.value = false;
      }
      if (newItems.isEmpty) {
        _hasMore.value = false;
      }
    } catch (e) {
      _currentPage.value--;
      _error.value = e.toString();
    } finally {
      _isLoadingMore.value = false;
    }
  }

  // ==================== Navigation ====================

  /// Navigate to video detail page from a search result item.
  Future<void> navigateToVideoDetail(SearchVideoItemModel result) async {
    final String bvid = result.bvid ?? '';
    if (bvid.isEmpty) return;

    final int aid = result.aid ?? 0;
    final String heroTag = Utils.makeHeroTag(aid);

    // Resolve CID
    int cid = result.cid ?? 0;
    if (cid == 0) {
      try {
        cid = await SearchHttp.ab2c(aid: aid, bvid: bvid);
      } catch (_) {
        cid = 0;
      }
    }

    Get.toNamed(
      '/video?bvid=$bvid&cid=$cid',
      arguments: {'videoItem': result, 'heroTag': heroTag},
    );
  }

  // ==================== State Management ====================

  /// Called when the clear button in the search field is pressed.
  void onClearInput() {
    if (_inputText.value.isNotEmpty) {
      textEditingController.clear();
      _inputText.value = '';
      _suggestions.clear();
    } else {
      safeBack();
    }
  }

  /// Clear the current search and return to default state.
  void clearKeyword() {
    _keyword.value = '';
    _inputText.value = '';
    textEditingController.clear();
    _searchResults.clear();
    _suggestions.clear();
    _currentPage.value = 1;
    _hasMore.value = true;
    searchFocusNode.requestFocus();
  }

  /// Change search type.
  void changeSearchType(String type) {
    _searchType.value = type;
    // Re-search with new type if keyword exists
    if (_keyword.value.isNotEmpty) {
      performSearch(_keyword.value);
    }
  }
}
