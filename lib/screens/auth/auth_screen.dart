// auth_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:barber_app/utils/colors.dart'; // Giả định AppColors nằm ở đường dẫn này

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin =
      true; // Dùng để chuyển đổi giữa giao diện đăng nhập và đăng ký

  Future<void> _authenticate() async {
    final String url =
        _isLogin
            ? 'http://localhost:9090/api/auth/login'
            : 'http://localhost:9090/api/auth/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Thành công
        _showSnackBar(context, responseData['message'] ?? 'Thành công!');
        // Xử lý lưu trữ token hoặc điều hướng
        if (_isLogin) {
          // Giả sử API trả về một token, bạn có thể lưu nó lại:
          // String token = responseData['token'];
          // Lưu token để sử dụng cho các yêu cầu xác thực sau này
          // Điều hướng về màn hình trước đó (ví dụ: ProfileScreen) hoặc màn hình chính
          Navigator.of(context).pop();
        } else {
          setState(() {
            _isLogin =
                true; // Sau khi đăng ký thành công, chuyển sang chế độ đăng nhập
          });
        }
      } else {
        // Lỗi
        _showSnackBar(context, responseData['message'] ?? 'Đã xảy ra lỗi!');
      }
    } catch (e) {
      _showSnackBar(context, 'Lỗi kết nối: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Đăng nhập' : 'Đăng ký'),
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: AppColors.secondaryWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.secondaryWhite,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isLogin ? 'Đăng nhập' : 'Đăng ký',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(
                _isLogin
                    ? 'Chưa có tài khoản? Đăng ký ngay!'
                    : 'Đã có tài khoản? Đăng nhập!',
                style: TextStyle(color: AppColors.primaryDarkBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
