import 'package:ble_project/ui/discover/discovery/view.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/view.dart';
import 'package:ble_project/ui/ranking/ranking/view.dart';
import 'package:ble_project/ui/user/personal/view.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' show RxInt, IntExtension;

class NavigationState {

  ///底部导航栏索引
  late RxInt bottomBarIndex;

  late List<Widget> bodyPageList;

  NavigationState() {
    bottomBarIndex = 0.obs;
    bodyPageList = [];
    bodyPageList
      ..add(HomePageMixin(key:ValueKey('home.title'.tr())))
      ..add(DiscoveryPage(key:ValueKey('discovery.title'.tr())))
      ..add(RankingPage(key:ValueKey('ranking.title'.tr())))
      ..add(PersonalPage(key: ValueKey('mine.title'.tr())));
  }
}
