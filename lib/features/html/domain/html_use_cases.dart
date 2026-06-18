import 'package:get/get.dart';
import 'package:pilipala/features/html/data/html_repository.dart';

/// Use case for fetching HTML content.
class FetchHtmlContentUseCase {
  final HtmlRepository _repository;

  FetchHtmlContentUseCase({HtmlRepository? repository})
      : _repository = repository ?? Get.find<HtmlRepository>();

  Future<Map<String, dynamic>> execute({
    required String id,
    required String dynamicType,
  }) async {
    return await _repository.fetchHtmlContent(
      id: id,
      dynamicType: dynamicType,
    );
  }
}

/// Use case for fetching reply list.
class FetchReplyListUseCase {
  final HtmlRepository _repository;

  FetchReplyListUseCase({HtmlRepository? repository})
      : _repository = repository ?? Get.find<HtmlRepository>();

  Future<Map<String, dynamic>> execute({
    required int oid,
    required int pageNum,
    required int type,
    required int sort,
  }) async {
    return await _repository.fetchReplyList(
      oid: oid,
      pageNum: pageNum,
      type: type,
      sort: sort,
    );
  }
}
