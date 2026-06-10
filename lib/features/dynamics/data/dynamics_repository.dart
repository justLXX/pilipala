import 'package:pilipala/http/dynamics.dart';

class DynamicsRepository {
  /// 获取关注动态列表
  Future<Map> getFollowDynamics({String? type, int? page, String? offset, int? mid}) async {
    return await DynamicsHttp.followDynamic(type: type, page: page, offset: offset, mid: mid);
  }

  /// 获取关注UP主列表
  Future<Map> getFollowUp() async {
    return await DynamicsHttp.followUp();
  }

  /// 动态点赞
  Future<Map> likeDynamic({required String? dynamicId, required int? up}) async {
    return await DynamicsHttp.likeDynamic(dynamicId: dynamicId, up: up);
  }

  /// 获取动态详情
  Future<Map> getDynamicDetail({required String? id}) async {
    return await DynamicsHttp.dynamicDetail(id: id);
  }

  /// 创建/转发动态
  Future<Map> createDynamic({required int mid, required int scene, int? oid, String? dynIdStr, String? rawText}) async {
    return await DynamicsHttp.dynamicCreate(mid: mid, scene: scene, oid: oid, dynIdStr: dynIdStr, rawText: rawText);
  }
}
