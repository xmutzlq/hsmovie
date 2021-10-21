import 'package:ble_project/model/home/home_entity.dart';
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
      categories.add(CateInfo("h", "本周热播", entity.weekHot[0].vodPic));
    }
    if(entity.newestMovie.isNotEmpty) {
      categories.add(CateInfo("m", "最新电影", entity.newestMovie[0].vodPic));
    }
    if(entity.newestSeries.isNotEmpty) {
      categories.add(CateInfo("t", "最新连续剧", entity.newestSeries[0].vodPic));
    }
    if(entity.newestVarietyShow.isNotEmpty) {
      categories.add(CateInfo("s", "最新综艺", entity.newestVarietyShow[0].vodPic));
    }
    if(entity.newestAnimation.isNotEmpty) {
      categories.add(CateInfo("c", "最新动漫", entity.newestAnimation[0].vodPic));
    }
    return categories;
  }
}