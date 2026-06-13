import 'package:get/get.dart';
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/sub_detail.dart';
import 'package:pilipala/models/user/sub_folder.dart';

class SubDetailController extends GetxController {
  late SubFolderItemData item;
  late int seasonId;
  late String heroTag;
  int currentPage = 1;
  bool isLoadingMore = false;
  Rx<DetailInfo> subInfo = DetailInfo().obs;
  RxList<SubDetailMediaItem> subList = <SubDetailMediaItem>[].obs;
  RxString loadingText = '加载中...'.obs;
  int mediaCount = 0;
  late int channelType;

  late final GetSeasonListUseCase _getSeasonList;
  late final GetResourceListUseCase _getResourceList;

  SubDetailController({
    GetSeasonListUseCase? getSeasonList,
    GetResourceListUseCase? getResourceList,
  })  : _getSeasonList = getSeasonList ?? GetSeasonListUseCase(),
        _getResourceList = getResourceList ?? GetResourceListUseCase();

  @override
  void onInit() {
    item = Get.arguments;
    final parameters = Get.parameters;
    if (parameters.isNotEmpty) {
      seasonId = int.tryParse(parameters['seasonId'] ?? '') ?? 0;
      heroTag = parameters['heroTag'] ?? '';
      channelType = int.tryParse(parameters['type'] ?? '') ?? 0;
    }
    super.onInit();
  }

  Future<dynamic> queryUserSeasonList({type = 'init'}) async {
    if (type == 'onLoad' && subList.length >= mediaCount) {
      loadingText.value = '没有更多了';
      return;
    }
    isLoadingMore = true;

    try {
      final data = channelType == 21
          ? await _getSeasonList.execute(
              seasonId: seasonId,
              page: currentPage,
              pageSize: 20,
            )
          : await _getResourceList.execute(
              seasonId: seasonId,
              page: currentPage,
              pageSize: 20,
            );

      final info = data['info'];
      final medias = (data['medias'] as List?)
              ?.map((e) => SubDetailMediaItem.fromJson(e))
              .toList() ??
          [];

      subInfo.value = DetailInfo.fromJson(info);

      if (currentPage == 1 && type == 'init') {
        subList.value = medias;
        mediaCount = info['media_count'] ?? 0;
      } else if (type == 'onLoad') {
        subList.addAll(medias);
      }
      if (subList.length >= mediaCount) {
        loadingText.value = '没有更多了';
      }
      currentPage += 1;
      isLoadingMore = false;
      return {'status': true, 'data': data, 'msg': ''};
    } catch (e) {
      isLoadingMore = false;
      return {'status': false, 'msg': e.toString()};
    }
  }

  onLoad() {
    queryUserSeasonList(type: 'onLoad');
  }
}
