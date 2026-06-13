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

/// Use case for pausing/resuming history.
class PauseHistoryUseCase {
  final MediaRepository _repository;

  PauseHistoryUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required bool pause}) async {
    final response = await _repository.pauseHistory(pause: pause);
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to pause history');
    }
  }
}

/// Use case for getting history pause status.
class GetHistoryStatusUseCase {
  final MediaRepository _repository;

  GetHistoryStatusUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<bool> execute() async {
    final response = await _repository.getHistoryStatus();
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg ?? 'Failed to get history status');
  }
}

/// Use case for clearing all history.
class ClearHistoryUseCase {
  final MediaRepository _repository;

  ClearHistoryUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute() async {
    final response = await _repository.clearHistory();
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to clear history');
    }
  }
}

/// Use case for deleting a single history item.
class DeleteHistoryUseCase {
  final MediaRepository _repository;

  DeleteHistoryUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required String kid}) async {
    final response = await _repository.deleteHistory(kid: kid);
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to delete history');
    }
  }
}

/// Use case for deleting favorite folder.
class DeleteFavFolderUseCase {
  final MediaRepository _repository;

  DeleteFavFolderUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required int mediaId}) async {
    final response = await _repository.deleteFavFolder(mediaId: mediaId);
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to delete favorite folder');
    }
  }
}

/// Use case for canceling video from favorite.
class CancelFavVideoUseCase {
  final MediaRepository _repository;

  CancelFavVideoUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required int aid, required String mediaIds}) async {
    final response = await _repository.cancelFavVideo(
      aid: aid,
      mediaIds: mediaIds,
    );
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to cancel favorite');
    }
  }
}

/// Use case for searching history.
class SearchHistoryUseCase {
  final MediaRepository _repository;

  SearchHistoryUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<Map<String, dynamic>> execute({
    required int pn,
    required String keyword,
  }) async {
    final response = await _repository.searchHistory(
      pn: pn,
      keyword: keyword,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg ?? 'Failed to search history');
  }
}

/// Use case for getting subscription folder list.
class GetSubFolderUseCase {
  final MediaRepository _repository;

  GetSubFolderUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<Map<String, dynamic>> execute({
    required int mid,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getSubFolder(
      mid: mid,
      page: page,
      pageSize: pageSize,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg ?? 'Failed to get subscription folder');
  }
}

/// Use case for canceling subscription.
class CancelSubscriptionUseCase {
  final MediaRepository _repository;

  CancelSubscriptionUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<void> execute({required int seasonId}) async {
    final response = await _repository.cancelSubscription(seasonId: seasonId);
    if (!response.isSuccess) {
      throw Exception(response.msg ?? 'Failed to cancel subscription');
    }
  }
}

/// Use case for getting subscription season list.
class GetSeasonListUseCase {
  final MediaRepository _repository;

  GetSeasonListUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<Map<String, dynamic>> execute({
    required int seasonId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getSeasonList(
      seasonId: seasonId,
      page: page,
      pageSize: pageSize,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg ?? 'Failed to get season list');
  }
}

/// Use case for getting subscription resource list.
class GetResourceListUseCase {
  final MediaRepository _repository;

  GetResourceListUseCase({MediaRepository? repository})
      : _repository = repository ?? Get.find<MediaRepository>();

  Future<Map<String, dynamic>> execute({
    required int seasonId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _repository.getResourceList(
      seasonId: seasonId,
      page: page,
      pageSize: pageSize,
    );
    if (response.isSuccess && response.data != null) {
      return response.data!;
    }
    throw Exception(response.msg ?? 'Failed to get resource list');
  }
}
