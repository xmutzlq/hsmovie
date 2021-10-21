// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'play_url_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayUrlInfo _$PlayUrlInfoFromJson(Map<String, dynamic> json) {
  return PlayUrlInfo(
    (json['hnm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList(),
    (json['zjm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList(),
  )
    ..youku = (json['youku'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..mgtv = (json['mgtv'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..tt = (json['tt'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..qq = (json['qq'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..kbm3u8 = (json['kbm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..ckm3u8 = (json['ckm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..qiyi = (json['qiyi'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..bjm3u8 = (json['bjm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..tkm3u8 = (json['tkm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..dbm3u8 = (json['dbm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..bdxm3u8 = (json['bdxm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..wjm3u8 = (json['wjm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList()
    ..zkm3u8 = (json['zkm3u8'] as List<dynamic>?)
        ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
        .toList();
}

Map<String, dynamic> _$PlayUrlInfoToJson(PlayUrlInfo instance) =>
    <String, dynamic>{
      'youku': instance.youku,
      'mgtv': instance.mgtv,
      'tt': instance.tt,
      'qq': instance.qq,
      'kbm3u8': instance.kbm3u8,
      'ckm3u8': instance.ckm3u8,
      'qiyi': instance.qiyi,
      'bjm3u8': instance.bjm3u8,
      'tkm3u8': instance.tkm3u8,
      'dbm3u8': instance.dbm3u8,
      'hnm3u8': instance.hnm3u8,
      'bdxm3u8': instance.bdxm3u8,
      'wjm3u8': instance.wjm3u8,
      'zkm3u8': instance.zkm3u8,
      'zjm3u8': instance.zjm3u8,
    };
