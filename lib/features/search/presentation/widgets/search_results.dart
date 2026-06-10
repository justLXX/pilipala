import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/search/presentation/search_controller.dart'
    as search_ctrl;
import 'package:pilipala/models/search/result.dart';
import 'package:pilipala/utils/utils.dart';

/// SearchResultsWidget displays search results with pagination and navigation.
class SearchResultsWidget extends StatefulWidget {
  final List<SearchVideoItemModel> results;
  final search_ctrl.PiliSearchController controller;
  final Future<void> Function()? onRefresh;

  const SearchResultsWidget({
    super.key,
    required this.results,
    required this.controller,
    this.onRefresh,
  });

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      EasyThrottle.throttle('searchLoadMore', const Duration(seconds: 1), () {
        widget.controller.loadMore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text('无搜索结果',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    )),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.results.length + 1,
        itemBuilder: (context, index) {
          // Last item: loading indicator or end of list
          if (index == widget.results.length) {
            return Obx(() {
              if (widget.controller.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              if (!widget.controller.hasMore) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      '没有更多了',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            });
          }

          final result = widget.results[index];
          return _SearchResultCard(
            result: result,
            keyword: widget.controller.keyword,
            onTap: () => widget.controller.navigateToVideoDetail(result),
          );
        },
      ),
    );
  }
}

/// A single search result card displaying video information.
class _SearchResultCard extends StatelessWidget {
  final SearchVideoItemModel result;
  final String keyword;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.keyword,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            _buildThumbnail(context),
            const SizedBox(width: 10),
            // Info
            Expanded(child: _buildInfo(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context) {
    final String? pic = result.pic;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Container(
              width: 160,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: pic != null && pic.isNotEmpty
                  ? Image.network(
                      pic,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(Icons.play_circle_outline, color: Colors.grey),
            ),
          ),
          // Duration badge
          if (result.duration != null && result.duration! > 0)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  _formatDuration(result.duration!),
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          result.title ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        // UP owner
        if (result.owner?.name != null)
          Row(
            children: [
              Icon(Icons.person_outline,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  result.owner!.name!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 4),
        // Stats: play count + danmaku + pubdate
        Row(
          children: [
            if (result.stat?.view != null) ...[
              Icon(Icons.play_arrow_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 2),
              Text(
                Utils.numFormat(result.stat!.view),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (result.stat?.danmaku != null &&
                result.stat!.danmaku! > 0) ...[
              Icon(Icons.subtitles_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 2),
              Text(
                Utils.numFormat(result.stat!.danmaku),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (result.pubdate != null && result.pubdate! > 0) ...[
              Icon(Icons.access_time,
                  size: 12,
                  color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: 2),
              Text(
                _formatTimestamp(result.pubdate!),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds >= 3600) {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      final s = seconds % 60;
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp(int timestamp) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return '刚刚';
        return '${diff.inMinutes}分钟前';
      }
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 365) {
      return '${date.month}-${date.day}';
    } else {
      return '${date.year}-${date.month}-${date.day}';
    }
  }
}
