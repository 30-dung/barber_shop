import 'package:flutter/material.dart';
import 'package:shine_booking_app/screens/auth/forgot_password_screen.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart'; // Make sure User model is imported
import '../../models/employee_model.dart'; // Import Employee model
import '../home/home_screen.dart';
import 'register_screen.dart';
import '../admin/admin_dashboard_screen.dart'; // Import AdminDashboardScreen
import '../employee/employee_dashboard_screen.dart'; // Import EmployeeDashboardScreen

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
      // 1. Call API to log in and get the response
      // This response contains 'token', 'role', 'userId', 'fullName'
      final Map<String, dynamic> response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // 2. Extract and save the token
      final String? token = response['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await StorageService.saveToken(token);
        print(
          'LoginScreen: Token saved: ${token.substring(0, 20)}...',
        ); // Debug print
      } else {
        throw Exception('Token not found or empty in login response.');
      }

      // 3. Extract basic user info and role from the initial login response
      final String? roleStringFromLoginResponse = response['role']?.toString();
      final int? userIdFromLogin = response['userId'] as int?;
      final String? fullNameFromLogin = response['fullName'] as String?;

      if (userIdFromLogin == null || fullNameFromLogin == null || roleStringFromLoginResponse == null) {
        throw Exception('Login response missing essential user details (userId, fullName, role).');
      }

      // Clean the role string (e.g., "ROLE_EMPLOYEE" -> "employee")
      String cleanRoleString = roleStringFromLoginResponse.toLowerCase().replaceAll('role_', '');
      UserRole parsedRole = UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == cleanRoleString,
        orElse: () => UserRole.customer, // Default to customer if role is unrecognized
      );

      print('LoginScreen: Parsed Role from login response: ${parsedRole.toString().split('.').last}');

      // 4. Based on the parsed role, fetch the appropriate profile details
      if (parsedRole == UserRole.employee) {
        try {
          final Employee employeeDetails = await ApiService.getEmployeeDetails(token);
          await StorageService.saveEmployee(employeeDetails); // Save the full Employee object
          print('LoginScreen: Employee profile fetched and saved: ${employeeDetails.fullName}, ID: ${employeeDetails.employeeId}, Role: ${employeeDetails.role.toString().split('.').last}');

          // Also save a basic User object for common app features (e.g., profile screen uses User)
          // We use employeeId as userId for consistency in User model
          await StorageService.saveUser(User(
            userId: employeeDetails.employeeId,
            fullName: employeeDetails.fullName,
            email: employeeDetails.email,
            phoneNumber: employeeDetails.phoneNumber,
            role: employeeDetails.role,
            membershipType: 'Employee', // Set a default or fetch if available
            loyaltyPoints: 0, // Employees might not have loyalty points
            createdAt: employeeDetails.createdAt?.toIso8601String(),
          ));
        } catch (e) {
          // If fetching employee details fails, it's a critical error for employee login
          throw Exception('Failed to fetch employee profile after login: $e. Please check /api/employees/profile endpoint.');
        }
      } else { // For Admin and Customer roles, use the general /api/user/profile endpoint
        try {
          final User userProfileFromApi = await ApiService.getProfile(token);
          await StorageService.saveUser(userProfileFromApi); // Save the full User object
          print('LoginScreen: User profile fetched and saved: ${userProfileFromApi.fullName}, ID: ${userProfileFromApi.userId}, Role: ${userProfileFromApi.role.toString().split('.').last}');
        } catch (e) {
          // If fetching user profile fails, it's a critical error for admin/customer login
          throw Exception('Failed to fetch user profile after login: $e. Please check /api/user/profile endpoint.');
        }
      }

      // 5. Navigate based on user role (using the parsedRole from step 3/4)
      if (mounted) {
        if (parsedRole == UserRole.admin) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );
        } else if (parsedRole == UserRole.employee) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()),
          );
        } else { // Default to customer role for any other roles or if role is not explicitly admin/employee
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      print('LoginScreen: Login failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đăng nhập thất bại: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- PHẦN GIAO DIỆN ĐƯỢC CẢI TIẾN (NO CHANGES HERE) ---

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
