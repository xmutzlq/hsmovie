// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ranking_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RankingEntity _$RankingEntityFromJson(Map<String, dynamic> json) {
  return RankingEntity(
    (json['cartoon'] as List<dynamic>)
        .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['movie'] as List<dynamic>)
        .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['show'] as List<dynamic>)
        .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    (json['teleplay'] as List<dynamic>)
        .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$RankingEntityToJson(RankingEntity instance) =>
    <String, dynamic>{
      'cartoon': instance.cartoon,
      'movie': instance.movie,
      'show': instance.show,
      'teleplay': instance.teleplay,
    };
