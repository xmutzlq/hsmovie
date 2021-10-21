import 'package:ble_project/model/player/video_url_list.dart';
import 'package:json_annotation/json_annotation.dart';
part 'video_list.g.dart';

@JsonSerializable()
class VideoList {
  @JsonKey(name: "video")
  List<VideoUrlList> video;

  VideoList(this.video);

  factory VideoList.fromJson(Map<String, dynamic> json) => _$VideoListFromJson(json);
  Map<String, dynamic> toJson() => _$VideoListToJson(this);
}