// lib/models/review_summary_model.dart
import 'package:json_annotation/json_annotation.dart';
// import 'package:shine_booking_app/models/store_model.dart'; // Import Store model nếu cần

part 'review_summary_model.g.dart';

@JsonSerializable()
class ReviewSummaryModel {
  final int storeId;
  final String? storeName;
  final String? storeImageUrl;
  final double? averageRating;
  final int? totalReviews;
  final Map<String, int>? ratingDistribution;
  final List<EmployeeRatingSummary>? employeeRatings;
  final List<ServiceRatingSummary>? serviceRatings;

  ReviewSummaryModel({
    required this.storeId,
    this.storeName,
    this.storeImageUrl,
    this.averageRating,
    this.totalReviews,
    this.ratingDistribution,
    this.employeeRatings,
    this.serviceRatings,
  });

  factory ReviewSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewSummaryModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewSummaryModelToJson(this);
}

@JsonSerializable()
class EmployeeRatingSummary {
  final int? employeeId;
  final String? employeeName;
  final double? averageRating;
  final int? totalReviews;
  final String? avatarUrl; // NEW: Added avatarUrl for employee

  EmployeeRatingSummary({
    this.employeeId,
    this.employeeName,
    this.averageRating,
    this.totalReviews,
    this.avatarUrl, // NEW: Add to constructor
  });

  factory EmployeeRatingSummary.fromJson(Map<String, dynamic> json) =>
      _$EmployeeRatingSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeRatingSummaryToJson(this);
}

@JsonSerializable()
class ServiceRatingSummary {
  final int? serviceId;
  final String? serviceName;
  final double? averageRating;
  final int? totalReviews;

  ServiceRatingSummary({
    this.serviceId,
    this.serviceName,
    this.averageRating,
    this.totalReviews,
  });

  factory ServiceRatingSummary.fromJson(Map<String, dynamic> json) =>
      _$ServiceRatingSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceRatingSummaryToJson(this);
}
