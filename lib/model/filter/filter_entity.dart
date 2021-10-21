import 'package:ble_project/model/filter/filter_types.dart';
import 'package:json_annotation/json_annotation.dart';

part 'filter_entity.g.dart';

@JsonSerializable()
class FilterEntity {
  @JsonKey(name: "types")
  FilterTypes types;

  FilterEntity(this.types);

  factory FilterEntity.fromJson(Map<String, dynamic> json) => _$FilterEntityFromJson(json);
  Map<String, dynamic> toJson() => _$FilterEntityToJson(this);
}