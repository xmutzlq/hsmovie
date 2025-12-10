import 'package:ble_project/model/detail/movie_detail_entity.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/state.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class MovieDetailControllerLogic extends GetxController with StateMixin<MovieDetailEntity> {

  MovieDetailControllerState detailState = MovieDetailControllerState();
  final personalLogic = Get.find<PersonalLogic>();

  void changeExpanded(bool isExpanded) {
    detailState.isExpanded = isExpanded;
    update();
  }

  @override
  void onReady() {
    debugPrint("MovieDetailControllerLogic_onReady");
    var map = Get.arguments;
    int movieId = map['movieId'];
    getMovieDetailRemoteData(movieId.toString());
    super.onReady();
  }

  void getMovieDetailRemoteData(String movieId) async {
    change(null, status: RxStatus.loading());
    var movieDetailData = await MovieRepository().fetchMovieDetail(movieId);
    if(movieDetailData.ok) {
      MovieDetailEntity entity = MovieDetailEntity.fromJson(movieDetailData.data);
      // logD('${JsonEncoder.withIndent('  ').convert(entity)}');
      detailState.entity = entity;
      // 增加浏览记录
      personalLogic.saveBrowsingRecord(entity.vod.vodID.toString(), entity.vod.vodPic, entity.vod.vodName);
      change(entity, status: RxStatus.success());
    } else {
      change(null, status: RxStatus.error(movieDetailData.error?.message));
    }
  }

  void saveFavourite() {
    MovieDetailEntity? entity = detailState.entity;
    if(entity != null) {
      personalLogic.saveFavouriteRecord(
          entity.vod.vodID.toString(),
          entity.vod.vodPic,
          entity.vod.vodName);
    }
  }

  @override
  void onClose() {
    debugPrint("MovieDetailControllerLogic_onClose");
    super.onClose();
  }

}
