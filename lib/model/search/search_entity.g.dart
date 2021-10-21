// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchEntity _$SearchEntityFromJson(Map<String, dynamic> json) {
  return SearchEntity(
    (json['data'] as List<dynamic>)
        .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['qty'] as int,
  );
}

Map<String, dynamic> _$SearchEntityToJson(SearchEntity instance) =>
    <String, dynamic>{
      'data': instance.data,
      'qty': instance.qty,
    };
