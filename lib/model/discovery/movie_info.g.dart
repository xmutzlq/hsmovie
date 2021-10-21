// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovieInfo _$MovieInfoFromJson(Map<String, dynamic> json) {
  return MovieInfo(
    json['ID'] as int,
    json['Name'] as String,
    (json['Items'] as List<dynamic>)
        .map((e) => VodInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$MovieInfoToJson(MovieInfo instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Items': instance.items,
    };
