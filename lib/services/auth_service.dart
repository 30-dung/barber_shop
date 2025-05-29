import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barber_app/models/auth_request.dart';
import 'package:barber_app/models/auth_response.dart';
import 'package:barber_app/utils/constants.dart';

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/login';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    return AuthResponse.fromJson(json.decode(response.body));
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    return AuthResponse.fromJson(json.decode(response.body));
  }

  Future<AuthResponse> forgotPassword(ForgotPasswordRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/forgot-password';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    return AuthResponse.fromJson(json.decode(response.body));
  }

  Future<AuthResponse> resetPassword(ResetPasswordRequest request) async {
    final url = '${AppConstants.baseUrl}/api/auth/reset-password';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );
    return AuthResponse.fromJson(json.decode(response.body));
  }
}
