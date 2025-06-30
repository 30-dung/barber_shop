import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemUiOverlayStyle
import 'package:shine_booking_app/services/api_user.dart';
// import '../../services/api_service.dart'; // REMOVED: No longer needed for user profile specific calls
import '../../services/storage_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

// --- Best Practice: Define colors and styles as constants for easy reuse and theming ---
const Color kPrimaryColor = Color(0xFFFF6B35);
const Color kPrimaryLightColor = Color(0xFFFFF0E5);
const Color kTextColor = Color(0xFF333333);
const Color kSubTextColor = Color(0xFF666666);
const Color kDangerColor = Color(0xFFE74C3C);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      // Use ApiUserService.getMyProfile() instead of ApiService.getProfile()
      final user = await ApiUserService.getMyProfile();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin cá nhân: $e')),
        );
        // Optionally, if loading profile fails due to auth, navigate to login
        if (e.toString().contains('Tài khoản mật khẩu không chính xác') ||
            e.toString().contains('No authentication token found')) {
          _logout();
        }
      }
    }
  }

  Future<void> _logout() async {
    await StorageService.clearStorage();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể chỉnh sửa hồ sơ. Dữ liệu người dùng không có sẵn.',
          ),
        ),
      );
      return;
    }

    final updatedUser = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUser: _user!),
      ),
    );

    if (updatedUser != null && updatedUser is User) {
      setState(() {
        _user = updatedUser;
      });
      // After updating, save the new user data to storage to reflect changes immediately
      await StorageService.saveUser(updatedUser);
    }
  }

  void _navigateToChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy thông tin người dùng.')),
      );
    }

    final systemUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildInfoCard('Thông tin liên hệ', [
              _buildInfoTile(
                Icons.phone_outlined,
                'Số điện thoại',
                _user!.phoneNumber?.isNotEmpty ==
                        true // FIX: Null-check phoneNumber
                    ? _user!.phoneNumber!
                    : 'Chưa có',
              ),
              _buildInfoTile(
                Icons.email_outlined,
                'Email',
                _user!.email ?? 'N/A',
              ), // FIX: Handle nullable email
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Thông tin thành viên', [
              _buildInfoTile(
                Icons.star_outline,
                'Điểm tích lũy',
                _user!.loyaltyPoints?.toString() ??
                    '0', // FIX: Handle nullable loyaltyPoints
              ),
              _buildInfoTile(
                Icons.card_membership_outlined,
                'Hạng thành viên',
                _user!.membershipType ??
                    'Thường', // FIX: Handle nullable membershipType
              ),
            ]),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final String initial =
        _user!.fullName?.isNotEmpty == true
            ? _user!.fullName![0].toUpperCase()
            : 'A'; // FIX: Null-check fullName

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white70,
            child: CircleAvatar(
              radius: 48,
              backgroundColor: kPrimaryLightColor,
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.fullName ?? 'Người dùng', // FIX: Handle nullable fullName
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email ?? 'N/A', // FIX: Handle nullable email
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: kPrimaryColor),
      title: Text(label, style: const TextStyle(color: kSubTextColor)),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: kTextColor,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit_outlined,
            text: 'Chỉnh sửa hồ sơ',
            onTap: _navigateToEditProfile,
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.lock_outline,
            text: 'Đổi mật khẩu',
            onTap: _navigateToChangePassword,
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.logout,
            text: 'Đăng xuất',
            color: kDangerColor,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? kSubTextColor),
      title: Text(
        text,
        style: TextStyle(
          color: color ?? kTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: kSubTextColor,
      ),
      onTap: onTap,
    );
  }
}
