// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayServerInfo _$PlayServerInfoFromJson(Map<String, dynamic> json) =>
    PlayServerInfo(
      (json['Status'] as num).toInt(),
      json['From'] as String,
      json['Show'] as String,
      json['Des'] as String?,
      json['Ps'] as String?,
      json['Target'] as String?,
      json['Parse'] as String?,
      json['Sort'] as String?,
      json['Tip'] as String,
      json['ID'] as String,
    );

Map<String, dynamic> _$PlayServerInfoToJson(PlayServerInfo instance) =>
    <String, dynamic>{
      'Status': instance.status,
      'From': instance.from,
      'Show': instance.show,
      'Des': instance.des,
      'Ps': instance.ps,
      'Target': instance.target,
      'Parse': instance.parse,
      'Sort': instance.sort,
      'Tip': instance.tip,
      'ID': instance.id,
    };
