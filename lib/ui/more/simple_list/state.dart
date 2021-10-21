import 'package:ble_project/model/vod_info.dart';
import 'package:get/get.dart';

class SimpleListState {

  RxString title = "更多".obs;
  List<VodInfo> simpleList = [];

  SimpleListState() {
    ///Initialize variables
  }
}
