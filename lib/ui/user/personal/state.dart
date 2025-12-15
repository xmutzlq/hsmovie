import 'package:animated_flip_widget/animated_flip_widget.dart';
import 'package:ble_project/model/movie_enum.dart';
import 'package:ble_project/ui/user/personal/model/moive_typs_statistics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/avatar_state.dart';
import 'model/movie_info.dart';

class PersonalState {
  RxString nickName = '昵称'.obs;
  RxString avatarSVGStr = ''.obs;
  /// 图像数据
  var avatarItemStatus = <int, AvatarItemState>{}.obs;
  /// 观看记录数据
  RxList<MovieInfo> viewingRecord = <MovieInfo>[].obs;
  /// 观看记录数量
  RxString viewingRecordSize = '0'.obs;
  /// 浏览记录数据
  RxList<MovieInfo> browsingRecord = <MovieInfo>[].obs;
  /// 浏览记录数量
  RxString browsingRecordSize = '0'.obs;
  /// 收藏数据
  RxList<MovieInfo> favourite = <MovieInfo>[].obs;
  /// 收藏数量
  RxString favouriteSize = '0'.obs;

  /// 记录统计
  MovieTypeStatistics statistics = MovieTypeStatistics();
  /// 当前统计项
  RecordType currentRecordType = RecordType.unknown;

  late ScrollController scrollController;
  late FlipController flipController;
  late FlipDirection flipDirection;

  PersonalState() {
    ///Initialize variables
    scrollController = ScrollController();
    flipController = FlipController();
    flipDirection = FlipDirection.vertical;
  }
}