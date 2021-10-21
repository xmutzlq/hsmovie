import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/discover/components/tab_bar_top.dart';
import 'package:ble_project/ui/discover/components/tab_bar_view_movie.dart';
import 'package:ble_project/ui/discover/components/tab_bar_view_tv.dart';
import 'package:ble_project/ui/discover/components/tab_bar_view_variety_show.dart';
import 'package:ble_project/ui/discover/discovery/logic.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoveryPage extends StatelessWidget {
  final logic = Get.find<DiscoveryLogic>();
  DiscoveryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        brightness: appThemeData.brightness,
        title: tabBarView(),
        backgroundColor: commBgColor,
        elevation: 0.0,
      ),
      body: ScrollConfiguration(
        behavior: MyScrollBehavior(),
        child:TabBarView(
          controller: logic.tabController,
          children: [
            movieView(),
            tvView(),
            varietyShowView()
          ],
        ),
      ),
      backgroundColor: commBgColor
    );
  }
}
