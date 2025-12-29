import 'package:ble_project/model/ranking/ranking_entity.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show SingleGetTickerProviderMixin, GetxController;

import 'state.dart';

class RankingLogic extends GetxController with SingleGetTickerProviderMixin {
  final RankingState state = RankingState();
  late List<Widget> rankingTabs;
  late ScrollController scrollController;
  late TabController tabController;
  late AnimationController controller;
  late Tween<Offset> positionTween;
  late Animation<Offset> positionAnimation;

  void updateRanking(double to) {
    if(positionAnimation.value == Offset(to, 0)) return;
    positionTween.begin = positionAnimation.value;
    positionTween.end = Offset(to, 0);

    controller.reset();
    controller.forward();
    state.currentRankingIndex.value = to;

    debugPrint("ranking_tab_to = $to");
    ///排行版数据
    if(RankingState.RANKING_TYPE_WEEK == to) {
      state.loadingBusy.value = true;
      getWeekRanking();
    } else if(RankingState.RANKING_TYPE_MONTH == to) {
      state.loadingBusy.value = true;
      getMonthRanking();
    } else if(RankingState.RANKING_TYPE_ALL == to) {
      state.loadingBusy.value = true;
      getAllRanking();
    }
  }

  ///电影排行
  void updateRankingMovie(List<VodInfo> movies, bool isNeedRefresh) {
    if(!state.isMovieBusy) {
      state.isMovieBusy = true;
    }
    state.movieVodList = movies;
    update(["rankingMovie"], isNeedRefresh);
    state.isMovieBusy = false;
  }

  ///电视剧排行
  void updateRankingTv(List<VodInfo> movies, bool isNeedRefresh) {
    if(!state.isTvBusy) {
      state.isTvBusy = true;
    }
    state.tvVodList = movies;
    update(["rankingTv"], isNeedRefresh);
    state.isTvBusy = false;
  }

  ///综艺排行
  void updateRankingShow(List<VodInfo> movies, bool isNeedRefresh) {
    if(!state.isShowBusy) {
      state.isShowBusy = true;
    }
    state.showVodList = movies;
    update(["rankingShow"], isNeedRefresh);
    state.isShowBusy = false;
  }

  ///动漫排行
  void updateRankingCartoon(List<VodInfo> movies, bool isNeedRefresh) {
    if(!state.isCartoonBusy) {
      state.isCartoonBusy = true;
    }
    state.cartoonVodList = movies;
    update(["rankingCartoon"], isNeedRefresh);
    state.isCartoonBusy = false;
  }

  @override
  void onInit() {
    rankingTabs = []
      ..add(Tab(
        child: GestureDetector(
          onDoubleTap: () => listScrollTop(),
          child: Text('common.movie'.tr()),
        )
      ))
      ..add(Tab(
        child: GestureDetector(
          onDoubleTap: ()  => listScrollTop(),
          child: Text('common.tv_series'.tr()),
        )
      ))
      ..add(Tab(
        child: GestureDetector(
          onDoubleTap: ()  => listScrollTop(),
          child: Text('common.variety_show'.tr()),
        )
      ))
      ..add(Tab(
        child: GestureDetector(
          onDoubleTap: ()  => listScrollTop(),
          child: Text('common.tv_anime'.tr()),
        )
      ));
    scrollController = ScrollController();

    tabController = TabController(vsync: this, length: rankingTabs.length)..addListener(() {
      ///点击tab回调一次，滑动切换tab不会回调
      if(tabController.indexIsChanging){
        //选择下面的方式：
      }

      ///点击tab时或滑动tab回调一次
      if(tabController.index.toDouble() == tabController.animation!.value){
        if (tabController.index == 0) { ///tab_movie
          updateRankingMovie(state.rankingEntity!.movie, true);
        } else if(tabController.index == 1) { ///tab_tv
          updateRankingTv(state.rankingEntity!.teleplay, true);
        } else if(tabController.index == 2) { ///tab_variety_show
          updateRankingShow(state.rankingEntity!.show, true);
        } else if(tabController.index == 3) { ///tab_variety_show
          updateRankingCartoon(state.rankingEntity!.cartoon, true);
        }
      }
    });
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    positionTween = Tween<Offset>(begin: Offset.zero, end: Offset.zero);
    positionAnimation = positionTween.animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    super.onInit();
  }

  void listScrollTop() {
    scrollController.animateTo(0, duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  @override
  void onReady() {
    getWeekRanking();
    super.onReady();
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  void getAllRanking() async {
    _getRanking("vod_hits");
  }

  void getMonthRanking() async {
    _getRanking("vod_hits_month");
  }

  void getWeekRanking() async {
    _getRanking("vod_hits_week");
  }

  void _getRanking(String type) async {
    var rankingData = await MovieRepository().fetchRanking(type);
    state.loadingBusy.value = false;
    if(rankingData.ok) {
      RankingEntity entity = RankingEntity.fromJson(rankingData.data);
      state.rankingEntity = entity;
      if(tabController.index == 0) {
        updateRankingMovie(entity.movie, true);
      } else if(tabController.index == 1) {
        updateRankingTv(entity.teleplay, true);
      } else if(tabController.index == 2) {
        updateRankingShow(entity.show, true);
      } else if(tabController.index == 3) {
        updateRankingCartoon(entity.cartoon, true);
      }
    } else {
    }
  }
}
