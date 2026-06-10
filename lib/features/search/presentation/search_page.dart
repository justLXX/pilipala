import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/common/widgets/http_error.dart';
import 'package:pilipala/features/search/presentation/search_controller.dart'
    as search_ctrl;
import 'package:pilipala/features/search/presentation/widgets/hot_keyword.dart';
import 'package:pilipala/features/search/presentation/widgets/search_text.dart';
import 'package:pilipala/features/search/presentation/widgets/search_results.dart';

/// SearchPage displays the search interface with three states:
/// - State A: Default (history + hot search)
/// - State B: Typing (suggestions)
/// - State C: Searched (results)
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();

  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class _SearchPageState extends State<SearchPage> with RouteAware {
  final search_ctrl.PiliSearchController _searchController =
      Get.find<search_ctrl.PiliSearchController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SearchPage.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.08),
            width: 1,
          ),
        ),
        titleSpacing: 0,
        centerTitle: false,
        title: SearchTextField(
          controller: _searchController,
          onSubmitted: (value) => _searchController.performSearch(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
      body: Obx(() {
        // State C: Has search keyword — show search results
        if (_searchController.keyword.isNotEmpty) {
          return _buildSearchResultsState();
        }
        // State B: Currently typing — show suggestions
        if (_searchController.inputText.isNotEmpty &&
            _searchController.suggestions.isNotEmpty) {
          return _buildSuggestionsState();
        }
        // State A: Default — show history + hot search
        return _buildDefaultState();
      }),
    );
  }

  /// State A: Default state with search history and hot search.
  Widget _buildDefaultState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          // Search history
          _buildSearchHistory(),
          // Hot search
          _buildHotSearch(),
        ],
      ),
    );
  }

  /// Search history section.
  Widget _buildSearchHistory() {
    return Obx(() {
      if (_searchController.searchHistory.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 0, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 0, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '搜索历史',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => _searchController.clearHistory(),
                    child: const Text('清空'),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              direction: Axis.horizontal,
              textDirection: TextDirection.ltr,
              children: [
                for (int i = 0;
                    i < _searchController.searchHistory.length;
                    i++)
                  _HistoryChip(
                    text: _searchController.searchHistory[i],
                    onTap: () =>
                        _searchController.performSearch(
                            _searchController.searchHistory[i]),
                    onLongPress: () =>
                        _searchController.removeHistory(
                            _searchController.searchHistory[i]),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  /// Hot search section.
  Widget _buildHotSearch() {
    return Obx(() {
      if (_searchController.hotSearchList.isEmpty) {
        if (_searchController.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_searchController.error,
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () => _searchController.loadHotSearch(),
                  child: const Text('点击重试'),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 4, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '热门搜索',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 34,
                    child: TextButton.icon(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.only(
                              left: 10, top: 6, bottom: 6, right: 10),
                        ),
                      ),
                      onPressed: () => _searchController.loadHotSearch(),
                      icon: const Icon(Icons.refresh_outlined, size: 18),
                      label: const Text('刷新'),
                    ),
                  ),
                ],
              ),
            ),
            HotKeywordWidget(
              hotSearchList: _searchController.hotSearchList,
              onTap: (keyword) => _searchController.performSearch(keyword),
            ),
          ],
        ),
      );
    });
  }

  /// State B: Suggestions while typing.
  Widget _buildSuggestionsState() {
    return Obx(() {
      final suggestions = _searchController.suggestions;
      if (suggestions.isEmpty) {
        return _buildDefaultState();
      }

      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: () => _searchController.performSearch(suggestion),
            child: Padding(
              padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
              child: Row(
                children: [
                  Icon(Icons.search,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  /// State C: Search results.
  Widget _buildSearchResultsState() {
    return Obx(() {
      if (_searchController.isLoading && _searchController.searchResults.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return SearchResultsWidget(
        results: _searchController.searchResults,
        controller: _searchController,
        onRefresh: () =>
            _searchController.performSearch(_searchController.keyword),
      );
    });
  }
}

/// A chip widget for search history items.
class _HistoryChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HistoryChip({
    required this.text,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Chip(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        labelPadding: const EdgeInsets.only(left: 4, right: 4),
        label: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
