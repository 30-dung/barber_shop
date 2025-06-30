// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_reply_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewReply _$ReviewReplyFromJson(Map<String, dynamic> json) => ReviewReply(
  replyId: (json['replyId'] as num).toInt(),
  user:
      json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
  comment: json['comment'] as String,
  isStoreReply: json['isStoreReply'] as bool? ?? false,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  parentReplyId: (json['parent_reply_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$ReviewReplyToJson(ReviewReply instance) =>
    <String, dynamic>{
      'replyId': instance.replyId,
      'user': instance.user,
      'comment': instance.comment,
      'isStoreReply': instance.isStoreReply,
      'createdAt': instance.createdAt?.toIso8601String(),
      'parent_reply_id': instance.parentReplyId,
    };
