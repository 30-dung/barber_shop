import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/constants/app_constants.dart';
import 'package:shine_booking_app/services/storage_service.dart';

class ApiDashboardService {
  static String get baseUrl => AppConstants.baseUrl;
  static const Duration _timeout = Duration(
    seconds: AppConstants.timeoutDuration,
  );

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
      throw Exception(
        'Lỗi xác thực: ${response.statusCode}. Vui lòng đăng nhập lại.',
      );
    }
  }

  static Future<Map<String, dynamic>> getEmployeeDashboardStats() async {
    final employee = await StorageService.getEmployee();
    if (employee?.employeeId == null) {
      throw Exception('Không tìm thấy ID nhân viên.');
    }
    final employeeId = employee!.employeeId!;

    try {
      // Lấy số cuộc hẹn hôm nay
      final todayResponse = await http
          .get(
            Uri.parse(
              '$baseUrl/api/appointments/employee/$employeeId?period=today',
            ),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);
      await _handleAuthError(todayResponse);

      // Lấy số cuộc hẹn tuần này
      final weeklyResponse = await http
          .get(
            Uri.parse(
              '$baseUrl/api/appointments/employee/$employeeId?period=week',
            ),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);
      await _handleAuthError(weeklyResponse);

      // Lấy doanh thu tháng
      final revenueResponse = await http
          .get(
            Uri.parse(
              '$baseUrl/api/revenue/employee/$employeeId?month=${DateTime.now().month}&year=${DateTime.now().year}',
            ),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);
      await _handleAuthError(revenueResponse);

      // Lấy đánh giá
      final reviewsResponse = await http
          .get(
            Uri.parse('$baseUrl/api/reviews/employee/$employeeId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);
      await _handleAuthError(reviewsResponse);

      // Tổng hợp dữ liệu
      Map<String, dynamic> stats = {
        'todayAppointments': 0,
        'weeklyAppointments': 0,
        'monthlyRevenue': 0.0,
        'averageRating': 0.0,
        'totalReviews': 0,
        'completedAppointments': 0,
      };

      if (todayResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(todayResponse.bodyBytes));
        stats['todayAppointments'] = data['count'] ?? 0;
      }

      if (weeklyResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(weeklyResponse.bodyBytes));
        stats['weeklyAppointments'] = data['count'] ?? 0;
        stats['completedAppointments'] = data['completedCount'] ?? 0;
      }

      if (revenueResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(revenueResponse.bodyBytes));
        stats['monthlyRevenue'] = data['totalRevenue']?.toDouble() ?? 0.0;
      }

      if (reviewsResponse.statusCode == 200) {
        final data = jsonDecode(utf8.decode(reviewsResponse.bodyBytes));
        stats['averageRating'] = data['averageRating']?.toDouble() ?? 0.0;
        stats['totalReviews'] = data['totalReviews'] ?? 0;
      }

      log('Employee Dashboard Stats: $stats');
      return stats;
    } catch (e) {
      log('Lỗi tải thống kê nhân viên: $e');
      rethrow;
    }
  }
}
