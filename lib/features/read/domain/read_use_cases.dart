import 'package:get/get.dart';
import 'package:pilipala/features/read/data/read_repository.dart';

/// Use case for fetching CV article data.
class FetchCvDataUseCase {
  final ReadRepository _repository;

  FetchCvDataUseCase({ReadRepository? repository})
      : _repository = repository ?? Get.find<ReadRepository>();

  Future<Map<String, dynamic>> execute({required String id}) async {
    return await _repository.fetchCvData(id: id);
  }
}

/// Use case for fetching view info.
class FetchViewInfoUseCase {
  final ReadRepository _repository;

  FetchViewInfoUseCase({ReadRepository? repository})
      : _repository = repository ?? Get.find<ReadRepository>();

  Future<Map<String, dynamic>> execute({required String id}) async {
    return await _repository.fetchViewInfo(id: id);
  }
}
