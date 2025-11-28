// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detail_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieDetailEntity _$MovieDetailEntityFromJson(Map<String, dynamic> json) =>
    MovieDetailEntity(
      (json['comments'] as List<dynamic>)
          .map((e) => CommentInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['count'] as num).toInt(),
      json['domain'] as String,
      (json['rand'] as List<dynamic>)
          .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['relate'] as List<dynamic>)
          .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['shareLink'] as String,
      (json['status'] as num).toInt(),
      DetailVodInfo.fromJson(json['vod'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MovieDetailEntityToJson(MovieDetailEntity instance) =>
    <String, dynamic>{
      'comments': instance.comments,
      'count': instance.count,
      'domain': instance.domain,
      'rand': instance.rand,
      'relate': instance.relate,
      'shareLink': instance.shareLink,
      'status': instance.status,
      'vod': instance.vod,
    };
