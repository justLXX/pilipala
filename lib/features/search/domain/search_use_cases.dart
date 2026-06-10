import 'package:get/get.dart';
import 'package:pilipala/features/search/data/search_repository.dart';
import 'package:pilipala/models/search/hot.dart';
import 'package:pilipala/models/search/result.dart';

/// Use case for getting hot search list.
class GetHotSearchUseCase {
  final SearchRepository _repository;

  GetHotSearchUseCase({SearchRepository? repository})
      : _repository = repository ?? Get.find<SearchRepository>();

  /// Execute the use case.
  Future<List<HotSearchItem>> execute() async {
    final response = await _repository.getHotSearchList();

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load hot search');
  }
}

/// Use case for searching content.
class SearchContentUseCase {
  final SearchRepository _repository;

  SearchContentUseCase({SearchRepository? repository})
      : _repository = repository ?? Get.find<SearchRepository>();

  /// Execute the use case.
  Future<SearchVideoModel> execute({
    required String keyword,
    required String searchType,
    int page = 1,
    int pageSize = 20,
    String order = 'totalrank',
  }) async {
    final response = await _repository.search(
      keyword: keyword,
      searchType: searchType,
      page: page,
      pageSize: pageSize,
      order: order,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Search failed');
  }
}

/// Use case for getting search suggestions.
class GetSearchSuggestionsUseCase {
  final SearchRepository _repository;

  GetSearchSuggestionsUseCase({SearchRepository? repository})
      : _repository = repository ?? Get.find<SearchRepository>();

  /// Execute the use case.
  Future<List<String>> execute(String keyword) async {
    final response = await _repository.getSearchSuggestions(keyword);

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load suggestions');
  }
}
