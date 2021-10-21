import 'package:ble_project/model/vod_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ranking_entity.g.dart';

@JsonSerializable()
class RankingEntity {
  @JsonKey(name: "cartoon")
  List<VodInfo> cartoon;
  @JsonKey(name: "movie")
  List<VodInfo> movie;
  @JsonKey(name: "show")
  List<VodInfo> show;
  @JsonKey(name: "teleplay")
  List<VodInfo> teleplay;

  RankingEntity(this.cartoon, this.movie, this.show, this.teleplay);

  factory RankingEntity.fromJson(Map<String, dynamic> json) => _$RankingEntityFromJson(json);
  Map<String, dynamic> toJson() => _$RankingEntityToJson(this);
}