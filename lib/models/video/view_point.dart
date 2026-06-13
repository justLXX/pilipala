class ViewPoint {
  ViewPoint({
    this.content,
    this.from,
    this.to,
    this.type,
    this.imgUrl,
    this.logoUrl,
  });

  String? content;
  int? from;
  int? to;
  int? type;
  String? imgUrl;
  String? logoUrl;

  ViewPoint.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    from = json['from'];
    to = json['to'];
    type = json['type'];
    imgUrl = json['imgUrl'] ?? '';
    logoUrl = json['logoUrl'] ?? '';
  }

  /// 获取章节时长（秒）
  int get durationSeconds => (to ?? 0) - (from ?? 0);

  /// 格式化起始时间为 mm:ss
  String get fromTimeString {
    final seconds = from ?? 0;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 格式化时长为 mm:ss
  String get durationTimeString {
    final seconds = durationSeconds;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes == 0) {
      return '$secs秒';
    }
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}