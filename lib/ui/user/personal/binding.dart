import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:get/get.dart';

class PersonalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalLogic());
  }
}