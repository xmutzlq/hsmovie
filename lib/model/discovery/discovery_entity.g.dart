// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiscoveryEntity _$DiscoveryEntityFromJson(Map<String, dynamic> json) =>
    DiscoveryEntity(
      (json['data'] as List<dynamic>)
          .map((e) => MovieInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DiscoveryEntityToJson(DiscoveryEntity instance) =>
    <String, dynamic>{'data': instance.data};
