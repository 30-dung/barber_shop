import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for SystemUiOverlayStyle
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart'; // Import the new edit screen
import 'change_password_screen.dart'; // Import the new change password screen

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
    final token = await StorageService.getToken();
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      // If no token, maybe navigate to login or show a login prompt
      // For now, just set isLoading to false and _user will be null
      return;
    }
    try {
      final user = await ApiService.getProfile(token);
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

  // --- NEW: Function to navigate to EditProfileScreen and handle result ---
  Future<void> _navigateToEditProfile() async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể chỉnh sửa hồ sơ. Dữ liệu người dùng không có sẵn.')),
      );
      return;
    }

    final updatedUser = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(currentUser: _user!),
      ),
    );

    // If updatedUser is returned (i.e., user saved changes), update the state
    if (updatedUser != null && updatedUser is User) {
      setState(() {
        _user = updatedUser;
      });
      // You could also call _loadUser() here to re-fetch from API for full refresh
    }
  }

  // --- NEW: Function to navigate to ChangePasswordScreen ---
  void _navigateToChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
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

    // This makes the status bar icons (wifi, battery) light, which looks better on a dark app bar
    final systemUiOverlayStyle = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: ListView(
          // Using ListView is better for scrollable content with various sections
          padding: EdgeInsets.zero, // Remove default padding
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildInfoCard('Thông tin liên hệ', [
              _buildInfoTile(
                Icons.phone_outlined,
                'Số điện thoại',
                _user!.phoneNumber.isNotEmpty ? _user!.phoneNumber : 'Chưa có', // Handle empty phone number
              ),
              _buildInfoTile(Icons.email_outlined, 'Email', _user!.email),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Thông tin thành viên', [
              _buildInfoTile(
                Icons.star_outline,
                'Điểm tích lũy',
                _user!.loyaltyPoints.toString(),
              ),
              _buildInfoTile(
                Icons.card_membership_outlined,
                'Hạng thành viên',
                _user!.membershipType,
              ),
            ]),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  // Widget for the top header section (Avatar, Name, etc.)
  Widget _buildProfileHeader() {
    // Get the first letter of the user's name for the avatar fallback
    final String initial =
    _user!.fullName.isNotEmpty ? _user!.fullName[0].toUpperCase() : 'A';

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
              // If you have a user avatar URL, you can use it here.
              // backgroundImage: NetworkImage(_user!.avatarUrl),
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
            _user!.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  // A reusable card for sections like "Contact Info", "Membership Info"
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
              ...children, // Use the spread operator to add the list of tiles
            ],
          ),
        ),
      ),
    );
  }

  // Replaces the old _profileRow with a more standard ListTile
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

  // A section for action buttons
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.edit_outlined,
            text: 'Chỉnh sửa hồ sơ',
            onTap: _navigateToEditProfile, // Calling the navigation function
          ),
          const Divider(height: 1),
          _buildActionTile(
            icon: Icons.lock_outline,
            text: 'Đổi mật khẩu',
            onTap: _navigateToChangePassword, // Calling the navigation function
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
