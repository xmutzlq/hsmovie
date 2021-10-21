// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filter_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FilterTypes _$FilterTypesFromJson(Map<String, dynamic> json) {
  return FilterTypes(
    (json['电影'] as List<dynamic>?)
        ?.map((e) => FilterTypeInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['连续剧'] as List<dynamic>?)
        ?.map((e) => FilterTypeInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['综艺'] as List<dynamic>?)
        ?.map((e) => FilterTypeInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['动漫'] as List<dynamic>?)
        ?.map((e) => FilterTypeInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$FilterTypesToJson(FilterTypes instance) =>
    <String, dynamic>{
      '电影': instance.movieFilter,
      '连续剧': instance.tvFilter,
      '综艺': instance.showFilter,
      '动漫': instance.cartoonFilter,
    };
