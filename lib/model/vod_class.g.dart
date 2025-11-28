// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vod_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VodClass _$VodClassFromJson(Map<String, dynamic> json) =>
    VodClass((json['TypeID'] as num).toInt(), json['TypeName'] as String);

Map<String, dynamic> _$VodClassToJson(VodClass instance) => <String, dynamic>{
  'TypeID': instance.typeID,
  'TypeName': instance.typeName,
};
