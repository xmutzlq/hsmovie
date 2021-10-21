import 'package:json_annotation/json_annotation.dart';
part 'vod_class.g.dart';

@JsonSerializable()
class VodClass {
  @JsonKey(name: "TypeID")
  int typeID;
  @JsonKey(name: "TypeName")
  String typeName;

  VodClass(this.typeID, this.typeName);

  factory VodClass.fromJson(Map<String, dynamic> json) => _$VodClassFromJson(json);
  Map<String, dynamic> toJson() => _$VodClassToJson(this);
}