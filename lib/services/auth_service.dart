import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barber_app/models/auth_request.dart';
import 'package:barber_app/models/auth_response.dart';
import 'package:barber_app/utils/constants.dart';

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      print('Login Response: ${response.body}, Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Login failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in login: $e');
      rethrow;
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/register';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      print(
        'Register Response: ${response.body}, Status: ${response.statusCode}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Register failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in register: $e');
      rethrow;
    }
  }

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/forgot-password';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      print(
        'ForgotPassword Response: ${response.body}, Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Kiểm tra xem phản hồi có phải JSON
        if (response.body.trim().startsWith('{') ||
            response.body.trim().startsWith('[')) {
          return AuthResponse.fromJson(json.decode(response.body));
        } else {
          // Xử lý phản hồi văn bản thuần
          if (response.body.toLowerCase().contains('otp sent') ||
              response.body.toLowerCase().contains('đã được gửi')) {
            return AuthResponse(
              message: 'Mã OTP đã được gửi đến email của bạn.',
            );
          }
          throw FormatException('Non-JSON response: ${response.body}');
        }
      } else {
        throw Exception(
          'Forgot password failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in forgotPassword: $e');
      rethrow;
    }
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/reset-password';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );
      print(
        'ResetPassword Response: ${response.body}, Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        // Kiểm tra xem phản hồi có phải JSON
        if (response.body.trim().startsWith('{') ||
            response.body.trim().startsWith('[')) {
          return AuthResponse.fromJson(json.decode(response.body));
        } else {
          // Xử lý phản hồi văn bản thuần
          if (response.body.toLowerCase().contains(
                'password reset successfully',
              ) ||
              response.body.toLowerCase().contains('thành công')) {
            return AuthResponse(message: 'Đặt lại mật khẩu thành công.');
          }
          throw FormatException('Non-JSON response: ${response.body}');
        }
      } else {
        throw Exception(
          'Reset password failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      rethrow;
    }
  }
}
