import 'package:pilipala/http/common.dart';

/// MainRepository - 主页面数据层
///
/// 处理主页面相关的数据获取，包括未读动态数量等
class MainRepository {
  /// 获取未读动态数量
  /// 复用 CommonHttp.unReadDynamic() 的实现
  Future<Map<String, dynamic>> getUnreadDynamic() async {
    return await CommonHttp.unReadDynamic();
  }
}
