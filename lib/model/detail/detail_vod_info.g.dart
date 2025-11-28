// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_vod_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetailVodInfo _$DetailVodInfoFromJson(Map<String, dynamic> json) =>
    DetailVodInfo(
      const JsonStringToInt().fromJson(json['VodID']),
      const JsonStringToInt().fromJson(json['VodLevel']),
      const JsonStringToInt().fromJson(json['TypeID']),
      const JsonStringToInt().fromJson(json['TypeID1']),
      const JsonStringToInt().fromJson(json['GroupID']),
      const JsonStringToInt().fromJson(json['VodUp']),
      json['VodName'] as String,
      json['VodPic'] as String,
      json['VodActor'] as String,
      json['VodDirector'] as String,
      json['VodBlurb'] as String?,
      json['VodContent'] as String,
      json['VodYear'] as String,
      const JsonStringToInt().fromJson(json['VodScore']),
      const JsonStringToInt().fromJson(json['VodScoreAll']),
      const JsonStringToInt().fromJson(json['VodHits']),
      const JsonStringToInt().fromJson(json['VodScoreNum']),
      json['VodArea'] as String,
      json['VodRemarks'] as String,
      json['Vps'] as String?,
      json['Vpf'] as String?,
      json['Vpl'] as String?,
      const JsonStringToInt().fromJson(json['VodHitsWeek']),
      const JsonStringToInt().fromJson(json['VodTime']),
      (json['VodPlayServer'] as List<dynamic>?)
          ?.map((e) => PlayServerInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['VodPlayUrls'] == null
          ? null
          : PlayUrlInfo.fromJson(json['VodPlayUrls'] as Map<String, dynamic>),
      VodClass.fromJson(json['VodClass'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DetailVodInfoToJson(DetailVodInfo instance) =>
    <String, dynamic>{
      'VodID': _$JsonConverterToJson<dynamic, int>(
        instance.vodID,
        const JsonStringToInt().toJson,
      ),
      'VodLevel': _$JsonConverterToJson<dynamic, int>(
        instance.vodLevel,
        const JsonStringToInt().toJson,
      ),
      'TypeID': _$JsonConverterToJson<dynamic, int>(
        instance.typeID,
        const JsonStringToInt().toJson,
      ),
      'TypeID1': _$JsonConverterToJson<dynamic, int>(
        instance.typeID1,
        const JsonStringToInt().toJson,
      ),
      'GroupID': _$JsonConverterToJson<dynamic, int>(
        instance.groupID,
        const JsonStringToInt().toJson,
      ),
      'VodUp': _$JsonConverterToJson<dynamic, int>(
        instance.vodUp,
        const JsonStringToInt().toJson,
      ),
      'VodName': instance.vodName,
      'VodPic': instance.vodPic,
      'VodActor': instance.vodActor,
      'VodDirector': instance.vodDirector,
      'VodBlurb': instance.vodBlurb,
      'VodContent': instance.vodContent,
      'VodYear': instance.vodYear,
      'VodScore': _$JsonConverterToJson<dynamic, int>(
        instance.vodScore,
        const JsonStringToInt().toJson,
      ),
      'VodScoreAll': _$JsonConverterToJson<dynamic, int>(
        instance.vodScoreAll,
        const JsonStringToInt().toJson,
      ),
      'VodHits': _$JsonConverterToJson<dynamic, int>(
        instance.vodHits,
        const JsonStringToInt().toJson,
      ),
      'VodScoreNum': _$JsonConverterToJson<dynamic, int>(
        instance.vodScoreNum,
        const JsonStringToInt().toJson,
      ),
      'VodArea': instance.vodArea,
      'VodRemarks': instance.vodRemarks,
      'Vps': instance.vps,
      'Vpf': instance.vpf,
      'Vpl': instance.vpl,
      'VodHitsWeek': _$JsonConverterToJson<dynamic, int>(
        instance.vodHitsWeek,
        const JsonStringToInt().toJson,
      ),
      'VodTime': _$JsonConverterToJson<dynamic, int>(
        instance.vodTime,
        const JsonStringToInt().toJson,
      ),
      'VodPlayServer': instance.vodPlayServer,
      'VodPlayUrls': instance.vodPlayUrls,
      'VodClass': instance.vodClass,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
