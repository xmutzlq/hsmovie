import 'package:ble_project/ui/navigation/navigation/logic.dart';
import 'package:get/get.dart';

class NavigationPageBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => NavigationLogic());
  }
}