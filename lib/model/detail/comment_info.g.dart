// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentInfo _$CommentInfoFromJson(Map<String, dynamic> json) => CommentInfo(
  (json['CommentID'] as num).toInt(),
  (json['CommentType'] as num).toInt(),
  json['CommentVid'] as String,
  (json['CommentHide'] as num).toInt(),
  (json['CommentIp'] as num).toInt(),
  (json['UserID'] as num).toInt(),
  json['CommentName'] as String,
  json['CommentContent'] as String,
  json['CommentReply'] as String,
  (json['CommentTime'] as num).toInt(),
);

Map<String, dynamic> _$CommentInfoToJson(CommentInfo instance) =>
    <String, dynamic>{
      'CommentID': instance.commentID,
      'CommentType': instance.commentType,
      'CommentVid': instance.commentVid,
      'CommentHide': instance.commentHide,
      'CommentIp': instance.commentIp,
      'UserID': instance.userID,
      'CommentName': instance.commentName,
      'CommentContent': instance.commentContent,
      'CommentReply': instance.commentReply,
      'CommentTime': instance.commentTime,
    };
