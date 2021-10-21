import 'package:ble_project/model/home/category/cate_info.dart';
import 'package:ble_project/model/home/home_entity.dart';

class HomeResult {
  HomeEntity homeEntity;
  List<CateInfo> categories;

  HomeResult(this.homeEntity, this.categories); //目录
}