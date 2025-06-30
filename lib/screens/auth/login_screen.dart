import 'package:flutter/material.dart';
import 'package:shine_booking_app/screens/auth/forgot_password_screen.dart';
import 'package:shine_booking_app/services/api_user.dart';
import '../../services/api_service.dart';
import '../../services/api_employee.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';
import '../../models/employee_model.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../employee/employee_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      final String? token = response['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await StorageService.saveToken(token);
      } else {
        throw Exception('Token not found or empty in login response.');
      }

      final String? roleStringFromLoginResponse = response['role']?.toString();
      final int? userIdFromLogin = response['userId'] as int?;
      final String? fullNameFromLogin = response['fullName'] as String?;
      final String? emailFromLogin = response['email'] as String?;

      if (userIdFromLogin == null ||
          fullNameFromLogin == null ||
          roleStringFromLoginResponse == null) {
        throw Exception(
          'Login response missing essential user details (userId, fullName, role).',
        );
      }

      String cleanRoleString = roleStringFromLoginResponse
          .toLowerCase()
          .replaceAll('role_', '');
      UserRole parsedRole = UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == cleanRoleString,
        orElse: () => UserRole.customer,
      );

      if (parsedRole == UserRole.employee) {
        final Employee employeeDetails =
            await ApiEmployeeService.getEmployeeDetails(token);
        await StorageService.saveEmployee(employeeDetails);
        await StorageService.saveUser(
          User(
            userId: employeeDetails.employeeId,
            fullName: employeeDetails.fullName,
            email: employeeDetails.email,
            role:
                employeeDetails.roles.isNotEmpty
                    ? UserRole.values.firstWhere(
                      (e) =>
                          e.toString().split('.').last ==
                          employeeDetails.roles.first.roleName.toLowerCase(),
                      orElse: () => UserRole.customer,
                    )
                    : UserRole.customer,
            membershipType: 'Employee',
            loyaltyPoints: 0,
            createdAt: employeeDetails.createdAt?.toIso8601String(),
            phoneNumber: '',
          ),
        );
      } else if (parsedRole == UserRole.admin) {
        // Lưu user trực tiếp từ response login, không gọi profile
        await StorageService.saveUser(
          User(
            userId: userIdFromLogin,
            fullName: fullNameFromLogin,
            email: emailFromLogin ?? '',
            role: UserRole.admin,
            membershipType: '',
            loyaltyPoints: 0,
            createdAt: '',
            phoneNumber: '',
          ),
        );
      } else {
        // Customer: lấy profile chi tiết
        final User userProfileFromApi = await ApiUserService.getMyProfile();
        await StorageService.saveUser(userProfileFromApi);
      }

      if (mounted) {
        if (parsedRole == UserRole.admin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const AdminDashboardScreen(),
            ),
          );
        } else if (parsedRole == UserRole.employee) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const EmployeeDashboardScreen(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      String errorMessageForUser = 'Đăng nhập thất bại. Vui lòng thử lại.';
      String rawErrorMessage = e.toString();

      if (rawErrorMessage.startsWith('Network error: ')) {
        rawErrorMessage =
            rawErrorMessage.substring('Network error: '.length).trim();
      }
      if (rawErrorMessage.startsWith('Exception: ')) {
        errorMessageForUser =
            rawErrorMessage.substring('Exception: '.length).trim();
      } else {
        errorMessageForUser = rawErrorMessage.trim();
      }
      if (errorMessageForUser.isEmpty || errorMessageForUser == 'null') {
        errorMessageForUser = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
      } else if (errorMessageForUser.contains('SocketException') ||
          errorMessageForUser.contains('HandshakeException')) {
        errorMessageForUser =
            'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng của bạn.';
      } else if (errorMessageForUser.contains(
        'Failed to fetch employee profile',
      )) {
        errorMessageForUser =
            'Đăng nhập thành công nhưng không thể lấy thông tin hồ sơ nhân viên. Vui lòng thử lại hoặc liên hệ hỗ trợ.';
      } else if (errorMessageForUser.contains('Token not found') ||
          errorMessageForUser.contains(
            'Login response missing essential user details',
          )) {
        errorMessageForUser =
            'Phản hồi từ máy chủ không hợp lệ. Vui lòng thử lại.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $errorMessageForUser')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                _buildHeader(theme),
                const SizedBox(height: 48),
                _buildLoginForm(theme),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 24),
                _buildRegisterButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
          child: const Icon(
            Icons.content_cut,
            size: 50,
            color: Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Chào mừng trở lại!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Đăng nhập để tiếp tục',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập mật khẩu';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text('Quên mật khẩu?'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
              : const Text(
                'Đăng nhập',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Chưa có tài khoản?"),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: const Text(
            'Đăng ký ngay',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
