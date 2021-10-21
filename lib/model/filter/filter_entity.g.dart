// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterEntity _$FilterEntityFromJson(Map<String, dynamic> json) {
  return FilterEntity(
    FilterTypes.fromJson(json['types'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$FilterEntityToJson(FilterEntity instance) =>
    <String, dynamic>{
      'types': instance.types,
    };
