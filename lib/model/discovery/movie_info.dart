import 'package:ble_project/model/vod_info.dart';
import 'package:json_annotation/json_annotation.dart';
part 'movie_info.g.dart';

@JsonSerializable()
class MovieInfo {
  @JsonKey(name: "ID")
  int id;
  @JsonKey(name: "Name")
  String name;
  @JsonKey(name: "Items")
  List<VodInfo> items;

  MovieInfo(this.id, this.name, this.items);

  factory MovieInfo.fromJson(Map<String, dynamic> json) => _$MovieInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MovieInfoToJson(this);
}