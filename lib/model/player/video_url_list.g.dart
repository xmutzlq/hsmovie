// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_url_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoUrlList _$VideoUrlListFromJson(Map<String, dynamic> json) {
  return VideoUrlList(
    json['name'] as String,
    (json['list'] as List<dynamic>)
        .map((e) => VideoUrlInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$VideoUrlListToJson(VideoUrlList instance) =>
    <String, dynamic>{
      'name': instance.name,
      'list': instance.list,
    };
