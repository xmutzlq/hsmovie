import 'package:ble_project/model/detail/movie_detail_entity.dart';
import 'package:flutter/widgets.dart';

class MovieDetailControllerState {

  bool isExpanded = false;
  MovieDetailEntity? entity;

  late ScrollController scrollController;

  MovieDetailControllerState() {
    ///Initialize variables
    scrollController = ScrollController();
  }
}
