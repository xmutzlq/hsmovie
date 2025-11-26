import 'package:ble_project/model/discovery/discovery_entity.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'state.dart';

class DiscoveryLogic extends GetxController with GetSingleTickerProviderStateMixin{
  final DiscoveryState state = DiscoveryState();
  late List<Widget> discoveryTabs;
  late TabController tabController;
  late ScrollController scrollController;

  @override
  void onInit() {
    discoveryTabs = []
      ..add(Tab(
          child: GestureDetector(
            onDoubleTap: () => listScrollTop(),
            child: Text("电影"),
          )
      ))
      ..add(Tab(
          child: GestureDetector(
            onDoubleTap: ()  => listScrollTop(),
            child: Text("电视剧"),
          )
      ))
      ..add(Tab(
          child: GestureDetector(
            onDoubleTap: ()  => listScrollTop(),
            child: Text("综艺"),
          )
      ));
    scrollController = ScrollController();

    tabController = TabController(length: discoveryTabs.length, vsync: this)..addListener(() {
      ///点击tab回调一次，滑动切换tab不会回调
      if(tabController.indexIsChanging){
        //选择下面的方式：
      }

      ///点击tab时或滑动tab回调一次
      if(tabController.index.toDouble() == tabController.animation!.value){
        if (tabController.index == 0) { ///tab_movie
          getMovieData();
        } else if(tabController.index == 1) { ///tab_tv
          getTvData();
        } else if(tabController.index == 2) { ///tab_variety_show
          getVarietyShow();
        }
      }
    });
    super.onInit();
  }

  void listScrollTop() {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  void onReady() {
    getMovieData();
    super.onReady();
  }

  ///电影
  void getMovieData() {
    if((state.discoveryGroups!.length == 0) && !state.isMovieOnLoading) {
      state.isMovieOnLoading = true;
      _getMovieRemoteData("1");
    }
  }

  ///电影
  void getMovieDataWithRefresh() {
    if(!state.isMovieOnLoading) {
      state.isMovieOnLoading = true;
    }
  }

  ///电视剧
  void getTvData() {
    if(state.discoveryTvGroups!.length == 0 && !state.isTvOnLoading) {
      state.isTvOnLoading = true;
      _getMovieRemoteData("2");
    }
  }

  ///电视剧
  void getTvDataWithRefresh() {
    if(!state.isTvOnLoading) {
      state.isTvOnLoading = true;
    }
  }

  ///综艺
  void getVarietyShow() {
    if(state.discoveryVSGroups!.length == 0 && !state.isVSOnLoading) {
      state.isVSOnLoading = true;
      _getMovieRemoteData("3");
    }
  }

  ///综艺
  void getVarietyShowDataWithRefresh() {
    if(!state.isVSOnLoading) {
      state.isVSOnLoading = true;
    }
  }

  void _getMovieRemoteData(String type) async {
    var movieData = await MovieRepository().fetchMovies(type);
    responseRemoteData(type, movieData);
  }

  void responseRemoteData(String type, var movieData) {
    if(movieData.ok) {
      DiscoveryEntity entity = DiscoveryEntity.fromJson(movieData.data);
      ///正确处理
      switch(type) {
        case "1":
          state.dataUpdate(entity);
          state.isMovieOnLoading = false;
          break;
        case "2":
          state.tvDataUpdate(entity);
          state.isTvOnLoading = false;
          break;
        case "3":
          state.vsDataUpdate(entity);
          state.isVSOnLoading = false;
          break;
      }

      update();
    } else {
      ///错误处理
      debugPrint("_getMovieRemoteData_error = ${movieData.error.toString()}");
      ///正确处理
      switch(type) {
        case "1":
          state.isMovieOnLoading = false;
          break;
        case "2":
          state.isTvOnLoading = false;
          break;
        case "3":
          state.isVSOnLoading = false;
          break;
      }
    }
  }
}
