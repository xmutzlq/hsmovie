import 'package:json_annotation/json_annotation.dart';

part 'filter_type_info.g.dart';
@JsonSerializable()
class FilterTypeInfo {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;

  FilterTypeInfo(this.id, this.name);

  factory FilterTypeInfo.fromJson(Map<String, dynamic> json) => _$FilterTypeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$FilterTypeInfoToJson(this);
}