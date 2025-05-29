import 'package:barber_app/screens/home/home_screen.dart';
import 'package:barber_app/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barber_app/controller/auth_controller.dart';
import 'package:barber_app/models/auth_request.dart';
import 'package:barber_app/utils/colors.dart';

enum AuthMode { login, register, forgotPassword, resetPassword }

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  AuthMode _authMode = AuthMode.login;
  final GlobalKey<FormState> _formKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureNewPassword = true;

  bool _pendingNavigateToProfile = false; // Thêm biến này

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: Consumer<AuthController>(
        builder: (context, controller, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (controller.errorMessage != null) {
              _showCustomSnackBar(
                context,
                controller.errorMessage!,
                isError: true,
              );
              controller.clearMessages();
            }
            if (controller.successMessage != null) {
              _showCustomSnackBar(
                context,
                controller.successMessage!,
                isError: false,
              );

              // Nếu là đăng nhập thành công, delay rồi chuyển trang
              if (_authMode == AuthMode.login && !_pendingNavigateToProfile) {
                _pendingNavigateToProfile = true;
                await Future.delayed(const Duration(seconds: 1));
                controller.clearMessages();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                }
                return;
              }

              controller.clearMessages();

              // Navigate to reset password after successful forgot password
              if (_authMode == AuthMode.forgotPassword &&
                  controller.successMessage!.contains('OTP')) {
                setState(() {
                  _authMode = AuthMode.resetPassword;
                });
              }
            }
          });

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryDarkBlue,
                    AppColors.primaryDarkBlue.withOpacity(0.8),
                    AppColors.primaryOrange.withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Card(
                          elevation: 20,
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 32),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.1, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _buildCurrentForm(controller),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryOrange, AppColors.primaryDarkBlue],
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(Icons.content_cut, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Barber App',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(),
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCurrentForm(AuthController controller) {
    switch (_authMode) {
      case AuthMode.login:
        return _buildLoginForm(controller);
      case AuthMode.register:
        return _buildRegisterForm(controller);
      case AuthMode.forgotPassword:
        return _buildForgotPasswordForm(controller);
      case AuthMode.resetPassword:
        return _buildResetPasswordForm(controller);
    }
  }

  Widget _buildLoginForm(AuthController controller) {
    return Column(
      key: const ValueKey('login'),
      children: [
        _buildCustomTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Vui lòng nhập email hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed:
                () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return 'Mật khẩu phải có ít 1 chữ hóa 1 chữ thường ít nhất 8 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          controller: controller,
          text: 'Đăng nhập',
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            await controller.login(
              LoginRequest(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            );
            // KHÔNG chuyển trang ở đây nữa!
          },
        ),
        const SizedBox(height: 24),
        _buildTextButton(
          text: 'Quên mật khẩu?',
          onPressed: () => _switchMode(AuthMode.forgotPassword),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chưa có tài khoản? ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            _buildTextButton(
              text: 'Đăng ký ngay',
              onPressed: () => _switchMode(AuthMode.register),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthController controller) {
    return Column(
      key: const ValueKey('register'),
      children: [
        _buildCustomTextField(
          controller: _fullNameController,
          label: 'Họ và tên',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập họ và tên';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Vui lòng nhập email hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _phoneNumberController,
          label: 'Số điện thoại',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 10) {
              return 'Vui lòng nhập số điện thoại hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _passwordController,
          label: 'Mật khẩu',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed:
                () => setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _confirmPasswordController,
          label: 'Xác nhận mật khẩu',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed:
                () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Mật khẩu xác nhận không khớp';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          controller: controller,
          text: 'Đăng ký',
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            await controller.register(
              RegisterRequest(
                fullName: _fullNameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text,
                phoneNumber: _phoneNumberController.text.trim(),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Đã có tài khoản? ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            _buildTextButton(
              text: 'Đăng nhập',
              onPressed: () => _switchMode(AuthMode.login),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForgotPasswordForm(AuthController controller) {
    return Column(
      key: const ValueKey('forgot'),
      children: [
        Icon(Icons.lock_reset, size: 64, color: AppColors.primaryOrange),
        const SizedBox(height: 16),
        Text(
          'Nhập email để nhận mã OTP',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildCustomTextField(
          controller: _emailController,
          label: 'Email đã đăng ký',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Vui lòng nhập email hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          controller: controller,
          text: 'Gửi mã OTP',
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            await controller.forgotPassword(
              ForgotPasswordRequest(email: _emailController.text.trim()),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildTextButton(
          text: 'Quay lại đăng nhập',
          onPressed: () => _switchMode(AuthMode.login),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm(AuthController controller) {
    return Column(
      key: const ValueKey('reset'),
      children: [
        Icon(Icons.verified_user, size: 64, color: AppColors.primaryOrange),
        const SizedBox(height: 16),
        Text(
          'Nhập mã OTP và mật khẩu mới',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildCustomTextField(
          controller: _otpController,
          label: 'Mã OTP',
          icon: Icons.verified_user,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mã OTP';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _newPasswordController,
          label: 'Mật khẩu mới',
          icon: Icons.lock_outline,
          obscureText: _obscureNewPassword,
          suffixIcon: IconButton(
            onPressed:
                () =>
                    setState(() => _obscureNewPassword = !_obscureNewPassword),
            icon: Icon(
              _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildCustomTextField(
          controller: _confirmPasswordController,
          label: 'Xác nhận mật khẩu mới',
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            onPressed:
                () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                ),
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryDarkBlue,
            ),
          ),
          validator: (value) {
            if (value != _newPasswordController.text) {
              return 'Mật khẩu xác nhận không khớp';
            }
            return null;
          },
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          controller: controller,
          text: 'Đặt lại mật khẩu',
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            await controller.resetPassword(
              ResetPasswordRequest(
                token: _otpController.text.trim(),
                newPassword: _newPasswordController.text,
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildTextButton(
          text: 'Gửi lại OTP',
          onPressed: () => _switchMode(AuthMode.forgotPassword),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primaryDarkBlue),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          labelStyle: TextStyle(color: Colors.grey[600]),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildActionButton({
    required AuthController controller,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            AppColors.primaryOrange,
            AppColors.primaryOrange.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          controller.isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
              : Material(
                borderRadius: BorderRadius.circular(15),
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: onPressed,
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildTextButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primaryDarkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _switchMode(AuthMode newMode) {
    setState(() {
      _authMode = newMode;
      _formKey.currentState?.reset();
      _clearControllers();
      _pendingNavigateToProfile = false;
    });
  }

  void _clearControllers() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _fullNameController.clear();
    _phoneNumberController.clear();
    _otpController.clear();
    _newPasswordController.clear();
  }

  String _getSubtitle() {
    switch (_authMode) {
      case AuthMode.login:
        return 'Chào mừng bạn trở lại!';
      case AuthMode.register:
        return 'Tạo tài khoản mới';
      case AuthMode.forgotPassword:
        return 'Khôi phục mật khẩu';
      case AuthMode.resetPassword:
        return 'Tạo mật khẩu mới';
    }
  }

  void _showCustomSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : AppColors.primaryDarkBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
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
