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

  late ScrollController scrollController;

  PersonalState() {
    ///Initialize variables
    scrollController = ScrollController();
  }
}