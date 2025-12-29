import 'package:ble_project/model/home/home_entity.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:json_annotation/json_annotation.dart';
part 'cate_info.g.dart';

@JsonSerializable()
class CateInfo {
  String cateId;
  String cateName;
  String cateImg;

  CateInfo(this.cateId, this.cateName, this.cateImg);

  factory CateInfo.fromJson(Map<String, dynamic> json) => _$CateInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CateInfoToJson(this);

  static List<CateInfo> makeCateInfo(HomeEntity entity) {
    List<CateInfo> categories = [];
    if(entity.weekHot.isNotEmpty) {
      categories.add(CateInfo("h", 'home.categories_trending_this_week'.tr(), entity.weekHot[0].vodPic));
    }
    if(entity.newestMovie.isNotEmpty) {
      categories.add(CateInfo("m", 'home.categories_latest_movies'.tr(), entity.newestMovie[0].vodPic));
    }
    if(entity.newestSeries.isNotEmpty) {
      categories.add(CateInfo("t", 'home.categories_latest_tv_series'.tr(), entity.newestSeries[0].vodPic));
    }
    if(entity.newestVarietyShow.isNotEmpty) {
      categories.add(CateInfo("s", 'home.categories_latest_variety_shows'.tr(), entity.newestVarietyShow[0].vodPic));
    }
    if(entity.newestAnimation.isNotEmpty) {
      categories.add(CateInfo("c", 'home.categories_latest_anime'.tr(), entity.newestAnimation[0].vodPic));
    }
    return categories;
  }
}