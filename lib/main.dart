import 'dart:async';
import 'dart:io';
import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/global_config.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/model/film_box_info.dart';
import 'package:ble_project/ui/navigation/navigation/binding.dart';
import 'package:ble_project/ui/navigation/navigation/view.dart';
import 'package:ble_project/ui/user/personal/model/movie_info.dart';
import 'package:ble_project/ui/user/personal/model/person_info.dart';
import 'package:ble_project/util/desktop_platform.dart';
import 'package:ble_project/util/desktop_stable_autosize.dart';
import 'package:ble_project/util/sp.dart';
import 'package:ble_project/util/my_scroll_behavior.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_autosize_screen_pro/flutter_autosize_screen_pro.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:statsfl/statsfl.dart';
import 'package:lifecycle/lifecycle.dart';

import 'base/log/log_helper.dart';
import 'base/log/size_based_logger.dart';
import 'base/screen/binding.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  runZonedGuarded(
    () async {
      FlutterAutosizeScreenPro.setStandard(360, isAutoTextSize: true);
      Global.init();
      FlutterNativeSplash.preserve(widgetsBinding: CustomFlutterBinding());
      SpUtil.init();
      Hive
        ..initFlutter()
        ..registerAdapter(MovieInfoAdapter())
        ..registerAdapter(PersonInfoAdapter())
        ..registerAdapter(FilmBoxInfoAdapter());

      MediaKit.ensureInitialized();
      // 初始化 EasyLocalization
      await EasyLocalization.ensureInitialized();
      await initializeDateFormatting('zh_CN', null); // 简体中文
      await initializeDateFormatting('en_US', null); // 英文
      // 初始化基于大小的日志系统
      await SizeBasedLoggerConfig.instance.initialize();
      // 如果需要使用基于时间的日志系统，注释上面的行，取消注释下面的行
      // await TimeBasedLoggerConfig.instance.initialize();
      // 配置Flutter错误处理
      FlutterError.onError = (details) {
        if (!Platform.isWindows || kDebugMode) {
          FlutterError.presentError(details);
        }
        Log.error(
          'Flutter error',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      Log.info('Application starting...');
      runApp(
        StatsFl(
          isEnabled: Global.showFPS,
          child: EasyLocalization(
            supportedLocales: const [
              Locale('zh', 'CN'), // 中文（中国）
              Locale('en', 'US'), // 英语（美国）
            ],
            path: 'assets/translations', // 语言文件路径
            // 可选：设置默认语言、回退语言等
            fallbackLocale: const Locale('zh', 'CN'),
            startLocale: const Locale('zh', 'CN'),
            child: const MyApp(),
          ),
        ),
      );
    },
    (error, stack) {
      // 在日志系统初始化之前发生的错误，直接打印到控制台
      if (SizeBasedLoggerConfig.instance.isInitialized) {
        Log.critical('Uncaught error', error: error, stackTrace: stack);
      } else {
        print('Error before logger initialization: $error\n$stack');
      }
    },
  );
}

class CustomFlutterBinding extends WidgetsFlutterBinding
    with AutoWidgetsFlutterBinding {}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FlutterAutosizeScreenPro.getSize(context);
    return GetMaterialApp(
      title: '浮光掠影',
      scrollBehavior: const MyScrollBehavior(),
      builder: FlutterSmartDialog.init(
        builder: (context, child) {
          Widget result = child!;
          if (isDesktopLayoutPlatform) {
            result = DesktopStableAutosize(child: result);
          } else {
            result = FlutterAutosizeScreenPro.appBuilder(context, result);
          }
          // 以上个result为基准，添加其他builder
          return result;
        },
      ),
      theme: appThemeData,
      darkTheme: appThemeDarkData,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      navigatorKey: Get.key,
      navigatorObservers: [
        defaultLifecycleObserver,
        FlutterSmartDialog.observer,
      ],
      initialRoute: RouterConfigs.root,
      getPages: PageConfig.getPages,
      initialBinding: NavigationPageBinding(),
      home: NavigationPage(),
    );
  }
}
