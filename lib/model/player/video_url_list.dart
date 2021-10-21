import 'package:ble_project/model/player/video_url_info.dart';
import 'package:json_annotation/json_annotation.dart';
part 'video_url_list.g.dart';

@JsonSerializable()
class VideoUrlList {
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "list")
  List<VideoUrlInfo> list;

  VideoUrlList(this.name, this.list);

  factory VideoUrlList.fromJson(Map<String, dynamic> json) => _$VideoUrlListFromJson(json);
  Map<String, dynamic> toJson() => _$VideoUrlListToJson(this);

  @override
  String toString() {
    return 'VideoUrlList{name: $name, list: $list}';
  }
}