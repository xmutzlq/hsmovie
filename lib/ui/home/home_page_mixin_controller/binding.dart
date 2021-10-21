import 'package:get/get.dart';

import 'logic.dart';

class HomePageBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => HomePageMixinControllerLogic());
  }
}
