import 'package:get/get.dart';

import 'logic.dart';

class SimpleListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SimpleListLogic());
  }
}
