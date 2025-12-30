import 'package:ble_project/ui/home/home_page_mixin_controller/logic.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'state.dart';

class SettingLogic extends GetxController {
  final homeLogic = Get.find<HomePageMixinControllerLogic>();
  final SettingState state = SettingState();
  ScrollController controller = ScrollController();
  late String currentLang;

  @override
  void onInit() {
    super.onInit();
    refreshCurrentLang();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void refreshCurrentLang() {
    currentLang = Get.context!.locale.toString();
    debugPrint('currentLang : $currentLang');
  }

  void updateHomePage() {
    homeLogic.getHomeRemoteData();
  }

  @override
  void onClose() {
  }

}
