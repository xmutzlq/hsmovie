// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoList _$VideoListFromJson(Map<String, dynamic> json) => VideoList(
  (json['video'] as List<dynamic>)
      .map((e) => VideoUrlList.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$VideoListToJson(VideoList instance) => <String, dynamic>{
  'video': instance.video,
};
