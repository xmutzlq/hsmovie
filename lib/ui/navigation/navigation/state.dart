import 'package:ble_project/ui/discover/discovery/view.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/view.dart';
import 'package:ble_project/ui/ranking/ranking/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NavigationState {

  ///底部导航栏索引
  late RxInt bottomBarIndex;

  late List<Widget> bodyPageList;

  NavigationState() {
    bottomBarIndex = 0.obs;
    bodyPageList = [];
    bodyPageList
      ..add(HomePageMixin(key:ValueKey("首页")))
      ..add(DiscoveryPage(key:ValueKey("发现")))
      ..add(RankingPage(key:ValueKey("排行")));
  }
}
