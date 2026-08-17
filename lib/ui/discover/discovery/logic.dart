import 'package:ble_project/model/discovery/discovery_entity.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'
    show GetxController, GetSingleTickerProviderStateMixin;

import 'state.dart';

class DiscoveryLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  final DiscoveryState state = DiscoveryState();
  late List<Widget> discoveryTabs;
  late TabController tabController;
  late ScrollController scrollController;

  @override
  void onInit() {
    resetTabs();

    scrollController = ScrollController();

    tabController = TabController(length: discoveryTabs.length, vsync: this)
      ..addListener(() {
        ///点击tab回调一次，滑动切换tab不会回调
        if (tabController.indexIsChanging) {
          //选择下面的方式：
        }

        ///点击tab时或滑动tab回调一次
        if (tabController.index.toDouble() == tabController.animation!.value) {
          if (tabController.index == 0) {
            ///tab_movie
            getMovieData();
          } else if (tabController.index == 1) {
            ///tab_tv
            getTvData();
          } else if (tabController.index == 2) {
            ///tab_variety_show
            getVarietyShow();
          }
        }
      });
    super.onInit();
  }

  void resetTabs() {
    discoveryTabs = []
      ..add(
        Tab(
          child: GestureDetector(
            onDoubleTap: () => listScrollTop(),
            child: Text('common.movie'.tr()),
          ),
        ),
      )
      ..add(
        Tab(
          child: GestureDetector(
            onDoubleTap: () => listScrollTop(),
            child: Text('common.tv_series'.tr()),
          ),
        ),
      )
      ..add(
        Tab(
          child: GestureDetector(
            onDoubleTap: () => listScrollTop(),
            child: Text('common.variety_show'.tr()),
          ),
        ),
      );
  }

  void listScrollTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  @override
  void onReady() {
    getMovieData();
    super.onReady();
  }

  ///电影
  void getMovieData() {
    if ((state.discoveryGroups!.length == 0) && !state.isMovieOnLoading) {
      state.isMovieOnLoading = true;
      if (kIsWeb) state.movieLoadError = null;
      _getMovieRemoteData("1");
    }
  }

  ///电影
  void getMovieDataWithRefresh() {
    if (!state.isMovieOnLoading) {
      state.isMovieOnLoading = true;
    }
  }

  ///电视剧
  void getTvData() {
    if (state.discoveryTvGroups!.length == 0 && !state.isTvOnLoading) {
      state.isTvOnLoading = true;
      if (kIsWeb) state.tvLoadError = null;
      _getMovieRemoteData("2");
    }
  }

  ///电视剧
  void getTvDataWithRefresh() {
    if (!state.isTvOnLoading) {
      state.isTvOnLoading = true;
    }
  }

  ///综艺
  void getVarietyShow() {
    if (state.discoveryVSGroups!.length == 0 && !state.isVSOnLoading) {
      state.isVSOnLoading = true;
      if (kIsWeb) state.vsLoadError = null;
      _getMovieRemoteData("3");
    }
  }

  ///综艺
  void getVarietyShowDataWithRefresh() {
    if (!state.isVSOnLoading) {
      state.isVSOnLoading = true;
    }
  }

  void _getMovieRemoteData(String type) async {
    if (!kIsWeb) {
      var movieData = await MovieRepository().fetchMovies(type);
      responseRemoteData(type, movieData);
      return;
    }

    try {
      var movieData = await MovieRepository().fetchMovies(type);
      responseRemoteData(type, movieData);
    } catch (error) {
      _finishRequest(type, error.toString());
    }
  }

  void responseRemoteData(String type, var movieData) {
    if (!kIsWeb) {
      if (movieData.ok) {
        DiscoveryEntity entity = DiscoveryEntity.fromJson(movieData.data);
        switch (type) {
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
        debugPrint("_getMovieRemoteData_error = ${movieData.error}");
        switch (type) {
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
      return;
    }

    String? errorMessage;
    try {
      if (movieData.ok) {
        DiscoveryEntity entity = DiscoveryEntity.fromJson(movieData.data);
        switch (type) {
          case "1":
            state.dataUpdate(entity);
            break;
          case "2":
            state.tvDataUpdate(entity);
            break;
          case "3":
            state.vsDataUpdate(entity);
            break;
        }
      } else {
        errorMessage = movieData.error?.message ?? '内容加载失败';
        debugPrint("_getMovieRemoteData_error = ${movieData.error}");
      }
    } catch (error) {
      errorMessage = error.toString();
    }
    _finishRequest(type, errorMessage);
  }

  void _finishRequest(String type, String? errorMessage) {
    switch (type) {
      case "1":
        state.isMovieOnLoading = false;
        state.movieLoadError = errorMessage;
        break;
      case "2":
        state.isTvOnLoading = false;
        state.tvLoadError = errorMessage;
        break;
      case "3":
        state.isVSOnLoading = false;
        state.vsLoadError = errorMessage;
        break;
    }
    update();
  }
}
