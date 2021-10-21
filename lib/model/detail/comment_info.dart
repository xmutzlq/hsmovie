import 'package:json_annotation/json_annotation.dart';

part 'comment_info.g.dart';

@JsonSerializable()
class CommentInfo {
  @JsonKey(name: "CommentID")
  int commentID;
  @JsonKey(name: "CommentType")
  int commentType;
  @JsonKey(name: "CommentVid")
  String commentVid;
  @JsonKey(name: "CommentHide")
  int commentHide;
  @JsonKey(name: "CommentIp")
  int commentIp;
  @JsonKey(name: "UserID")
  int userID;
  @JsonKey(name: "CommentName")
  String commentName;
  @JsonKey(name: "CommentContent")
  String commentContent;
  @JsonKey(name: "CommentReply")
  String commentReply;
  @JsonKey(name: "CommentTime")
  int commentTime;

  CommentInfo(
      this.commentID,
      this.commentType,
      this.commentVid,
      this.commentHide,
      this.commentIp,
      this.userID,
      this.commentName,
      this.commentContent,
      this.commentReply,
      this.commentTime);

  factory CommentInfo.fromJson(Map<String, dynamic> json) => _$CommentInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CommentInfoToJson(this);
}