import 'package:get/get.dart';

import 'state.dart';

class SimpleListLogic extends GetxController {
  final SimpleListState state = SimpleListState();

  @override
  void onInit() {
    var map = Get.arguments;
    state.title.value = map['simpleListTitle'];
    state.simpleList = map['simpleListArgument'];
    super.onInit();
  }

  @override
  void onReady() {
    updateSimpleList();
    super.onReady();
  }

  void updateSimpleList() {
    update();
  }
}
