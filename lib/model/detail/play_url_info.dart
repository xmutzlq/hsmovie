import 'package:json_annotation/json_annotation.dart';

part 'play_url_info.g.dart';

@JsonSerializable()
class PlayUrlInfo extends Object {
  ///优酷视频
  @JsonKey(name: 'youku')
  List<List<String>>? youku;
  ///芒果tv
  @JsonKey(name: 'mgtv')
  List<List<String>>? mgtv;
  ///TT云
  @JsonKey(name: 'tt')
  List<List<String>>? tt;
  ///腾讯
  @JsonKey(name: 'qq')
  List<List<String>>? qq;
  ///快播
  @JsonKey(name: 'kbm3u8')
  List<List<String>>? kbm3u8;
  ///CK播放源
  @JsonKey(name: 'ckm3u8')
  List<List<String>>? ckm3u8;
  ///奇艺视频
  @JsonKey(name: 'qiyi')
  List<List<String>>? qiyi;
  ///八戒资源
  @JsonKey(name: 'bjm3u8')
  List<List<String>>? bjm3u8;
  ///天空资源
  @JsonKey(name: 'tkm3u8')
  List<List<String>>? tkm3u8;
  ///百度资源
  @JsonKey(name: 'dbm3u8')
  List<List<String>>? dbm3u8;
  ///红牛资源
  @JsonKey(name: 'hnm3u8')
  List<List<String>>? hnm3u8;
  ///北斗资源
  @JsonKey(name: 'bdxm3u8')
  List<List<String>>? bdxm3u8;
  ///无尽资源
  @JsonKey(name: 'wjm3u8')
  List<List<String>>? wjm3u8;
  ///最快资源
  @JsonKey(name: 'zkm3u8')
  List<List<String>>? zkm3u8;
  ///自建云
  @JsonKey(name: 'zjm3u8')
  List<List<String>>? zjm3u8;

  PlayUrlInfo(this.hnm3u8, this.zjm3u8);

  factory PlayUrlInfo.fromJson(Map<String, dynamic> json) => _$PlayUrlInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PlayUrlInfoToJson(this);
}