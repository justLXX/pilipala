import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pilipala/features/media/data/media_repository.dart';
import 'package:pilipala/features/media/domain/media_use_cases.dart';
import 'package:pilipala/models/user/fav_detail.dart';
import 'package:pilipala/utils/navigation_helper.dart';

class FavSearchController extends GetxController {
  final ScrollController scrollController = ScrollController();
  Rx<TextEditingController> controller = TextEditingController().obs;
  final FocusNode searchFocusNode = FocusNode();
  RxString searchKeyWord = ''.obs;
  String hintText = '请输入已收藏视频名称';
  RxBool loadingStatus = false.obs;
  RxString loadingText = '加载中...'.obs;
  bool hasMore = false;
  late int searchType;
  late int mediaId;

  int currentPage = 1;
  int count = 0;
  RxList<FavDetailItemData> favList = <FavDetailItemData>[].obs;

  late final CancelFavVideoUseCase _cancelFavVideo;
  late final MediaRepository _repository;

  FavSearchController({
    CancelFavVideoUseCase? cancelFavVideo,
    MediaRepository? repository,
  })  : _cancelFavVideo = cancelFavVideo ?? CancelFavVideoUseCase(),
        _repository = repository ?? Get.find<MediaRepository>();

  @override
  void onInit() {
    super.onInit();
    searchType = int.parse(Get.parameters['searchType']!);
    mediaId = int.parse(Get.parameters['mediaId']!);
  }

  void onClear() {
    if (searchKeyWord.value.isNotEmpty && controller.value.text != '') {
      controller.value.clear();
      searchKeyWord.value = '';
    } else {
      safeBack();
    }
  }

  void onChange(value) {
    searchKeyWord.value = value;
  }

  void submit() {
    loadingStatus.value = true;
    currentPage = 1;
    searchFav();
  }

  Future searchFav({type = 'init'}) async {
    try {
      final response = await _repository.getFavFolderDetailSearch(
        mediaId: mediaId,
        page: currentPage,
        pageSize: 20,
        keyword: searchKeyWord.value,
        type: searchType,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final medias = (data['medias'] as List?)
                ?.map((e) => FavDetailItemData.fromJson(e))
                .toList() ??
            [];

        if (currentPage == 1 && type == 'init') {
          favList.value = medias;
        } else if (type == 'onLoad') {
          favList.addAll(medias);
        }
        hasMore = data['has_more'] ?? false;
      }
      currentPage += 1;
      loadingStatus.value = false;
    } catch (e) {
      loadingStatus.value = false;
      SmartDialog.showToast(e.toString());
    }
  }

  onLoad() {
    if (!hasMore) return;
    searchFav(type: 'onLoad');
  }

  onCancelFav(int id) async {
    try {
      await _cancelFavVideo.execute(
        aid: id,
        mediaIds: mediaId.toString(),
      );
      favList.removeWhere((i) => i.id == id);
      SmartDialog.showToast('取消收藏');
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }
}
