import 'package:get/get.dart';

import 'logic.dart';

class SearchLogicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchLogicLogic());
  }
}
