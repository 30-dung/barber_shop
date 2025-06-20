// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shine_booking_app/models/booking_model.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/invoice_model.dart';
import 'package:shine_booking_app/models/service_detail_model.dart';
import 'package:shine_booking_app/models/store_model.dart';
import 'package:shine_booking_app/models/store_service_model.dart';
import 'package:shine_booking_app/models/working_time_slot_model.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/location_count_model.dart';
// ...existing code...

class ApiService {
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

  // Hàm tiện ích kiểm tra lỗi xác thực
  static Future<void> _handleAuthError(http.Response response) async {
    if (response.statusCode == 401 || response.statusCode == 403) {
      await StorageService.clearStorage();
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }
  }

  // --- Authentication Endpoints ---

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        String errorMessage = 'Login failed';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Login network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(userData),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        String errorMessage = 'Registration failed';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Registration network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<void> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to send reset password email';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Forgot password network error: $e');
      throw Exception('Lỗi mạng hoặc hệ thống: $e');
    }
  }

  static Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'token': token, 'newPassword': newPassword}),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to reset password';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Reset password network error: $e');
      throw Exception('Lỗi mạng hoặc hệ thống: $e');
    }
  }

  // --- Service Endpoints ---

  static Future<List<ServiceDetail>> getServices() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/services'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => ServiceDetail.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load services';
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
      log('Get services network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<StoreService>> getServicesByStoreId(int storeId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/services/store/$storeId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<StoreService>.from(
          list.map((model) => StoreService.fromJson(model)),
        );
      } else {
        String errorMessage =
            'Failed to load services for store $storeId: ${response.statusCode}';
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
      log('Get services by store ID network error: $e');
      throw Exception('Failed to load services for store $storeId: $e');
    }
  }

  // --- Store Endpoints ---

  static Future<List<Store>> getStores({String? city, String? district}) async {
    final Map<String, String> queryParams = {};
    if (city != null && city.isNotEmpty) {
      queryParams['city'] = city;
    }
    if (district != null && district.isNotEmpty) {
      queryParams['district'] = district;
    }

    final uri = Uri.parse(
      '$baseUrl/api/store/locate',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http
          .get(uri, headers: await _getAuthHeaders())
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<Store>.from(list.map((model) => Store.fromJson(model)));
      } else {
        String errorMessage = 'Failed to load stores: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        log('Error in getStores: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get stores network error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<LocationCount>> getStoreCities() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/store/cities'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<LocationCount>.from(
          list.map((model) => LocationCount.fromJson(model)),
        );
      } else {
        String errorMessage = 'Failed to load cities';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        log('Error in getStoreCities: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get store cities network error: $e');
      throw Exception('Failed to load cities: $e');
    }
  }

  static Future<List<LocationCount>> getStoreDistricts(String city) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/store/districts?cityProvince=$city'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        Iterable list = json.decode(utf8.decode(response.bodyBytes));
        return List<LocationCount>.from(
          list.map((model) => LocationCount.fromJson(model)),
        );
      } else {
        String errorMessage = 'Failed to load districts';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        log('Error in getStoreDistricts: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get store districts network error: $e');
      throw Exception('Failed to load districts: $e');
    }
  }

  // --- Employee Endpoints ---

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

  static Future<List<WorkingTimeSlot>> getAvailableTimeSlots({
    required int storeId,
    required int serviceId,
    required int employeeId,
    required DateTime date,
  }) async {
    final headers = await _getAuthHeaders();
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final uri = Uri.parse('$baseUrl/api/working-time-slots/available').replace(
      queryParameters: {
        'employeeId': employeeId.toString(),
        'date': formattedDate,
      },
    );

    try {
      final response = await http.get(uri, headers: headers).timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => WorkingTimeSlot.fromJson(json)).toList();
      } else {
        String errorMessage =
            'Failed to load available time slots: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {}
        log('Error in getAvailableTimeSlots: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Get available time slots network error: $e');
      throw Exception('Network error: $e');
    }
  }

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

      log('Creating appointment with data: $appointmentData');

      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/api/appointments'),
            headers: await _getAuthHeaders(),
            body: jsonEncode([appointmentData]),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('Create appointment response status: ${response.statusCode}');
      log('Create appointment response body: ${response.body}');

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
          log('Error parsing error response: $e');
        }
        log('Error creating appointment: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Network error creating appointment: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Booking>> getUserBookings() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/appointments/user/current'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('getUserBookings response status: ${response.statusCode}');
      log('getUserBookings response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return jsonList.map((json) => Booking.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load bookings: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response for getUserBookings: $e');
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error in getUserBookings: $e');
      throw Exception('Failed to load your bookings: $e');
    }
  }

  static Future<User> getProfile(String token) async {
    try {
      final response = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}/api/user/profile'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        String errorMessage = 'Failed to load profile';
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
      log('Get profile network error: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  static Future<void> cancelAppointment(int appointmentId) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('User not authenticated. Please log in.');
    }

    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/appointments/$appointmentId/cancel'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('Cancel appointment response status: ${response.statusCode}');
      log('Cancel appointment response body: ${response.body}');

      if (response.statusCode == 200) {
        log('Appointment $appointmentId cancelled successfully.');
      } else {
        String errorMessage =
            'Failed to cancel appointment: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response for cancel: $e');
        }
        log('Error cancelling appointment: $errorMessage');
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Network error cancelling appointment: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Invoice>> getUserInvoices() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/invoices'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('getUserInvoices response status: ${response.statusCode}');
      log('getUserInvoices response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(
          utf8.decode(response.bodyBytes),
        );
        return jsonList.map((json) => Invoice.fromJson(json)).toList();
      } else {
        String errorMessage = 'Failed to load bookings: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response for getUserInvoices: $e');
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Error in getUserInvoices: $e');
      throw Exception('Failed to load your bookings: $e');
    }
  }

  static Future<String> getVnpayPaymentUrl(int invoiceId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/payment/create/$invoiceId'),
            headers: await _getAuthHeaders(),
          )
          .timeout(_timeout);

      await _handleAuthError(response);

      log('getVnpayPaymentUrl response status: ${response.statusCode}');
      log('getVnpayPaymentUrl response body: ${response.body}');

      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      } else {
        String errorMessage =
            'Failed to get payment URL: ${response.statusCode}';
        try {
          final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (e) {
          log('Error parsing error response for getVnpayPaymentUrl: $e');
        }
        throw Exception(errorMessage);
      }
    } on TimeoutException {
      throw Exception(
        'Request timed out. Please check your internet connection.',
      );
    } catch (e) {
      log('Network error getting VNPAY URL: $e');
      throw Exception('Network error: $e');
    }
  }
}
