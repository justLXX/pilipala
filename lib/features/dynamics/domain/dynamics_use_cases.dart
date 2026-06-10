import 'package:pilipala/features/dynamics/data/dynamics_repository.dart';

class GetFollowDynamicsUseCase {
  final DynamicsRepository _repository;
  GetFollowDynamicsUseCase({DynamicsRepository? repository})
      : _repository = repository ?? DynamicsRepository();

  Future<Map> execute({String? type, int? page, String? offset, int? mid}) {
    return _repository.getFollowDynamics(type: type, page: page, offset: offset, mid: mid);
  }
}

class GetFollowUpUseCase {
  final DynamicsRepository _repository;
  GetFollowUpUseCase({DynamicsRepository? repository})
      : _repository = repository ?? DynamicsRepository();

  Future<Map> execute() {
    return _repository.getFollowUp();
  }
}

class LikeDynamicUseCase {
  final DynamicsRepository _repository;
  LikeDynamicUseCase({DynamicsRepository? repository})
      : _repository = repository ?? DynamicsRepository();

  Future<Map> execute({required String? dynamicId, required int? up}) {
    return _repository.likeDynamic(dynamicId: dynamicId, up: up);
  }
}

class GetDynamicDetailUseCase {
  final DynamicsRepository _repository;
  GetDynamicDetailUseCase({DynamicsRepository? repository})
      : _repository = repository ?? DynamicsRepository();

  Future<Map> execute({required String? id}) {
    return _repository.getDynamicDetail(id: id);
  }
}

class CreateDynamicUseCase {
  final DynamicsRepository _repository;
  CreateDynamicUseCase({DynamicsRepository? repository})
      : _repository = repository ?? DynamicsRepository();

  Future<Map> execute({required int mid, required int scene, int? oid, String? dynIdStr, String? rawText}) {
    return _repository.createDynamic(mid: mid, scene: scene, oid: oid, dynIdStr: dynIdStr, rawText: rawText);
  }
}
