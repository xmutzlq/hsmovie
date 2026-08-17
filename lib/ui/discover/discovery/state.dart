import 'package:ble_project/model/discovery/discovery_entity.dart';
import 'package:ble_project/model/discovery/discovery_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class DiscoveryState {
  ///movie
  List<DiscoveryGroupInfo>? discoveryGroups;
  late int page;
  late int totalPages;
  late bool isMovieOnLoading;
  String? movieLoadError;

  ///tv
  DiscoveryEntity? discoveryTvEntity;
  List<DiscoveryGroupInfo>? discoveryTvGroups;
  ScrollController? tvController;
  late int tvPage;
  late int tvTotalPages;
  late bool isTvOnLoading;
  String? tvLoadError;

  ///vs
  DiscoveryEntity? discoveryVSEntity;
  List<DiscoveryGroupInfo>? discoveryVSGroups;
  ScrollController? vsController;
  late int vsPage;
  late int vsTotalPages;
  late bool isVSOnLoading;
  String? vsLoadError;

  DiscoveryState() {
    this.discoveryGroups = [];
    this.page = 1;
    this.totalPages = 1;
    this.isMovieOnLoading = false;

    this.discoveryTvGroups = [];
    this.tvPage = 1;
    this.tvTotalPages = 1;
    this.isTvOnLoading = false;

    this.discoveryVSGroups = [];
    this.vsPage = 1;
    this.vsTotalPages = 1;
    this.isVSOnLoading = false;
  }

  void dataUpdate(DiscoveryEntity entity) {
    discoveryGroups = DiscoveryResult.makeDiscoveryGroups(entity);
  }

  void tvDataUpdate(DiscoveryEntity entity) {
    discoveryTvGroups = DiscoveryResult.makeDiscoveryGroups(entity);
  }

  void vsDataUpdate(DiscoveryEntity entity) {
    List<DiscoveryGroupInfo> tmpList = DiscoveryResult.makeDiscoveryGroups(
      entity,
    );
    // tmpList.sort((left,right)=>right.id.compareTo(left.id));
    discoveryVSGroups = tmpList;
  }
}
