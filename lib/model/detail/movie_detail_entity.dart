import 'package:ble_project/model/detail/comment_info.dart';
import 'package:ble_project/model/detail/detail_vod_info.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movie_detail_entity.g.dart';

@JsonSerializable()
class MovieDetailEntity {
  @JsonKey(name: "comments")
  List<CommentInfo> comments;
  @JsonKey(name: "count")
  int count;
  @JsonKey(name: "domain")
  String domain;
  @JsonKey(name: "rand")
  List<VodInfo> rand;
  @JsonKey(name: "relate")
  List<VodInfo> relate;
  @JsonKey(name: "shareLink")
  String shareLink;
  @JsonKey(name: "status")
  int status;
  @JsonKey(name: "vod")
  DetailVodInfo vod;


  MovieDetailEntity(this.comments, this.count, this.domain, this.rand,
      this.relate, this.shareLink, this.status, this.vod);

  factory MovieDetailEntity.fromJson(Map<String, dynamic> json) => _$MovieDetailEntityFromJson(json);
  Map<String, dynamic> toJson() => _$MovieDetailEntityToJson(this);
}