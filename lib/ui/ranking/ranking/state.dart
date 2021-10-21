import 'package:ble_project/model/ranking/ranking_entity.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankingState {
  static const double RANKING_TYPE_WEEK = 0;
  static const double RANKING_TYPE_MONTH = 1;
  static const double RANKING_TYPE_ALL = 2;

  RxDouble currentRankingIndex = RANKING_TYPE_WEEK.obs;

  RankingEntity? rankingEntity;

  late List<VodInfo> movieVodList;
  late List<VodInfo> tvVodList;
  late List<VodInfo> showVodList;
  late List<VodInfo> cartoonVodList;

  RxBool loadingBusy = false.obs;
  bool isMovieBusy = false;
  bool isTvBusy = false;
  bool isShowBusy = false;
  bool isCartoonBusy = false;

  RankingState() {
    movieVodList = [];
    tvVodList = [];
    showVodList = [];
    cartoonVodList = [];
  }
}
