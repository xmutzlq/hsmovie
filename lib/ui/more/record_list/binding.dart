import 'package:get/get.dart';

import 'logic.dart';

class RecordListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RecordListLogic());
  }
}
