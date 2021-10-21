import 'package:ble_project/model/vod_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_entity.g.dart';

@JsonSerializable(disallowUnrecognizedKeys: false)
class SearchEntity {
  List<VodInfo> data;
  int qty;

  SearchEntity(this.data, this.qty);

  factory SearchEntity.fromJson(Map<String, dynamic> json) => _$SearchEntityFromJson(json);
  Map<String, dynamic> toJson() => _$SearchEntityToJson(this);

}