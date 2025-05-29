import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barber_app/models/auth_request.dart';
import 'package:barber_app/models/auth_response.dart';
import 'package:barber_app/services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _userToken;
  String? _userRole;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get userToken => _userToken;
  String? get userRole => _userRole;
  bool get isLoggedIn => _userToken != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> _saveToken(String token, String? role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      if (role != null) {
        await prefs.setString('user_role', role);
      }
      _userToken = token;
      _userRole = role;
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  Future<void> loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userToken = prefs.getString('auth_token');
      _userRole = prefs.getString('user_role');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  Future<void> _clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_role');
      _userToken = null;
      _userRole = null;
    } catch (e) {
      debugPrint('Error clearing token: $e');
    }
  }

  // Login
  Future<void> login(LoginRequest request) async {
    _setLoading(true);
    try {
      final response = await _authService.login(request);
      if (response.token != null && response.token!.isNotEmpty) {
        await _saveToken(response.token!, response.role);
        _setSuccess(response.message ?? 'Đăng nhập thành công!');
      } else {
        _setError(
          response.message ??
              'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _setError('Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.');
      } else {
        _setError('Lỗi kết nối: $e');
      }
    }
  }

  // Register
  Future<void> register(RegisterRequest request) async {
    _setLoading(true);
    try {
      final response = await _authService.register(request);
      if ((response.token != null && response.token!.isNotEmpty) ||
          (response.message?.toLowerCase().contains('thành công') == true)) {
        _setSuccess(
          response.message ?? 'Đăng ký thành công! Vui lòng đăng nhập.',
        );
      } else {
        _setError(response.message ?? 'Đăng ký thất bại.');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _setError('Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.');
      } else {
        _setError('Lỗi kết nối: $e');
      }
    }
  }

  // Forgot Password
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    _setLoading(true);
    try {
      final response = await _authService.forgotPassword(request);
      if (response.message?.contains('OTP') == true) {
        _setSuccess(
          response.message ?? 'Mã OTP đã được gửi đến email của bạn.',
        );
      } else {
        _setError(
          response.message ?? 'Không thể gửi OTP. Vui lòng kiểm tra email.',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _setError('Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.');
      } else {
        _setError('Lỗi kết nối: $e');
      }
    }
  }

  // Reset Password
  Future<void> resetPassword(ResetPasswordRequest request) async {
    _setLoading(true);
    try {
      final response = await _authService.resetPassword(request);
      if (response.message?.toLowerCase().contains('thành công') == true) {
        _setSuccess(
          response.message ??
              'Đặt lại mật khẩu thành công! Vui lòng đăng nhập.',
        );
      } else {
        _setError(response.message ?? 'Đặt lại mật khẩu thất bại.');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        _setError('Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng.');
      } else {
        _setError('Lỗi kết nối: $e');
      }
    }
  }

  // Logout
  Future<void> logout() async {
    await _clearToken();
    notifyListeners();
  }
}
