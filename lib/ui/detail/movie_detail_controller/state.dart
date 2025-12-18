import 'package:ble_project/model/detail/movie_detail_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MovieDetailControllerState {

  bool isExpanded = false;
  MovieDetailEntity? entity;
  var isFilm = false.obs;

  late ScrollController scrollController;

  MovieDetailControllerState() {
    ///Initialize variables
    scrollController = ScrollController();
  }
}
