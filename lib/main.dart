import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/global_config.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/ui/navigation/navigation/binding.dart';
import 'package:ble_project/ui/navigation/navigation/view.dart';
import 'package:ble_project/util/sp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:flutter_autosize_screen_pro/flutter_autosize_screen_pro.dart';
import 'package:media_kit/media_kit.dart';
import 'package:statsfl/statsfl.dart';

import 'base/screen/binding.dart';

Future main() async {
  FlutterAutosizeScreenPro.setStandard(360, isAutoTextSize: true);
  Global.init();
  FlutterNativeSplash.preserve(widgetsBinding: CustomFlutterBinding());
  SpUtil.init();
  MediaKit.ensureInitialized();
  runApp(StatsFl(isEnabled: Global.showFPS, child: const MyApp()));
}

class CustomFlutterBinding extends WidgetsFlutterBinding with AutoWidgetsFlutterBinding{}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterAutosizeScreenPro.getSize(context);
    return GetMaterialApp(
      builder: FlutterAutosizeScreenPro.appBuilder,
      theme: appThemeData,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      navigatorKey: Get.key,
      initialRoute: RouterConfigs.root,
      getPages: PageConfig.getPages,
      initialBinding: NavigationPageBinding(),
      home: NavigationPage(),
    );
  }
}
