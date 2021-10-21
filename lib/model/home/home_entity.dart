import 'package:json_annotation/json_annotation.dart';
import 'package:ble_project/model/vod_info.dart';
part 'home_entity.g.dart';

@JsonSerializable(includeIfNull: false)
class HomeEntity {
  @JsonKey(name: "h")
  List<VodInfo> weekHot;           //本周热播
  @JsonKey(name: "m")
  List<VodInfo> newestMovie;       //最新电影
  @JsonKey(name: "s")
  List<VodInfo> newestVarietyShow; //最新综艺
  @JsonKey(name: "t")
  List<VodInfo> newestSeries;      //最新连续剧
  @JsonKey(name: "c")
  List<VodInfo> newestAnimation;   //最新动漫

  HomeEntity(
    this.weekHot,
    this.newestMovie,
    this.newestVarietyShow,
    this.newestSeries,
    this.newestAnimation,
  );

  factory HomeEntity.fromJson(Map<String, dynamic> json) => _$HomeEntityFromJson(json);
  Map<String, dynamic> toJson() => _$HomeEntityToJson(this);

}