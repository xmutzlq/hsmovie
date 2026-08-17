import 'package:ble_project/model/vod_info.dart';
import 'package:get/get.dart';

class MoreState {
  late int page;
  RxString title = "更多".obs;
  late int typeId;
  late List<VodInfo> moreList;
  bool isLoading = true;
  String? loadError;

  MoreState() {
    moreList = [];
    page = 1;
    typeId = 0;
  }
}
