// lib/models/review_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:shine_booking_app/models/user_model.dart'; // Make sure this is correctly imported if User model is used within Reviewer
import 'package:shine_booking_app/models/review_reply_model.dart'; // Ensure ReviewReply model is correctly imported

part 'review_model.g.dart';

// Helper class for the reviewer data in the Review model
@JsonSerializable()
class Reviewer {
  final int? userId; // FIX: Make nullable
  final String? fullName; // FIX: Make nullable
  final String? email; // email can be null or missing

  Reviewer({this.userId, this.fullName, this.email});

  factory Reviewer.fromJson(Map<String, dynamic> json) =>
      _$ReviewerFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewerToJson(this);
}

@JsonSerializable()
class Review {
  @JsonKey(name: 'mainReviewId')
  final int reviewId;
  final Reviewer? reviewer; // FIX: Make nullable
  final int appointmentId;
  final String appointmentSlug;
  final String storeName;
  final int storeId;
  final String? employeeName;
  final int? employeeId;
  final String? serviceName;
  final int? storeServiceId;
  final int storeRating;
  final int? employeeRating;
  final int? serviceRating;
  final String? comment;
  final DateTime createdAt;
  final List<ReviewReply>? replies;

  Review({
    required this.reviewId,
    this.reviewer, // FIX: Make nullable in constructor
    required this.appointmentId,
    required this.appointmentSlug,
    required this.storeName,
    required this.storeId,
    this.employeeName,
    this.employeeId,
    this.serviceName,
    this.storeServiceId,
    required this.storeRating,
    this.employeeRating,
    this.serviceRating,
    this.comment,
    required this.createdAt,
    this.replies,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
