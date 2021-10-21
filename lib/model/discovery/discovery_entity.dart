import 'package:ble_project/model/discovery/movie_info.dart';
import 'package:json_annotation/json_annotation.dart';
part 'discovery_entity.g.dart';

@JsonSerializable()
class DiscoveryEntity {
  List<MovieInfo> data;

  DiscoveryEntity(this.data);

  factory DiscoveryEntity.fromJson(Map<String, dynamic> json) => _$DiscoveryEntityFromJson(json);
  Map<String, dynamic> toJson() => _$DiscoveryEntityToJson(this);

}