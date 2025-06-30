// lib/services/api_appointments.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer'; // For logging
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/constants/app_constants.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import 'package:shine_booking_app/models/appointment_model.dart'; // Import Appointment model

class ApiAppointmentsService {
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

  // FIX: Thay đổi _handleAuthError để không xóa storage.
  // Lỗi xác thực sẽ được xử lý ở lớp gọi (ví dụ, trong main.dart hoặc wrapper service)
  static Future<void> _handleAuthError(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      // KHÔNG XÓA STORAGE Ở ĐÂY NỮA
      throw Exception(
        'Lỗi xác thực: ${response.statusCode}. Vui lòng đăng nhập lại.',
      );
    }
  }

  // Phương thức để lấy tất cả cuộc hẹn của người dùng hiện tại
  static Future<List<Appointment>> getUserBookings() async {
    final uri = Uri.parse(
      '$baseUrl/api/appointments', // Endpoint bạn đã cung cấp cho API người dùng
    );

    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);

      await _handleAuthError(response); // Kiểm tra lỗi xác thực

      if (response.statusCode == 200) {
        log(
          'Raw API response for user bookings: ${utf8.decode(response.bodyBytes)}',
        ); // Debug log

        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<Appointment>.from(
          list.map((model) => Appointment.fromJson(model)),
        );
      } else if (response.statusCode == 404) {
        // Handle 404 specifically if it means no bookings found
        log('No bookings found (404), returning empty list.');
        return [];
      } else {
        String errorMessage =
            'Không thể tải cuộc hẹn của người dùng: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log(
            'Error parsing error body for user bookings: $e',
          ); // Log parsing error
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Get user bookings network error: $e');
      throw Exception('Không thể tải cuộc hẹn của người dùng: $e');
    }
  }

  // Phương thức để lấy tất cả cuộc hẹn của một nhân viên bằng email
  static Future<List<Appointment>> getAppointmentsByEmployeeEmail(
    String employeeEmail,
  ) async {
    final uri = Uri.parse('$baseUrl/api/appointments/employee/$employeeEmail');

    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);

      await _handleAuthError(response); // Kiểm tra lỗi xác thực

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<Appointment>.from(
          list.map((model) => Appointment.fromJson(model)),
        );
      } else {
        String errorMessage =
            'Không thể tải cuộc hẹn của nhân viên: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Get appointments by employee email network error: $e');
      throw Exception('Không thể tải cuộc hẹn của nhân viên: $e');
    }
  }

  // Phương thức để cập nhật trạng thái cuộc hẹn (Confirm)
  static Future<void> confirmAppointment(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/api/appointments/$appointmentId/confirm');

    try {
      final response = await http
          .patch(
            uri,
            headers: await _getAuthHeaders(),
          ) // PATCH request for confirm
          .timeout(_timeout);

      await _handleAuthError(response); // Kiểm tra lỗi xác thực

      if (response.statusCode != 200) {
        String message = 'Không thể xác nhận cuộc hẹn: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          message = errorBody['message'] ?? message;
        } catch (_) {}
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Confirm appointment network error: $e');
      throw Exception('Không thể xác nhận cuộc hẹn: $e');
    }
  }

  // Phương thức để cập nhật trạng thái cuộc hẹn (Complete)
  static Future<void> completeAppointment(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/api/appointments/$appointmentId/complete');

    try {
      final response = await http
          .patch(
            uri,
            headers: await _getAuthHeaders(),
          ) // PATCH request for complete
          .timeout(_timeout);

      await _handleAuthError(response); // Kiểm tra lỗi xác thực

      if (response.statusCode != 200) {
        String message =
            'Không thể hoàn thành cuộc hẹn: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          message = errorBody['message'] ?? message;
        } catch (_) {}
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Complete appointment network error: $e');
      throw Exception('Không thể hoàn thành cuộc hẹn: $e');
    }
  }

  // Phương thức để cập nhật trạng thái cuộc hẹn (Cancel)
  static Future<void> cancelAppointment(int appointmentId) async {
    final uri = Uri.parse('$baseUrl/api/appointments/$appointmentId/cancel');
    final token = await StorageService.getToken();

    try {
      final response = await http
          .patch(
            uri,
            headers: await _getAuthHeaders(), // Sử dụng headers có token
          )
          .timeout(_timeout);

      await _handleAuthError(response); // Kiểm tra lỗi xác thực

      log('Cancel appointment response status: ${response.statusCode}');
      log(
        'Cancel appointment response body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode != 200) {
        String message = 'Không thể hủy cuộc hẹn: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          message = errorBody['message'] ?? message;
        } catch (_) {}
        throw Exception(message);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Cancel appointment network error: $e');
      throw Exception('Không thể hủy cuộc hẹn: $e');
    }
  }

  // Phương thức để tạo cuộc hẹn mới (chuyển từ ApiService)
  static Future<Map<String, dynamic>> createAppointment({
    required int timeSlotId,
    required int storeServiceId,
    required String startTime,
    required String endTime,
    String? notes,
  }) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please log in.');
    }

    try {
      final appointmentData = {
        'timeSlotId': timeSlotId,
        'storeServiceId': storeServiceId,
        'startTime': startTime,
        'endTime': endTime,
        'notes': notes ?? '',
      };

      log('Creating appointment with data: $appointmentData'); // Debug log

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/appointments'),
            headers: await _getAuthHeaders(),
            body: jsonEncode([appointmentData]),
          )
          .timeout(_timeout);

      await _handleAuthError(response); // Kiểm tra lỗi xác thực

      log(
        'Create appointment response status: ${response.statusCode}',
      ); // Debug log
      log('Create appointment response body: ${response.body}'); // Debug log

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));

        if (responseData is List && responseData.isNotEmpty) {
          return responseData[0] as Map<String, dynamic>;
        } else {
          return responseData as Map<String, dynamic>;
        }
      } else {
        String errorMessage =
            'Failed to create appointment: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response: $e'); // Log parsing error
        }
        log('Error creating appointment: $errorMessage'); // Log error
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Network error creating appointment: $e'); // Log network error
      throw Exception('Network error: $e');
    }
  }
}
