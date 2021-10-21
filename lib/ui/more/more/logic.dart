import 'package:ble_project/base/dio_new.dart';
import 'package:ble_project/model/search/search_entity.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'state.dart';

class MoreLogic extends GetxController {
  final MoreState state = MoreState();
  ScrollController controller = ScrollController();

  void listScrollTop() {
    controller.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  void onInit() {
    var map = Get.arguments;
    state.title.value = map['title'];
    state.typeId = map['vodTypeId'];
    super.onInit();
  }

  @override
  void onReady() {
    loadMoreData();
    super.onReady();
  }

  @override
  void onClose() {
    state.page = 1;
    state.typeId = 0;
  }

  ///首次进入页面加载数据
  void loadMoreData() async {
    var moreData = await refreshMoreData(true);
    if(moreData.ok) {
      SearchEntity movieData = SearchEntity.fromJson(moreData.data);
      state.moreList = movieData.data;
      update();
    }
  }

  ///刷新加载数据
  Future<HttpResponse> refreshMoreData(bool isRefresh) {
    if(isRefresh) {
      state.page = 1;
    } else {
      state.page ++;
    }
    ///typeId区分不同视频
    return MovieRepository().fetchMoreData(state.typeId, state.page);
  }

  void updateResultForRefresh(HttpResponse moreData, bool isRefresh) {
    if(moreData.ok) {
      SearchEntity movieData = SearchEntity.fromJson(moreData.data);
      if(isRefresh) {
        state.moreList = movieData.data;
      } else {
        state.moreList.addAll(movieData.data);
      }
      update();
    } else {
      if(state.page > 1) {
        state.page --;
      }
    }
  }
}
