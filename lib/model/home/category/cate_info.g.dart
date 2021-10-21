// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cate_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CateInfo _$CateInfoFromJson(Map<String, dynamic> json) {
  return CateInfo(
    json['cateId'] as String,
    json['cateName'] as String,
    json['cateImg'] as String,
  );
}

Map<String, dynamic> _$CateInfoToJson(CateInfo instance) => <String, dynamic>{
      'cateId': instance.cateId,
      'cateName': instance.cateName,
      'cateImg': instance.cateImg,
    };
