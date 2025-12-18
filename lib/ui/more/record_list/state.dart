import 'package:ble_project/ui/user/personal/model/movie_info.dart';
import 'package:get/get.dart';

class RecordListState {
  late int page;
  late int pageSize;
  RxString title = "更多".obs;
  List<MovieInfo> totalRecordList = [];
  List<MovieInfo> recordList = [];

  RecordListState() {
    page = 0;
    pageSize = 10;
    totalRecordList = [];
    recordList = [];
  }
}
