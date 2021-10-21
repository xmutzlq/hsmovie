import 'package:ble_project/model/vod_class.dart';
import 'package:json_annotation/json_annotation.dart';
part 'vod_info.g.dart';

@JsonSerializable()
class VodInfo {
  @JsonKey(name: "VodID")
  int vodID;
  @JsonKey(name: "VodName")
  String vodName;
  @JsonKey(name: "VodPic")
  String vodPic;
  @JsonKey(name: "VodYear")
  String vodYear;
  @JsonKey(name: "VodArea")
  String vodArea;
  @JsonKey(name: "VodRemarks")
  String vodRemarks;
  @JsonKey(name: "VodHits")
  int vodHits;
  @JsonKey(name: "VodActor")
  String vodActor;
  @JsonKey(name: "VodDirector")
  String vodDirector;
  @JsonKey(name: "VodTime")
  int vodTime;
  @JsonKey(name: "VodTypeID")
  int vodTypeID;
  @JsonKey(name: "VodClass")
  VodClass vodClass;

  VodInfo(
      this.vodID,
      this.vodName,
      this.vodPic,
      this.vodYear,
      this.vodArea,
      this.vodRemarks,
      this.vodHits,
      this.vodActor,
      this.vodDirector,
      this.vodTime,
      this.vodTypeID,
      this.vodClass);


  @override
  String toString() {
    return 'VodInfo{vodID: $vodID, vodName: $vodName, vodPic: $vodPic, vodYear: $vodYear, vodArea: $vodArea, vodRemarks: $vodRemarks, vodHits: $vodHits, vodActor: $vodActor, vodDirector: $vodDirector, vodTime: $vodTime, vodTypeID: $vodTypeID, vodClass: $vodClass}';
  }

  factory VodInfo.fromJson(Map<String, dynamic> json) => _$VodInfoFromJson(json);
  Map<String, dynamic> toJson() => _$VodInfoToJson(this);
}