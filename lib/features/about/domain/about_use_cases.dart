import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pilipala/features/about/data/about_repository.dart';
import 'package:pilipala/models/github/latest.dart';
import 'package:pilipala/utils/utils.dart';

/// Use case for checking app updates.
class CheckUpdateUseCase {
  final AboutRepository _repository;

  CheckUpdateUseCase({AboutRepository? repository})
      : _repository = repository ?? Get.find<AboutRepository>();

  Future<Map<String, dynamic>> execute(String currentVersion) async {
    final result = await _repository.getLatestRelease();
    
    if (result['status'] == true && result['data'] != null) {
      final latestData = result['data'] as LatestDataModel;
      final remoteVersion = latestData.tagName ?? '';
      final needUpdate = Utils.needUpdate(currentVersion, remoteVersion);
      
      return {
        'status': true,
        'data': latestData,
        'needUpdate': needUpdate,
        'remoteVersion': remoteVersion,
      };
    }
    
    return result;
  }
}

/// Use case for getting current app version.
class GetCurrentVersionUseCase {
  Future<String> execute() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
