// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewSummaryModel _$ReviewSummaryModelFromJson(
  Map<String, dynamic> json,
) => ReviewSummaryModel(
  storeId: (json['storeId'] as num).toInt(),
  storeName: json['storeName'] as String?,
  storeImageUrl: json['storeImageUrl'] as String?,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
  ratingDistribution: (json['ratingDistribution'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, (e as num).toInt())),
  employeeRatings:
      (json['employeeRatings'] as List<dynamic>?)
          ?.map(
            (e) => EmployeeRatingSummary.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  serviceRatings:
      (json['serviceRatings'] as List<dynamic>?)
          ?.map((e) => ServiceRatingSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ReviewSummaryModelToJson(ReviewSummaryModel instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'storeImageUrl': instance.storeImageUrl,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'ratingDistribution': instance.ratingDistribution,
      'employeeRatings': instance.employeeRatings,
      'serviceRatings': instance.serviceRatings,
    };

EmployeeRatingSummary _$EmployeeRatingSummaryFromJson(
  Map<String, dynamic> json,
) => EmployeeRatingSummary(
  employeeId: (json['employeeId'] as num?)?.toInt(),
  employeeName: json['employeeName'] as String?,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$EmployeeRatingSummaryToJson(
  EmployeeRatingSummary instance,
) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'employeeName': instance.employeeName,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
  'avatarUrl': instance.avatarUrl,
};

ServiceRatingSummary _$ServiceRatingSummaryFromJson(
  Map<String, dynamic> json,
) => ServiceRatingSummary(
  serviceId: (json['serviceId'] as num?)?.toInt(),
  serviceName: json['serviceName'] as String?,
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  totalReviews: (json['totalReviews'] as num?)?.toInt(),
);

Map<String, dynamic> _$ServiceRatingSummaryToJson(
  ServiceRatingSummary instance,
) => <String, dynamic>{
  'serviceId': instance.serviceId,
  'serviceName': instance.serviceName,
  'averageRating': instance.averageRating,
  'totalReviews': instance.totalReviews,
};
