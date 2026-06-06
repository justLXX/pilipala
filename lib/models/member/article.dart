class MemberArticleDataModel {
  MemberArticleDataModel({
    this.hasMore,
    this.items,
    this.offset,
    this.updateNum,
  });

  bool? hasMore;
  List<MemberArticleItemModel>? items;
  String? offset;
  int? updateNum;

  MemberArticleDataModel.fromJson(Map<String, dynamic> json) {
    hasMore = json['has_more'];
    items = json['items']
        .map<MemberArticleItemModel>((e) => MemberArticleItemModel.fromJson(e))
        .toList();
    offset = json['offset'];
    final rawUpdateNum = json['update_num'];
    if (rawUpdateNum is String) {
      updateNum = int.tryParse(rawUpdateNum);
    } else {
      updateNum = rawUpdateNum as int?;
    }
  }
}

class MemberArticleItemModel {
  MemberArticleItemModel({
    this.content,
    this.cover,
    this.jumpUrl,
    this.opusId,
    this.stat,
  });

  String? content;
  Map? cover;
  String? jumpUrl;
  String? opusId;
  Map? stat;

  MemberArticleItemModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    cover = json['cover'];
    jumpUrl = json['jump_url'];
    opusId = json['opus_id'];
    stat = json['stat'];
  }
}
