// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeEntity _$HomeEntityFromJson(Map<String, dynamic> json) => HomeEntity(
  (json['h'] as List<dynamic>)
      .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['m'] as List<dynamic>)
      .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['s'] as List<dynamic>)
      .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['t'] as List<dynamic>)
      .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
  (json['c'] as List<dynamic>)
      .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HomeEntityToJson(HomeEntity instance) =>
    <String, dynamic>{
      'h': instance.weekHot,
      'm': instance.newestMovie,
      's': instance.newestVarietyShow,
      't': instance.newestSeries,
      'c': instance.newestAnimation,
    };
