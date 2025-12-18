import 'package:ble_project/model/movie_enum.dart';
import 'package:ble_project/ui/more/record_list/state.dart';
import 'package:ble_project/ui/user/personal/logic.dart';
import 'package:ble_project/ui/user/personal/model/movie_info.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class RecordListLogic extends GetxController {
  final ScrollController controller = ScrollController();
  final RecordListState state = RecordListState();
  final personalLogic = Get.find<PersonalLogic>();

  @override
  Future<void> onInit() async {
    var map = Get.arguments;
    state.title.value = map['recordListTitle'];
    var recordType = map['recordType'] as RecordType;
    List<MovieInfo> records = await personalLogic.getRecordsByType(recordType);
    state.totalRecordList = records;
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    List<MovieInfo> recordList = await refreshRecordData(true);
    updateResultForRefresh(recordList, true);
  }

  @override
  void onClose() {
    state.totalRecordList = [];
    state.page = 0;
  }

  ///刷新加载数据
  Future<List<MovieInfo>> refreshRecordData(bool isRefresh) async {
    if(isRefresh) {
      state.page = 1;
    } else {
      state.page ++;
    }
    List<MovieInfo> records = _getPageData(state.totalRecordList, state.page, state.pageSize);
    return records;
  }

  void updateResultForRefresh(List<MovieInfo>? recordData, bool isRefresh) {
    if(recordData != null && recordData.isNotEmpty) {
      if(isRefresh) {
        state.recordList = recordData;
      } else {
        state.recordList.addAll(recordData);
      }
      update();
    } else {
      if(state.page > 1) {
        state.page --;
      }
    }
  }

  List<T> _getPageData<T>(List<T> allData, int page, int pageSize) {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allData.length) {
      return [];
    }

    if (endIndex > allData.length) {
      return allData.sublist(startIndex);
    }

    return allData.sublist(startIndex, endIndex);
  }
}
