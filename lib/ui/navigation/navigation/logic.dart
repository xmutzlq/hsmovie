import 'package:ble_project/util/toast_util.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class NavigationLogic extends GetxController {
  final NavigationState state = NavigationState();

  ///改变底部导航栏索引
  changeBottomBarIndex(int index) {
    debugPrint("current_page = " + state.bodyPageList[index].key.toString());
    state.bottomBarIndex.value = index;
    update();
  }

  DateTime? _lastTime;
  Future<bool> exitApp() {
    if (_lastTime == null ||
        DateTime.now().difference(_lastTime!) > Duration(milliseconds: 2000)) {
      _lastTime = DateTime.now();
      ToastUtil.showToast("再次点击退出应用");
      return Future.value(false);
    }
    ToastUtil.cancelAllToast();
    return Future.value(true);
  }
}
