// api_employee.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import '../constants/app_constants.dart';

class ApiEmployeeService {
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

  static Future<List<Employee>> getEmployees({required int storeId}) async {
    final uri = Uri.parse('$baseUrl/api/employees/store/$storeId');

    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<Employee>.from(
          list.map((model) => Employee.fromJson(model)),
        );
      } else {
        String errorMessage =
            'Failed to load employees for store $storeId: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get employees network error: $e');
      throw Exception('Failed to load employees for store $storeId: $e');
    }
  }

  static Future<Employee> getEmployeeDetails(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/employees/profile'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage = 'Failed to load employee profile';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get employee profile network error: $e');
      throw Exception('Failed to load employee profile: $e');
    }
  }

  static Future<List<Employee>> getAllEmployees() async {
    final uri = Uri.parse('$baseUrl/api/employees/all');

    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<Employee>.from(
          list.map((model) => Employee.fromJson(model)),
        );
      } else {
        String errorMessage =
            'Failed to load all employees: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get all employees network error: $e');
      throw Exception('Failed to load all employees: $e');
    }
  }

  static Future<Employee> createEmployee(
    Map<String, dynamic> employeeData,
  ) async {
    final uri = Uri.parse('$baseUrl/api/employees/create');

    try {
      final response = await http
          .post(
            uri,
            headers: await _getAuthHeaders(),
            body: json.encode(employeeData),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Employee.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Failed to create employee: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Create employee network error: $e');
      throw Exception('Failed to create employee: $e');
    }
  }

  // --- CẬP NHẬT CÁC PHƯƠNG THỨC SAU ĐÂY DỰA TRÊN ẢNH SWAGGER ---

  // Phương thức cho admin cập nhật profile nhân viên: PUT /api/employees/{employeeId}/admin-update-profile
  static Future<Employee> adminUpdateEmployeeProfile(
    int employeeId,
    Map<String, dynamic> employeeData,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/employees/$employeeId/admin-update-profile',
    ); // Endpoint chính xác

    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
            body: json.encode(employeeData),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Failed to admin update employee profile: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Admin update employee profile network error: $e');
      throw Exception('Failed to admin update employee profile: $e');
    }
  }

  // Phương thức cho nhân viên cập nhật profile của chính họ: PUT /api/employees/update-profile
  // (Giữ nguyên như đã có trong Swagger)
  static Future<Employee> updateEmployeeProfile(
    Map<String, dynamic> employeeData,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/employees/update-profile',
    ); // Endpoint chính xác

    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
            body: json.encode(employeeData),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Failed to update employee profile: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Update employee profile network error: $e');
      throw Exception('Failed to update employee profile: $e');
    }
  }

  // Phương thức cho admin cập nhật trạng thái hoạt động: PUT /api/employees/{employeeId}/status/{isActive}
  static Future<Employee> updateEmployeeStatus(
    int employeeId,
    bool isActive,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/employees/$employeeId/status/$isActive',
    ); // Endpoint chính xác

    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
          ) // Không có body cho endpoint này
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return Employee.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Failed to update employee status: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Update employee status network error: $e');
      throw Exception('Failed to update employee status: $e');
    }
  }

  // Phương thức cho nhân viên cập nhật mật khẩu: PUT /api/employees/update-profile/password
  // (Giữ nguyên như đã có trong Swagger)
  static Future<String> updateEmployeePassword(
    Map<String, dynamic> passwordData,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/api/employees/update-profile/password',
    ); // Endpoint chính xác

    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
            body: json.encode(passwordData),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return utf8.decode(
          response.bodyBytes,
        ); // Trả về chuỗi thông báo thành công
      } else {
        String errorMessage =
            'Failed to update employee password: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Update employee password network error: $e');
      throw Exception('Failed to update employee password: $e');
    }
  }

  // Phương thức để xóa nhân viên: DELETE /api/employees/{employeeId}
  static Future<void> deleteEmployee(int employeeId) async {
    final uri = Uri.parse(
      '$baseUrl/api/employees/$employeeId',
    ); // Endpoint chính xác

    try {
      final response = await http
          .delete(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // Xóa thành công, không có nội dung trả về
      } else {
        String errorMessage =
            'Failed to delete employee: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Delete employee network error: $e');
      throw Exception('Failed to delete employee: $e');
    }
  }
}
