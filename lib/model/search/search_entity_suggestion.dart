import 'package:ble_project/model/vod_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_entity_suggestion.g.dart';

@JsonSerializable()
class SearchEntitySuggestion {
  List<VodInfo> data;

  SearchEntitySuggestion(this.data);

  factory SearchEntitySuggestion.fromJson(Map<String, dynamic> json) => _$SearchEntitySuggestionFromJson(json);
  Map<String, dynamic> toJson() => _$SearchEntitySuggestionToJson(this);

}