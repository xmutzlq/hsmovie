import 'package:get/get.dart';

import 'logic.dart';

class MoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MoreLogic());
  }
}
