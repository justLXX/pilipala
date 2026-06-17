import 'package:get/get.dart';
import 'package:pilipala/features/opus/data/opus_repository.dart';
import 'package:pilipala/models/read/opus.dart';

/// Use case for fetching opus article data.
class FetchOpusDataUseCase {
  final OpusRepository _repository;

  FetchOpusDataUseCase({OpusRepository? repository})
      : _repository = repository ?? Get.find<OpusRepository>();

  Future<Map<String, dynamic>> execute({required String id}) async {
    return await _repository.fetchOpusData(id: id);
  }
}
