import 'package:json_annotation/json_annotation.dart';
part 'video_url_info.g.dart';

@JsonSerializable()
class VideoUrlInfo {
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "url")
  String url;

  VideoUrlInfo(this.name, this.url);

  factory VideoUrlInfo.fromJson(Map<String, dynamic> json) => _$VideoUrlInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoUrlInfoToJson(this);

  @override
  String toString() {
    return 'VideoUrlInfo{name: $name, url: $url}';
  }
}