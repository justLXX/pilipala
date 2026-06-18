class MediaVideoItemModel {
  MediaVideoItemModel({
    this.id,
    this.aid,
    this.offset,
    this.index,
    this.intro,
    this.attr,
    this.tid,
    this.copyRight,
    this.cntInfo,
    this.cover,
    this.duration,
    this.pubtime,
    this.likeState,
    this.favState,
    this.page,
    this.cid,
    this.pages,
    this.title,
    this.type,
    this.upper,
    this.link,
    this.bvid,
    this.shortLink,
    this.rights,
    this.elecInfo,
    this.coin,
    this.progressPercent,
    this.badge,
    this.forbidFav,
    this.moreType,
    this.businessOid,
    this.stat,
  });

  int? id;
  int? aid;
  int? offset;
  int? index;
  String? intro;
  int? attr;
  int? tid;
  int? copyRight;
  Map? cntInfo;
  String? cover;
  int? duration;
  int? pubtime;
  int? likeState;
  int? favState;
  int? page;
  int? cid;
  List<Page>? pages;
  String? title;
  int? type;
  Upper? upper;
  String? link;
  String? bvid;
  String? shortLink;
  Rights? rights;
  dynamic elecInfo;
  Coin? coin;
  double? progressPercent;
  dynamic badge;
  bool? forbidFav;
  int? moreType;
  int? businessOid;
  VideoStat? stat;

  // getter 兼容 VideoCardH 使用的字段名
  String get pic => cover ?? '';
  Upper? get owner => upper;

  factory MediaVideoItemModel.fromJson(Map<String, dynamic> json) {
    // 兼容两种 API 格式：收藏夹 API 和 稍后再看 API
    final isLaterFormat = json.containsKey('pic') || json.containsKey('owner');

    // 解析 cid：稍后再看有 cid 字段，收藏夹从 pages 取
    int? parsedCid = json['cid'];
    List<Page>? parsedPages;
    int? parsedPage;
    if (isLaterFormat) {
      parsedCid = json['cid'];
      parsedPage = 1;
      // 解析 page 对象
      if (json['page'] is Map) {
        final pageMap = json['page'] as Map<String, dynamic>;
        parsedCid ??= pageMap['cid'];
      }
    } else {
      parsedCid =
          json['pages'] == null ? -1 : json['pages'].first['id'];
      parsedPages = json['pages'] == null
          ? []
          : List<Page>.from(
              json['pages'].map((x) => Page.fromJson(x)));
      parsedPage = json['page'];
    }

    // 解析 upper/owner
    Upper? parsedUpper;
    if (json['upper'] is Map) {
      parsedUpper = Upper.fromJson(json['upper']);
    } else if (json['owner'] is Map) {
      final owner = json['owner'] as Map<String, dynamic>;
      parsedUpper = Upper(
        mid: owner['mid'],
        name: owner['name'],
        face: owner['face'],
      );
    }

    // 解析 stat（稍后再看 API 有 stat 字段）
    VideoStat? parsedStat;
    if (json['stat'] is Map) {
      parsedStat = VideoStat.fromJson(json['stat']);
    }

    // 解析 progressPercent（稍后再看 API 用 progress 表示秒数）
    double? progressPercent;
    if (json['progress_percent'] != null) {
      progressPercent = (json['progress_percent'] as num).toDouble();
    } else if (json['progress'] != null && json['duration'] != null) {
      final progress = json['progress'] as num;
      final duration = json['duration'] as num;
      progressPercent =
          duration > 0 ? (progress / duration * 100).toDouble() : 0.0;
    }

    return MediaVideoItemModel(
      id: json['id'] ?? json['aid'],
      aid: json['id'] ?? json['aid'],
      offset: json['offset'],
      index: json['index'],
      intro: json['intro'] ?? json['desc'],
      attr: json['attr'],
      tid: json['tid'],
      copyRight: json['copy_right'] ?? json['copyright'],
      cntInfo: json['cnt_info'],
      cover: json['cover'] ?? json['pic'],
      duration: json['duration'],
      pubtime: json['pubtime'] ?? json['pubdate'],
      likeState: json['like_state'],
      favState: json['fav_state'],
      page: parsedPage,
      cid: parsedCid,
      pages: parsedPages,
      title: json['title'],
      type: json['type'],
      upper: parsedUpper,
      link: json['link'],
      bvid: json['bv_id'] ?? json['bvid'],
      shortLink: json['short_link'] ?? json['short_link_v2'],
      rights: json['rights'] is Map
          ? Rights.fromJson(json['rights'])
          : null,
      elecInfo: json['elec_info'],
      coin: json['coin'] is Map ? Coin.fromJson(json['coin']) : null,
      progressPercent: progressPercent,
      badge: json['badge'],
      forbidFav: json['forbid_fav'],
      moreType: json['more_type'],
      businessOid: json['business_oid'],
      stat: parsedStat,
    );
  }
}

class VideoStat {
  VideoStat({
    this.view,
    this.danmaku,
    this.reply,
    this.favorite,
    this.coin,
    this.share,
    this.like,
  });

  int? view;
  int? danmaku;
  int? reply;
  int? favorite;
  int? coin;
  int? share;
  int? like;

  factory VideoStat.fromJson(Map<String, dynamic> json) => VideoStat(
        view: json['view'],
        danmaku: json['danmaku'],
        reply: json['reply'],
        favorite: json['favorite'],
        coin: json['coin'],
        share: json['share'],
        like: json['like'],
      );
}

class Coin {
  Coin({
    this.maxNum,
    this.coinNumber,
  });

  int? maxNum;
  int? coinNumber;

  factory Coin.fromJson(Map<String, dynamic> json) => Coin(
        maxNum: json["max_num"],
        coinNumber: json["coin_number"],
      );
}

class Page {
  Page({
    this.id,
    this.title,
    this.intro,
    this.duration,
    this.link,
    this.page,
    this.metas,
    this.from,
    this.dimension,
  });

  int? id;
  String? title;
  String? intro;
  int? duration;
  String? link;
  int? page;
  List<Meta>? metas;
  String? from;
  Dimension? dimension;

  factory Page.fromJson(Map<String, dynamic> json) => Page(
        id: json["id"],
        title: json["title"],
        intro: json["intro"],
        duration: json["duration"],
        link: json["link"],
        page: json["page"],
        metas: List<Meta>.from(json["metas"].map((x) => Meta.fromJson(x))),
        from: json["from"],
        dimension: Dimension.fromJson(json["dimension"]),
      );
}

class Dimension {
  Dimension({
    this.width,
    this.height,
    this.rotate,
  });

  int? width;
  int? height;
  int? rotate;

  factory Dimension.fromJson(Map<String, dynamic> json) => Dimension(
        width: json["width"],
        height: json["height"],
        rotate: json["rotate"],
      );
}

class Meta {
  Meta({
    this.quality,
    this.size,
  });

  int? quality;
  int? size;

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
        quality: json["quality"],
        size: json["size"],
      );
}

class Rights {
  Rights({
    this.bp,
    this.elec,
    this.download,
    this.movie,
    this.pay,
    this.ugcPay,
    this.hd5,
    this.noReprint,
    this.autoplay,
    this.noBackground,
  });

  int? bp;
  int? elec;
  int? download;
  int? movie;
  int? pay;
  int? ugcPay;
  int? hd5;
  int? noReprint;
  int? autoplay;
  int? noBackground;

  factory Rights.fromJson(Map<String, dynamic> json) => Rights(
        bp: json["bp"],
        elec: json["elec"],
        download: json["download"],
        movie: json["movie"],
        pay: json["pay"],
        ugcPay: json["ugc_pay"],
        hd5: json["hd5"],
        noReprint: json["no_reprint"],
        autoplay: json["autoplay"],
        noBackground: json["no_background"],
      );
}

class Upper {
  Upper({
    this.mid,
    this.name,
    this.face,
    this.followed,
    this.fans,
    this.vipType,
    this.vipStatue,
    this.vipDueDate,
    this.vipPayType,
    this.officialRole,
    this.officialTitle,
    this.officialDesc,
    this.displayName,
  });

  int? mid;
  String? name;
  String? face;
  int? followed;
  int? fans;
  int? vipType;
  int? vipStatue;
  int? vipDueDate;
  int? vipPayType;
  int? officialRole;
  String? officialTitle;
  String? officialDesc;
  String? displayName;

  factory Upper.fromJson(Map<String, dynamic> json) => Upper(
        mid: json["mid"],
        name: json["name"],
        face: json["face"],
        followed: json["followed"],
        fans: json["fans"],
        vipType: json["vip_type"],
        vipStatue: json["vip_statue"],
        vipDueDate: json["vip_due_date"],
        vipPayType: json["vip_pay_type"],
        officialRole: json["official_role"],
        officialTitle: json["official_title"],
        officialDesc: json["official_desc"],
        displayName: json["display_name"],
      );
}
