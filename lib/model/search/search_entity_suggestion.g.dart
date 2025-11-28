// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_entity_suggestion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchEntitySuggestion _$SearchEntitySuggestionFromJson(
  Map<String, dynamic> json,
) => SearchEntitySuggestion(
  (json['data'] as List<dynamic>)
      .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SearchEntitySuggestionToJson(
  SearchEntitySuggestion instance,
) => <String, dynamic>{'data': instance.data};
