import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shine_booking_app/constants/app_constants.dart';
import 'package:shine_booking_app/models/dto/my_payroll_response_model.dart';
import 'package:shine_booking_app/models/payroll_summary_model.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import '../models/salary_record_model.dart';

class ApiSalaryService {
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

  static Future<List<PayrollSummary>> getAllPayrollsForMonth({
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/salary/payroll/monthly?year=$year&month=$month',
    );
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('All Payrolls Response Status: ${response.statusCode}');
      log('All Payrolls Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => PayrollSummary.fromJson(e)).toList();
      } else {
        String errorMessage =
            'Lỗi lấy bảng lương tháng: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Lỗi lấy bảng lương tháng: $e');
      rethrow;
    }
  }

  static Future<List<SalaryRecord>> getAllSalaryRecords() async {
    final uri = Uri.parse('$baseUrl/api/salary/records');
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => SalaryRecord.fromJson(e)).toList();
      } else {
        String errorMessage = 'Lỗi lấy bảng lương: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Lỗi lấy bảng lương: $e');
      rethrow;
    }
  }

  static Future<void> generatePayroll({
    required int employeeId,
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final startDateStr = DateFormat('yyyy-MM-dd').format(startDate);
    final endDateStr = DateFormat('yyyy-MM-dd').format(endDate);

    final uri = Uri.parse(
      '$baseUrl/api/salary/generate-payroll?employeeId=$employeeId&startDate=$startDateStr&endDate=$endDateStr',
    );

    try {
      final response = await http
          .post(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Generate Payroll Response Status: ${response.statusCode}');
      log('Generate Payroll Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = 'Lỗi tạo bảng lương: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Lỗi tạo bảng lương: $e');
    }
  }

  static Future<MyPayrollResponse> getMyPayroll({
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/salary/my-payroll?year=$year&month=$month',
    );
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('My Payroll Response Status: ${response.statusCode}');
      log('My Payroll Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return MyPayrollResponse.fromJson(data);
      } else {
        String errorMessage =
            'Không thể tải bảng lương của bạn: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Lỗi tải bảng lương của tôi: $e');
      rethrow;
    }
  }

  static Future<MyPayrollResponse> getPayrollByEmployeeId({
    required String employeeId,
    required int year,
    required int month,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/salary/payroll/employee?employeeId=$employeeId&year=$year&month=$month',
    );
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Payroll by Employee ID Response Status: ${response.statusCode}');
      log(
        'Payroll by Employee ID Response Body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return MyPayrollResponse.fromJson(data);
      } else {
        String errorMessage =
            'Không thể tải bảng lương của nhân viên $employeeId: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Lỗi tải bảng lương của nhân viên $employeeId: $e');
      rethrow;
    }
  }

  static Future<List<PayrollSummary>> getMyPayrollHistory() async {
    final uri = Uri.parse('$baseUrl/api/salary/my-payroll/history');
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('My Payroll History Response Status: ${response.statusCode}');
      log(
        'My Payroll History Response Body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => PayrollSummary.fromJson(e)).toList();
      } else {
        String errorMessage =
            'Không thể tải lịch sử bảng lương: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('Lỗi tải lịch sử bảng lương: $e');
      rethrow;
    }
  }

  static Future<void> processUnprocessedAppointments() async {
    final uri = Uri.parse(
      '$baseUrl/api/salary/process-unprocessed-appointments',
    );
    try {
      final response = await http
          .post(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log(
        'Process Unprocessed Appointments Response Status: ${response.statusCode}',
      );
      log(
        'Process Unprocessed Appointments Response Body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage =
            'Lỗi xử lý appointments chưa tính lương: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Lỗi xử lý appointments chưa tính lương: $e');
    }
  }

  static Future<void> approvePayroll(int payrollId) async {
    final uri = Uri.parse('$baseUrl/api/salary/payroll/$payrollId/approve');
    try {
      final response = await http
          .post(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Approve Payroll Response Status: ${response.statusCode}');
      log('Approve Payroll Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage =
            'Lỗi phê duyệt bảng lương: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Lỗi phê duyệt bảng lương: $e');
    }
  }

  static Future<void> markAsPaid(int payrollId) async {
    final uri = Uri.parse('$baseUrl/api/salary/payroll/$payrollId/paid');
    try {
      final response = await http
          .post(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Mark As Paid Response Status: ${response.statusCode}');
      log('Mark As Paid Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage =
            'Lỗi đánh dấu thanh toán bảng lương: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Lỗi đánh dấu thanh toán bảng lương: $e');
    }
  }
}
