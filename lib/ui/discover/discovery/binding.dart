import 'package:get/get.dart';

import 'logic.dart';

class DiscoveryPageBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => DiscoveryLogic());
  }
}
