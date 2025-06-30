// api_worktimeslot.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import '../constants/app_constants.dart';
import 'package:shine_booking_app/models/working_time_slot_model.dart'; // Import model WorkingTimeSlot

class ApiWorktimeslot {
  static const Duration _timeout = Duration(
    seconds: AppConstants.timeoutDuration,
  );

  static String get baseUrl => AppConstants.baseUrl;

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getToken();
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<void> _handleAuthError(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await StorageService.clearStorage();
      throw Exception('Tài khoản mật khẩu không chính xác, Vui lòng thử lại!');
    }
  }

  // Phương thức đăng ký khung giờ làm việc cho nhân viên
  // Endpoint: POST /api/working-time-slots/registration
  static Future<WorkingTimeSlot> registerWorkTimeSlot(
    Map<String, dynamic> data,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/working-time-slots/registration',
    ); // Endpoint chính xác

    try {
      final response = await http
          .post(uri, headers: await _getAuthHeaders(), body: json.encode(data))
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WorkingTimeSlot.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
        );
      } else {
        String errorMessage =
            'Không thể đăng ký lịch làm: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Register work time slot network error: $e');
      throw Exception('Không thể đăng ký lịch làm: $e');
    }
  }

  // Phương thức để lấy danh sách các slot làm việc của nhân viên (nếu có API)
  static Future<List<WorkingTimeSlot>> getEmployeeWorkTimeSlots(
    int employeeId,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/working-time-slots/list',
    ); // Giả định endpoint

    try {
      final token = await StorageService.getToken();
      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              if (token != null && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<WorkingTimeSlot>.from(
          list.map((model) => WorkingTimeSlot.fromJson(model)),
        );
      } else {
        String errorMessage =
            'Không thể tải lịch làm việc: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Get employee work time slots network error: $e');
      throw Exception('Không thể tải lịch làm việc: $e');
    }
  }
}
