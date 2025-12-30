import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/ui/discover/discovery/logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget tabBarView() {
  debugPrint('discover tab bar update');
  final logic = Get.find<DiscoveryLogic>();
  logic.resetTabs();
  return Container(
      child: TabBar(
        tabs: logic.discoveryTabs,
        controller: logic.tabController,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: appThemeData.tabBarTheme.labelColor,
        labelColor: appThemeData.tabBarTheme.labelColor,
        unselectedLabelColor: appThemeData.tabBarTheme.unselectedLabelColor,
        labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 14, color: kPrimaryLightColor),
      )
  );
}