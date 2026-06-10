import 'package:get/get.dart';
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/models/user/fav_folder.dart';
import 'package:pilipala/models/user/fav_detail.dart';
import 'package:pilipala/models/video/later.dart';
import 'package:pilipala/models/user/history.dart';

/// Use case for getting watch later list.
class GetWatchLaterUseCase {
  final MediaRepository _repository;

  GetWatchLaterUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  /// Execute the use case.
  Future<List<MediaVideoItemModel>> execute() async {
    final response = await _repository.getWatchLaterList();

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load watch later list');
  }
}

/// Use case for getting history list.
class GetHistoryUseCase {
  final MediaRepository _repository;

  GetHistoryUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  /// Execute the use case.
  Future<List<HisListItem>> execute() async {
    final response = await _repository.getHistoryList();

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load history');
  }
}

/// Use case for getting favorite folders.
class GetFavFoldersUseCase {
  final MediaRepository _repository;

  GetFavFoldersUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  /// Execute the use case.
  Future<List<FavFolderItemData>> execute({
    required int mid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getFavFolders(
      mid: mid,
      page: page,
      pageSize: pageSize,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load favorite folders');
  }
}

/// Use case for getting favorite folder detail.
class GetFavFolderDetailUseCase {
  final MediaRepository _repository;

  GetFavFolderDetailUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  /// Execute the use case.
  Future<List<FavDetailItemData>> execute({
    required int mediaId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getFavFolderDetail(
      mediaId: mediaId,
      page: page,
      pageSize: pageSize,
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw Exception(response.msg ?? 'Failed to load favorite folder detail');
  }
}

/// Use case for adding a video to watch later.
class AddToWatchLaterUseCase {
  final MediaRepository _repository;

  AddToWatchLaterUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required String bvid}) async {
    final response = await _repository.addToWatchLater(bvid: bvid);
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to add to watch later');
    }
  }
}

/// Use case for removing a video from watch later.
class RemoveFromWatchLaterUseCase {
  final MediaRepository _repository;

  RemoveFromWatchLaterUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required String bvid}) async {
    final response = await _repository.removeFromWatchLater(bvid: bvid);
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to remove from watch later');
    }
  }
}
