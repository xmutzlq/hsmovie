import 'package:ble_project/base/screen/auto_size.dart';
import 'package:ble_project/base/screen/binding.dart';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/global_config.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/ui/navigation/navigation/binding.dart';
import 'package:ble_project/ui/navigation/navigation/view.dart';
import 'package:ble_project/util/sp.dart';
import 'package:flutter/material.dart';
import 'package:fps_monitor/widget/custom_widget_inspector.dart';
import 'package:get/get.dart';

Future main() async {
  AutoSizeUtil.setStandard(360, isAutoTextSize: true);
  Global.init();
  runAutoApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((t) {
      overlayState = Get.key.currentState!.overlay!;
    });
    SpUtil.init();
    return GetMaterialApp(
      builder: AutoSizeUtil.appBuilder,
      theme: appThemeData,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      navigatorKey: Get.key,
      initialRoute: RouterConfig.root,
      getPages: PageConfig.getPages,
      initialBinding: NavigationPageBinding(),
      home: NavigationPage()
    );
  }
}
