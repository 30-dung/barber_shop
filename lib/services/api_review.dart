// lib/services/api_review.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import '../models/review_model.dart';
import '../models/review_summary_model.dart';
import '../models/review_target_type_model.dart';
import '../services/storage_service.dart'; // Import StorageService
import 'package:shine_booking_app/constants/app_constants.dart';

class ApiReviewService {
  static String get baseUrl => AppConstants.baseUrl;

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getToken();
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Phương thức để lấy danh sách đánh giá chi tiết
  static Future<List<Review>> getReviewsByStoreId(int storeId) async {
    final uri = Uri.parse(
      '$baseUrl/api/reviews/store/$storeId/filtered?page=0&size=50&sortBy=createdAt&sortDir=desc',
    );

    final response = await http.get(uri, headers: await _getAuthHeaders());

    log('API Review List Response Status: ${response.statusCode}');
    log('API Review List Response Body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(
        utf8.decode(response.bodyBytes),
      );
      final List dataContent = responseData['content'] as List;
      return dataContent.map((e) => Review.fromJson(e)).toList();
    }
    throw Exception(
      'Failed to load reviews: ${response.statusCode} ${utf8.decode(response.bodyBytes)}',
    );
  }

  // Phương thức để trả lời đánh giá
  static Future<void> replyToReview(int reviewId, String comment) async {
    final user = await StorageService.getUser(); // Lấy thông tin người dùng
    if (user == null || user.userId == null) {
      throw Exception('Không thể lấy User ID. Vui lòng đăng nhập lại.');
    }
    final int userId = user.userId!;

    final requestBody = {
      'reviewId': reviewId, // FIX: Thêm reviewId vào body
      'userId': userId, // FIX: Thêm userId vào body
      'comment': comment,
      'isStoreReply': true, // Giả sử phản hồi này là từ cửa hàng (nhân viên)
    };

    log('Sending reply request: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse('$baseUrl/api/reviews/$reviewId/replies'),
      headers: await _getAuthHeaders(),
      body: json.encode(requestBody), // Gửi requestBody đã cập nhật
    );

    log('Reply API response status: ${response.statusCode}');
    log('Reply API response body: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Failed to send reply: ${response.statusCode}';
      try {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (e) {
        log('Error parsing reply error response: $e');
      }
      throw Exception(errorMessage);
    }
  }

  // API để lấy tóm tắt đánh giá của cửa hàng
  static Future<ReviewSummaryModel> getStoreReviewSummary(int storeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/reviews/store/$storeId/summary'),
      headers: await _getAuthHeaders(),
    );
    if (response.statusCode == 200) {
      return ReviewSummaryModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception(
        'Failed to load review summary: ${response.statusCode} ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  // Phương thức để tạo đánh giá
  static Future<void> createReview({
    required int appointmentId,
    required int targetId,
    required ReviewTargetType targetType,
    required int rating,
    String? comment,
    required int userId,
  }) async {
    final headers = await _getAuthHeaders();
    final requestBody = {
      'userId': userId,
      'appointmentId': appointmentId,
      'targetId': targetId,
      'targetType': targetType.name,
      'rating': rating,
      'comment': comment,
    };

    log('Sending review request: ${json.encode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/reviews'),
        headers: headers,
        body: json.encode(requestBody),
      );

      log('Review API response status: ${response.statusCode}');
      log('Review API response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else {
        String errorMessage = 'Failed to create review: ${response.statusCode}';
        try {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing review error response: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Network error creating review: $e');
      throw Exception('Network error: $e');
    }
  }

  // Phương thức để kiểm tra xem một cuộc hẹn đã được đánh giá chưa
  static Future<bool> checkReviewExistsForAppointment(int appointmentId) async {
    final uri = Uri.parse(
      '$baseUrl/api/reviews/existsByAppointmentId?appointmentId=$appointmentId',
    );
    try {
      final response = await http.get(uri, headers: await _getAuthHeaders());

      log(
        'Check review exists status for appointmentId $appointmentId: ${response.statusCode}',
      );
      log('Check review exists body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes)) as bool;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        String errorMessage =
            'Failed to check review status: ${response.statusCode}';
        try {
          final errorBody = json.decode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response for checkReviewExists: $e');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Network error checking review status: $e');
      throw Exception('Network error: $e');
    }
  }
}
