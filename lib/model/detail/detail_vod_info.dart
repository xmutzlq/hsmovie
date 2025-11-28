import 'package:ble_project/model/detail/play_server_info.dart';
import 'package:ble_project/model/detail/play_url_info.dart';
import 'package:ble_project/model/support/json_string_to_int.dart';
import 'package:ble_project/model/vod_class.dart';
import 'package:json_annotation/json_annotation.dart';

part 'detail_vod_info.g.dart';

@JsonSerializable()
@JsonStringToInt()
class DetailVodInfo {
  @JsonKey(name: "VodID")
  int? vodID;
  @JsonKey(name: "VodLevel")
  int? vodLevel;
  @JsonKey(name: "TypeID")
  int? typeID;
  @JsonKey(name: "TypeID1")
  int? typeID1;
  @JsonKey(name: "GroupID")
  int? groupID;
  @JsonKey(name: "VodUp")
  int? vodUp;
  @JsonKey(name: "VodName")
  String vodName;
  @JsonKey(name: "VodPic")
  String vodPic;
  @JsonKey(name: "VodActor")
  String vodActor;
  @JsonKey(name: "VodDirector")
  String vodDirector;
  @JsonKey(name: "VodBlurb")
  String? vodBlurb;
  @JsonKey(name: "VodContent")
  String vodContent;
  @JsonKey(name: "VodYear")
  String vodYear;
  @JsonKey(name: "VodScore")
  int? vodScore;
  @JsonKey(name: "VodScoreAll")
  int? vodScoreAll;
  @JsonKey(name: "VodHits")
  int? vodHits;
  @JsonKey(name: "VodScoreNum")
  int? vodScoreNum;
  @JsonKey(name: "VodArea")
  String vodArea;
  @JsonKey(name: "VodRemarks")
  String vodRemarks;
  @JsonKey(name: "Vps")
  String? vps;
  @JsonKey(name: "Vpf")
  String? vpf;
  @JsonKey(name: "Vpl")
  String? vpl;
  @JsonKey(name: "VodHitsWeek")
  int? vodHitsWeek;
  @JsonKey(name: "VodTime")
  int? vodTime;
  @JsonKey(name: "VodPlayServer")
  List<PlayServerInfo>? vodPlayServer;
  @JsonKey(name: "VodPlayUrls")
  PlayUrlInfo? vodPlayUrls;
  @JsonKey(name: "VodClass")
  VodClass vodClass;

  DetailVodInfo(
      this.vodID,
      this.vodLevel,
      this.typeID,
      this.typeID1,
      this.groupID,
      this.vodUp,
      this.vodName,
      this.vodPic,
      this.vodActor,
      this.vodDirector,
      this.vodBlurb,
      this.vodContent,
      this.vodYear,
      this.vodScore,
      this.vodScoreAll,
      this.vodHits,
      this.vodScoreNum,
      this.vodArea,
      this.vodRemarks,
      this.vps,
      this.vpf,
      this.vpl,
      this.vodHitsWeek,
      this.vodTime,
      this.vodPlayServer,
      this.vodPlayUrls,
      this.vodClass);

  factory DetailVodInfo.fromJson(Map<String, dynamic> json) => _$DetailVodInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DetailVodInfoToJson(this);
}