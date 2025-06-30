import 'package:json_annotation/json_annotation.dart';
import 'package:shine_booking_app/models/user_model.dart'; // Corrected path

part 'review_reply_model.g.dart';

@JsonSerializable()
class ReviewReply {
  final int replyId; // Assuming replyId is always present
  // ĐÃ XÓA: @JsonKey(name: 'review_id') Review review; // <-- Loại bỏ vòng lặp tham chiếu này
  final User?
  user; // FIX: Make nullable. Backend might not always send full user object, or it could be null.
  final String comment;
  final bool isStoreReply;
  final DateTime? createdAt;
  @JsonKey(name: 'parent_reply_id')
  final int? parentReplyId; // Changed to int? to represent ID, not object
  // List<ReviewReply>? childrenReplies; // Nested replies usually not supported recursively by API for display

  ReviewReply({
    required this.replyId,
    this.user, // FIX: Make nullable in constructor
    required this.comment,
    this.isStoreReply = false,
    this.createdAt,
    this.parentReplyId,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) =>
      _$ReviewReplyFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewReplyToJson(this);
}
