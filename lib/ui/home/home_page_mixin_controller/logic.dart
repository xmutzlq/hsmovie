import 'package:ble_project/base/log/app_log.dart';
import 'package:ble_project/model/filter/filter_entity.dart';
import 'package:ble_project/model/filter/filter_types.dart';
import 'package:ble_project/model/home/category/cate_info.dart';
import 'package:ble_project/model/home/home_entity.dart';
import 'package:ble_project/model/home/home_result.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/util/class_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../repository/movie_repository.dart';

class HomePageMixinControllerLogic extends GetxController with StateMixin<HomeResult> {

  ///本周热播
  List<VodInfo> weekHot = [];
  ///目录
  List<CateInfo> categories = [];
  ///所有分类
  FilterTypes? filterTypes;

  void onChangeWeekHot(List<VodInfo> newWeekHot) {
    this.weekHot = newWeekHot;
    update(['week_hot'], true);
  }

  void onChangeCategories(List<CateInfo> newCategories) {
    this.categories = newCategories;
    update(['categories'], true);
  }

  @override
  void onInit() {
    getAllFilter();
    super.onInit();
  }

  void getAllFilter() async {
    var allFilterData = await MovieRepository().fetchAllFilter();
    if(allFilterData.ok) {
      FilterEntity entity = FilterEntity.fromJson(allFilterData.data);
      filterTypes = entity.types;
    }
  }

  @override
  void onReady() {
    getHomeRemoteData();
    super.onReady();
  }

  void getHomeRemoteData() async {
    change(null, status: RxStatus.loading());
    var homeData = await MovieRepository().fetchHome();
    if(homeData.ok) {
      parserDataWithChange(homeData);
    } else {
      debugPrint("${ClazzUtil.getClassName(this)} -> error msg : ${homeData.error?.message}");
      change(null, status: RxStatus.error(homeData.error?.message));
    }
  }

  void parserDataWithChange(var homeData) {
    HomeEntity entity = HomeEntity.fromJson(homeData.data);
    HomeResult homeResult = HomeResult(entity, CateInfo.makeCateInfo(entity));
    onChangeWeekHot(entity.weekHot);
    onChangeCategories(homeResult.categories);
    change(homeResult, status: RxStatus.success());
  }
}
