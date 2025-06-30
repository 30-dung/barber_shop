// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reviewer _$ReviewerFromJson(Map<String, dynamic> json) => Reviewer(
  userId: (json['userId'] as num?)?.toInt(),
  fullName: json['fullName'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$ReviewerToJson(Reviewer instance) => <String, dynamic>{
  'userId': instance.userId,
  'fullName': instance.fullName,
  'email': instance.email,
};

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  reviewId: (json['mainReviewId'] as num).toInt(),
  reviewer:
      json['reviewer'] == null
          ? null
          : Reviewer.fromJson(json['reviewer'] as Map<String, dynamic>),
  appointmentId: (json['appointmentId'] as num).toInt(),
  appointmentSlug: json['appointmentSlug'] as String,
  storeName: json['storeName'] as String,
  storeId: (json['storeId'] as num).toInt(),
  employeeName: json['employeeName'] as String?,
  employeeId: (json['employeeId'] as num?)?.toInt(),
  serviceName: json['serviceName'] as String?,
  storeServiceId: (json['storeServiceId'] as num?)?.toInt(),
  storeRating: (json['storeRating'] as num).toInt(),
  employeeRating: (json['employeeRating'] as num?)?.toInt(),
  serviceRating: (json['serviceRating'] as num?)?.toInt(),
  comment: json['comment'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  replies:
      (json['replies'] as List<dynamic>?)
          ?.map((e) => ReviewReply.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'mainReviewId': instance.reviewId,
  'reviewer': instance.reviewer,
  'appointmentId': instance.appointmentId,
  'appointmentSlug': instance.appointmentSlug,
  'storeName': instance.storeName,
  'storeId': instance.storeId,
  'employeeName': instance.employeeName,
  'employeeId': instance.employeeId,
  'serviceName': instance.serviceName,
  'storeServiceId': instance.storeServiceId,
  'storeRating': instance.storeRating,
  'employeeRating': instance.employeeRating,
  'serviceRating': instance.serviceRating,
  'comment': instance.comment,
  'createdAt': instance.createdAt.toIso8601String(),
  'replies': instance.replies,
};
