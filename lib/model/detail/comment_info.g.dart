// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommentInfo _$CommentInfoFromJson(Map<String, dynamic> json) {
  return CommentInfo(
    json['CommentID'] as int,
    json['CommentType'] as int,
    json['CommentVid'] as String,
    json['CommentHide'] as int,
    json['CommentIp'] as int,
    json['UserID'] as int,
    json['CommentName'] as String,
    json['CommentContent'] as String,
    json['CommentReply'] as String,
    json['CommentTime'] as int,
  );
}

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
