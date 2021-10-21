// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VodInfo _$VodInfoFromJson(Map<String, dynamic> json) {
  return VodInfo(
    json['VodID'] as int,
    json['VodName'] as String,
    json['VodPic'] as String,
    json['VodYear'] as String,
    json['VodArea'] as String,
    json['VodRemarks'] as String,
    json['VodHits'] as int,
    json['VodActor'] as String,
    json['VodDirector'] as String,
    json['VodTime'] as int,
    json['VodTypeID'] as int,
    VodClass.fromJson(json['VodClass'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$VodInfoToJson(VodInfo instance) => <String, dynamic>{
      'VodID': instance.vodID,
      'VodName': instance.vodName,
      'VodPic': instance.vodPic,
      'VodYear': instance.vodYear,
      'VodArea': instance.vodArea,
      'VodRemarks': instance.vodRemarks,
      'VodHits': instance.vodHits,
      'VodActor': instance.vodActor,
      'VodDirector': instance.vodDirector,
      'VodTime': instance.vodTime,
      'VodTypeID': instance.vodTypeID,
      'VodClass': instance.vodClass,
    };
