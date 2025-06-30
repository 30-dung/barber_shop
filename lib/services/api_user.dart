// lib/services/api_user_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer'; // For logging
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/constants/app_constants.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import 'package:shine_booking_app/models/user_model.dart'; // Import User model

class ApiUserService {
  // Changed class name
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
      throw Exception(
        'Tài khoản mật khẩu không chính xác, Vui lòng đăng nhập lại!',
      );
    }
  }

  // GET /api/user/profile (Lấy thông tin profile của người dùng hiện tại)
  static Future<User> getMyProfile() async {
    // Renamed from getProfile(String token)
    final uri = Uri.parse('$baseUrl/api/user/profile');
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Failed to load user profile: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Vui lòng kiểm tra kết nối internet.');
    } catch (e) {
      log('Error fetching user profile: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT /api/user/update-profile (Cập nhật profile của người dùng hiện tại)
  static Future<User> updateMyProfile(Map<String, dynamic> userData) async {
    // Renamed from updateProfile
    final uri = Uri.parse('$baseUrl/api/user/update-profile');
    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
            body: jsonEncode(userData),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('Update My Profile Response Status: ${response.statusCode}');
      log(
        'Update My Profile Response Body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Không thể cập nhật hồ sơ: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error updating my profile: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT /api/user/update-profile (Thay đổi mật khẩu của người dùng hiện tại)
  static Future<void> changeMyPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/api/user/update-profile',
    ); // Assuming same endpoint for password change
    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('Change password response status: ${response.statusCode}');
      log('Change password response body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        log('Password changed successfully.');
      } else {
        String errorMessage =
            'Failed to change password: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response for changePassword: $e');
        }
        log('Error changing password: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Network error changing password: $e');
      throw Exception('Network error: $e');
    }
  }

  // --- ADMIN User Management APIs ---

  // GET /api/user/customer/all (Lấy danh sách tất cả người dùng khách hàng)
  static Future<List<User>> getAllCustomers() async {
    final uri = Uri.parse('$baseUrl/api/user/customer/all');
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Get All Customers Response Status: ${response.statusCode}');
      log(
        'Get All Customers Response Body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        String errorMessage =
            'Không thể tải danh sách người dùng: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error fetching all customers: $e');
      throw Exception('Network error: $e');
    }
  }

  // GET /api/user/customer/{id} (Lấy thông tin người dùng theo ID)
  static Future<User> getCustomerById(int id) async {
    final uri = Uri.parse('$baseUrl/api/user/customer/$id');
    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Get Customer by ID Response Status: ${response.statusCode}');
      log(
        'Get Customer by ID Response Body: ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Không thể tải thông tin người dùng ID $id: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error fetching customer by ID: $e');
      throw Exception('Network error: $e');
    }
  }

  // POST /api/user/customer/create (Tạo người dùng khách hàng mới)
  static Future<User> createCustomer(Map<String, dynamic> userData) async {
    final uri = Uri.parse('$baseUrl/api/user/customer/create');
    try {
      final response = await http
          .post(
            uri,
            headers: await _getAuthHeaders(),
            body: jsonEncode(userData),
          )
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Create Customer Response Status: ${response.statusCode}');
      log('Create Customer Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Không thể tạo người dùng: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error creating customer: $e');
      throw Exception('Network error: $e');
    }
  }

  // PUT /api/user/custome/update/{id} (Cập nhật thông tin người dùng khách hàng)
  // Note: API path is '/api/user/custome/update/{id}', check for typo 'custome' vs 'customer'
  static Future<User> updateCustomer(
    int id,
    Map<String, dynamic> userData,
  ) async {
    final uri = Uri.parse('$baseUrl/api/user/custome/update/$id');
    try {
      final response = await http
          .put(
            uri,
            headers: await _getAuthHeaders(),
            body: jsonEncode(userData),
          )
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Update Customer Response Status: ${response.statusCode}');
      log('Update Customer Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage =
            'Không thể cập nhật người dùng ID $id: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error updating customer: $e');
      throw Exception('Network error: $e');
    }
  }

  // DELETE /api/user/customer/delete/{id} (Xóa người dùng khách hàng)
  static Future<void> deleteCustomer(int id) async {
    final uri = Uri.parse('$baseUrl/api/user/customer/delete/$id');
    try {
      final response = await http
          .delete(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);
      await _handleAuthError(response);
      log('Delete Customer Response Status: ${response.statusCode}');
      log('Delete Customer Response Body: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content for successful delete
        return;
      } else {
        String errorMessage =
            'Không thể xóa người dùng ID $id: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error deleting customer: $e');
      throw Exception('Network error: $e');
    }
  }
}
