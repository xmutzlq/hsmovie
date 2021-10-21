// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_vod_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailVodInfo _$DetailVodInfoFromJson(Map<String, dynamic> json) {
  return DetailVodInfo(
    json['VodID'] as int,
    json['VodLevel'] as int,
    json['TypeID'] as int,
    json['TypeID1'] as int,
    json['GroupID'] as int,
    json['VodUp'] as int,
    json['VodName'] as String,
    json['VodPic'] as String,
    json['VodActor'] as String,
    json['VodDirector'] as String,
    json['VodBlurb'] as String,
    json['VodContent'] as String,
    json['VodYear'] as String,
    json['VodScore'] as int,
    json['VodScoreAll'] as int,
    json['VodHits'] as int,
    json['VodScoreNum'] as int,
    json['VodArea'] as String,
    json['VodRemarks'] as String,
    json['Vps'] as String,
    json['Vpf'] as String,
    json['Vpl'] as String,
    json['VodHitsWeek'] as String,
    json['VodTime'] as int,
    (json['VodPlayServer'] as List<dynamic>?)
        ?.map((e) => PlayServerInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['VodPlayUrls'] == null
        ? null
        : PlayUrlInfo.fromJson(json['VodPlayUrls'] as Map<String, dynamic>),
    VodClass.fromJson(json['VodClass'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$DetailVodInfoToJson(DetailVodInfo instance) =>
    <String, dynamic>{
      'VodID': instance.vodID,
      'VodLevel': instance.vodLevel,
      'TypeID': instance.typeID,
      'TypeID1': instance.typeID1,
      'GroupID': instance.groupID,
      'VodUp': instance.vodUp,
      'VodName': instance.vodName,
      'VodPic': instance.vodPic,
      'VodActor': instance.vodActor,
      'VodDirector': instance.vodDirector,
      'VodBlurb': instance.vodBlurb,
      'VodContent': instance.vodContent,
      'VodYear': instance.vodYear,
      'VodScore': instance.vodScore,
      'VodScoreAll': instance.vodScoreAll,
      'VodHits': instance.vodHits,
      'VodScoreNum': instance.vodScoreNum,
      'VodArea': instance.vodArea,
      'VodRemarks': instance.vodRemarks,
      'Vps': instance.vps,
      'Vpf': instance.vpf,
      'Vpl': instance.vpl,
      'VodHitsWeek': instance.vodHitsWeek,
      'VodTime': instance.vodTime,
      'VodPlayServer': instance.vodPlayServer,
      'VodPlayUrls': instance.vodPlayUrls,
      'VodClass': instance.vodClass,
    };
