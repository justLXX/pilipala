import 'package:get/get.dart';
import 'package:pilipala/http/html.dart';
import 'package:pilipala/http/reply.dart';
import 'package:pilipala/models/video/reply/item.dart';

/// Repository for HTML rendering feature.
/// Handles API calls related to dynamic HTML content and replies.
class HtmlRepository {
  /// Fetch HTML content for dynamic posts (opus/picture) or read articles.
  Future<Map<String, dynamic>> fetchHtmlContent({
    required String id,
    required String dynamicType,
  }) async {
    late dynamic res;
    if (dynamicType == 'opus' || dynamicType == 'picture') {
      res = await HtmlHttp.reqHtml(id, dynamicType);
    } else {
      res = await HtmlHttp.reqReadHtml(id, dynamicType);
    }
    return res as Map<String, dynamic>;
  }

  /// Fetch reply list for HTML content.
  Future<Map<String, dynamic>> fetchReplyList({
    required int oid,
    required int pageNum,
    required int type,
    required int sort,
  }) async {
    final res = await ReplyHttp.replyList(
      oid: oid,
      pageNum: pageNum,
      type: type,
      sort: sort,
    );
    return res as Map<String, dynamic>;
  }
}
