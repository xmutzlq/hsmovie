import 'package:ble_project/base/dio_new.dart';
import 'package:ble_project/ui/discover/discovery/logic.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:ble_project/ui/ranking/ranking/logic.dart';
import 'package:ble_project/ui/search/search_page_controller/search_logic/logic.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 全局配置
class Global {
  /// 是否 release
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");
  static bool get showFPS => false;

  /// 全局依赖
  static Future<void> init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      );
    }
    HttpConfig dioConfig = HttpConfig(
      baseUrl:
          "https://88api.omwjhz.com:18888/", // https://88api.omwjhz.com:18888/ || https://vip.88-spa.com:8443/
    );
    HttpClient client = HttpClient(dioConfig: dioConfig);
    Get.lazyPut(() => client);
    Get.lazyPut(() => HomePageMixinControllerLogic());
    Get.lazyPut(() => DiscoveryLogic());
    Get.lazyPut(() => RankingLogic());
    Get.lazyPut(() => SearchLogicLogic());
  }
}
