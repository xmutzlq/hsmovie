import 'package:ble_project/model/filter/filter_type_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'filter_types.g.dart';

@JsonSerializable()
class FilterTypes {
  @JsonKey(name: "电影")
  List<FilterTypeInfo>? movieFilter;
  @JsonKey(name: "连续剧")
  List<FilterTypeInfo>? tvFilter;
  @JsonKey(name: "综艺")
  List<FilterTypeInfo>? showFilter;
  @JsonKey(name: "动漫")
  List<FilterTypeInfo>? cartoonFilter;

  FilterTypes(
      this.movieFilter, this.tvFilter, this.showFilter, this.cartoonFilter);

  factory FilterTypes.fromJson(Map<String, dynamic> json) => _$FilterTypesFromJson(json);
  Map<String, dynamic> toJson() => _$FilterTypesToJson(this);
}