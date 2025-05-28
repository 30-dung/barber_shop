// auth_screen.dart
import 'package:barber_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barber_app/utils/colors.dart';
import 'package:barber_app/models/auth_request.dart';
import 'package:barber_app/models/auth_response.dart';

// Enum để quản lý chế độ hiển thị form
enum AuthMode { login, register, forgotPassword, resetPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AuthMode _authMode = AuthMode.login;
  final GlobalKey<FormState> _formKey =
      GlobalKey(); // GlobalKey cho form validation
  bool _isLoading = false;

  // Controllers cho các trường nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController =
      TextEditingController(); // Cho mã OTP / token
  final TextEditingController _newPasswordController = TextEditingController();

  // Hàm hiển thị Snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.secondaryWhite),
        ),
        backgroundColor: isError ? Colors.red : AppColors.primaryDarkBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Hàm xử lý đăng nhập
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // <<< Sửa URL ở đây
    final String url = '${AppConstants.baseUrl}/api/auth/login';
    try {
      // Create LoginRequest object
      final loginRequest = LoginRequest(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginRequest.toJson()), // Use toJson() from model
      );

      final responseData = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(
        responseData,
      ); // Use fromJson() for response

      if (response.statusCode == 200) {
        _showSnackBar(authResponse.message ?? 'Đăng nhập thành công!');
        // TODO: Lưu token và vai trò (role) vào SharedPreferences hoặc Provider để sử dụng sau này
        // String? token = authResponse.token;
        // String? role = authResponse.role;
        Navigator.of(context).pop(); // Điều hướng về màn hình trước
      } else {
        _showSnackBar(
          authResponse.message ?? 'Đăng nhập thất bại.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm xử lý đăng ký
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // <<< Sửa URL ở đây
    final String url = '${AppConstants.baseUrl}/api/auth/register';
    try {
      // Create RegisterRequest object
      final registerRequest = RegisterRequest(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phoneNumber: _phoneNumberController.text,
        // membershipType defaults to 'BASIC' in the model
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registerRequest.toJson()), // Use toJson() from model
      );

      final responseData = json.decode(response.body);
      final authResponse = AuthResponse.fromJson(
        responseData,
      ); // Use fromJson() for response

      if (response.statusCode == 201) {
        _showSnackBar(
          authResponse.message ?? 'Đăng ký thành công! Vui lòng đăng nhập.',
        );
        setState(() {
          _authMode =
              AuthMode.login; // Chuyển sang chế độ đăng nhập sau khi đăng ký
        });
      } else {
        _showSnackBar(
          authResponse.message ?? 'Đăng ký thất bại.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm gửi yêu cầu quên mật khẩu (gửi OTP)
  Future<void> _forgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // <<< Sửa URL ở đây
    final String url = '${AppConstants.baseUrl}/api/auth/forgot-password';
    try {
      // Create ForgotPasswordRequest object
      final forgotPasswordRequest = ForgotPasswordRequest(
        email: _emailController.text,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          forgotPasswordRequest.toJson(),
        ), // Use toJson() from model
      );

      if (response.statusCode == 200) {
        _showSnackBar('Mã OTP đã được gửi đến email của bạn.');
        setState(() {
          _authMode =
              AuthMode.resetPassword; // Chuyển sang chế độ đặt lại mật khẩu
        });
      } else {
        final responseData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(
          responseData,
        ); // Use fromJson() for response
        _showSnackBar(
          authResponse.message ?? 'Không thể gửi OTP. Vui lòng kiểm tra email.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hàm đặt lại mật khẩu (với OTP)
  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // <<< Sửa URL ở đây
    final String url = '${AppConstants.baseUrl}/api/auth/reset-password';
    try {
      // Create ResetPasswordRequest object
      final resetPasswordRequest = ResetPasswordRequest(
        token: _otpController.text,
        newPassword: _newPasswordController.text,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          resetPasswordRequest.toJson(),
        ), // Use toJson() from model
      );

      if (response.statusCode == 200) {
        _showSnackBar('Đặt lại mật khẩu thành công! Vui lòng đăng nhập.');
        setState(() {
          _authMode = AuthMode.login; // Chuyển về màn hình đăng nhập
          _emailController.clear(); // Xóa email sau khi reset
          _passwordController.clear(); // Xóa password (nếu có)
          _otpController.clear();
          _newPasswordController.clear();
        });
      } else {
        final responseData = json.decode(response.body);
        final authResponse = AuthResponse.fromJson(
          responseData,
        ); // Use fromJson() for response
        _showSnackBar(
          authResponse.message ?? 'Đặt lại mật khẩu thất bại.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar('Lỗi kết nối: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Xây dựng form đăng nhập
  Widget _buildLoginForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(
              Icons.email,
              color: AppColors.primaryDarkBlue,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Vui lòng nhập email hợp lệ.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(
              Icons.lock,
              color: AppColors.primaryDarkBlue,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: AppColors.primaryOrange)
            : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.secondaryWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Đăng nhập', style: TextStyle(fontSize: 18)),
            ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _authMode = AuthMode.forgotPassword;
              _formKey.currentState?.reset(); // Reset form state
              _emailController.clear();
              _passwordController.clear();
            });
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(color: AppColors.primaryDarkBlue),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _authMode = AuthMode.register;
              _formKey.currentState?.reset(); // Reset form state
              _emailController.clear();
              _passwordController.clear();
            });
          },
          child: Text(
            'Chưa có tài khoản? Đăng ký ngay!',
            style: TextStyle(color: AppColors.primaryDarkBlue),
          ),
        ),
      ],
    );
  }

  // Xây dựng form đăng ký
  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      // Đảm bảo cuộn được nếu bàn phím che mất input
      child: Column(
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(
                Icons.person,
                color: AppColors.primaryDarkBlue,
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.3),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập họ và tên.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(
                Icons.email,
                color: AppColors.primaryDarkBlue,
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.3),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty || !value.contains('@')) {
                return 'Vui lòng nhập email hợp lệ.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(
                Icons.lock,
                color: AppColors.primaryDarkBlue,
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.3),
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Mật khẩu phải có ít nhất 6 ký tự.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Xác nhận mật khẩu',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.primaryDarkBlue,
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.3),
            ),
            obscureText: true,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Mật khẩu xác nhận không khớp.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(
                Icons.phone,
                color: AppColors.primaryDarkBlue,
              ),
              filled: true,
              fillColor: AppColors.lightGrey.withOpacity(0.3),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 10) {
                return 'Vui lòng nhập số điện thoại hợp lệ.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _isLoading
              ? const CircularProgressIndicator(color: AppColors.primaryOrange)
              : ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.secondaryWhite,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Đăng ký', style: TextStyle(fontSize: 18)),
              ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _authMode = AuthMode.login;
                _formKey.currentState?.reset();
                _emailController.clear();
                _passwordController.clear();
                _fullNameController.clear();
                _phoneNumberController.clear();
                _confirmPasswordController.clear();
              });
            },
            child: Text(
              'Đã có tài khoản? Đăng nhập!',
              style: TextStyle(color: AppColors.primaryDarkBlue),
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng form quên mật khẩu
  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email đã đăng ký',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(
              Icons.email,
              color: AppColors.primaryDarkBlue,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Vui lòng nhập email hợp lệ.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: AppColors.primaryOrange)
            : ElevatedButton(
              onPressed: _forgotPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.secondaryWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Gửi mã OTP', style: TextStyle(fontSize: 18)),
            ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _authMode = AuthMode.login;
              _formKey.currentState?.reset();
              _emailController.clear();
            });
          },
          child: Text(
            'Quay lại Đăng nhập',
            style: TextStyle(color: AppColors.primaryDarkBlue),
          ),
        ),
      ],
    );
  }

  // Xây dựng form đặt lại mật khẩu
  Widget _buildResetPasswordForm() {
    return Column(
      children: [
        TextFormField(
          controller: _otpController,
          decoration: InputDecoration(
            labelText: 'Mã OTP (Token)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(
              Icons.verified_user,
              color: AppColors.primaryDarkBlue,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mã OTP.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(
              Icons.lock_reset,
              color: AppColors.primaryDarkBlue,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu mới',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.primaryDarkBlue,
            ),
            filled: true,
            fillColor: AppColors.lightGrey.withOpacity(0.3),
          ),
          obscureText: true,
          validator: (value) {
            if (value != _newPasswordController.text) {
              return 'Mật khẩu xác nhận không khớp.';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: AppColors.primaryOrange)
            : ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.secondaryWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đặt lại mật khẩu',
                style: TextStyle(fontSize: 18),
              ),
            ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _authMode = AuthMode.forgotPassword; // Quay lại gửi OTP nếu cần
              _formKey.currentState?.reset();
              _otpController.clear();
              _newPasswordController.clear();
            });
          },
          child: Text(
            'Gửi lại OTP?',
            style: TextStyle(color: AppColors.primaryDarkBlue),
          ),
        ),
      ],
    );
  }

  String _getAppBarTitle() {
    switch (_authMode) {
      case AuthMode.login:
        return 'Đăng nhập';
      case AuthMode.register:
        return 'Đăng ký tài khoản';
      case AuthMode.forgotPassword:
        return 'Quên mật khẩu';
      case AuthMode.resetPassword:
        return 'Đặt lại mật khẩu';
      default:
        return 'Xác thực';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: AppColors.secondaryWhite,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _authMode == AuthMode.login
                      ? _buildLoginForm()
                      : _authMode == AuthMode.register
                      ? _buildRegisterForm()
                      : _authMode == AuthMode.forgotPassword
                      ? _buildForgotPasswordForm()
                      : _buildResetPasswordForm(),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
