import 'package:json_annotation/json_annotation.dart';

part 'play_server_info.g.dart';

@JsonSerializable()
class PlayServerInfo {
  @JsonKey(name: "Status")
  int status;
  @JsonKey(name: "From")
  String from;
  @JsonKey(name: "Show")
  String show;
  @JsonKey(name: "Des")
  String? des;
  @JsonKey(name: "Ps")
  String? ps;
  @JsonKey(name: "Target")
  String? target;
  @JsonKey(name: "Parse")
  String? parse;
  @JsonKey(name: "Sort")
  String? sort;
  @JsonKey(name: "Tip")
  String tip;
  @JsonKey(name: "ID")
  String id;

  PlayServerInfo(this.status, this.from, this.show, this.des, this.ps,
      this.target, this.parse, this.sort, this.tip, this.id);

  factory PlayServerInfo.fromJson(Map<String, dynamic> json) => _$PlayServerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PlayServerInfoToJson(this);
}