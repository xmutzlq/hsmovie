import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/discover/discovery/logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget tabBarView() {
  final logic = Get.find<DiscoveryLogic>();
  return Container(
    child: TabBar(
      tabs: logic.discoveryTabs,
      controller: logic.tabController,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: appThemeData.tabBarTheme.labelColor,
      labelColor: appThemeData.tabBarTheme.labelColor,
      unselectedLabelColor: appThemeData.tabBarTheme.unselectedLabelColor,
      labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(color: kPrimaryLightColor),
    )
  );
}