import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'logic.dart';

class MovieDetailControllerBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint("MovieDetailControllerBinding");
    Get.lazyPut(() => MovieDetailControllerLogic());
  }
}
