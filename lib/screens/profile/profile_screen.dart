import 'package:barber_app/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:barber_app/utils/constants.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Không tìm thấy token. Vui lòng đăng nhập lại.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/api/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          userData = responseData;
          isLoading = false;
          errorMessage = null;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
        });
        await prefs.remove('auth_token');
        await prefs.remove('user_role');
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Không thể tải thông tin người dùng. Mã lỗi: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi kết nối: $e';
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      // Đổi thành màn hình chính của bạn nếu muốn về Home, ví dụ MainScreen()
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkBlue,
        elevation: 0,
        title: const Text(
          'Hồ sơ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (userData != null)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'Đăng xuất',
            ),
        ],
      ),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : errorMessage != null
                ? _buildErrorState()
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      fetchUserInfo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Thử lại',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDarkBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Đăng nhập',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return RefreshIndicator(
      onRefresh: fetchUserInfo,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header với avatar và thông tin user
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.secondaryWhite,
                  child: Icon(
                    Icons.person,
                    size: 45,
                    color: AppColors.primaryDarkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userData?['fullName'] ?? 'Không có tên',
                  style: const TextStyle(
                    color: AppColors.secondaryWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData?['email'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  userData?['phoneNumber'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                // Membership info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${userData?['membershipType'] ?? 'REGULAR'} • ${userData?['loyaltyPoints'] ?? 0} điểm',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Menu items container
          Container(
            decoration: const BoxDecoration(
              color: AppColors.secondaryWhite,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildMenuItem(
                    icon: Icons.person,
                    title: 'Thông tin tài khoản',
                    subtitle: 'Chỉnh sửa thông tin cá nhân',
                    onTap: () => _showUserInfo(),
                  ),
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Địa chỉ của anh',
                    subtitle: 'Xem các cửa hàng gần bạn',
                    onTap: () => _showStoreLocations(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.shopping_bag,
                    title: 'Đơn hàng',
                    subtitle: 'Lịch sử đặt hàng',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.local_offer,
                    title: 'Ưu đãi',
                    subtitle: 'Khuyến mãi dành cho bạn',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Lịch sử cắt',
                    subtitle: 'Xem lịch sử đặt lịch',
                    onTap: () => _showBookingHistory(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    title: 'Sở thích phục vụ',
                    subtitle: 'Dịch vụ yêu thích',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.help,
                    title: 'Hiệu để phục vụ anh tốt hơn',
                    subtitle: 'Góp ý và phản hồi',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'Lấy OTP xác thực giao dịch',
                    subtitle: 'Bảo mật tài khoản',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.language,
                    title: 'Hệ thống salon',
                    subtitle: 'Tìm hiểu về chúng tôi',
                    onTap: () => _showStoreLocations(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryDarkBlue, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                )
                : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.secondaryGrey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  void _showUserInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => SafeArea(
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder:
                  (context, scrollController) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const Text(
                            'Thông tin tài khoản',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoRow(
                            'Họ và tên',
                            userData?['fullName'] ?? '',
                          ),
                          _buildInfoRow('Email', userData?['email'] ?? ''),
                          _buildInfoRow(
                            'Số điện thoại',
                            userData?['phoneNumber'] ?? '',
                          ),
                          _buildInfoRow(
                            'Loại thành viên',
                            userData?['membershipType'] ?? '',
                          ),
                          _buildInfoRow(
                            'Điểm tích lũy',
                            '${userData?['loyaltyPoints'] ?? 0} điểm',
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // TODO: Thêm logic cập nhật thông tin
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Cập nhật thông tin'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  icon: const Icon(Icons.close),
                                  label: const Text('Đóng'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
            ),
          ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showBookingHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Lịch sử đặt hẹn',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.primaryOrange,
                                  child: Icon(
                                    Icons.content_cut,
                                    color: AppColors.secondaryWhite,
                                  ),
                                ),
                                title: Text(
                                  'Cắt tóc nam - ${15 + index}/12/2024',
                                ),
                                subtitle: const Text('9:00 AM - Hoàn thành'),
                                trailing: const Icon(
                                  Icons.check_circle,
                                  color: AppColors.accentGreen,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _showStoreLocations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: AppColors.secondaryWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGrey,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Địa chỉ cửa hàng',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            final stores = [
                              {
                                'name': '30SHINE Quận 1',
                                'address': '123 Nguyễn Huệ, Quận 1, TP.HCM',
                                'phone': '028 1234 5678',
                                'hours': '8:00 - 22:00',
                              },
                              {
                                'name': '30SHINE Quận 3',
                                'address': '456 Võ Văn Tần, Quận 3, TP.HCM',
                                'phone': '028 2345 6789',
                                'hours': '8:00 - 22:00',
                              },
                              {
                                'name': '30SHINE Quận 7',
                                'address':
                                    '789 Nguyễn Thị Thập, Quận 7, TP.HCM',
                                'phone': '028 3456 7890',
                                'hours': '8:00 - 22:00',
                              },
                            ];

                            final store = stores[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store['name']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 16,
                                          color: AppColors.secondaryGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(store['address']!),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 16,
                                          color: AppColors.secondaryGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(store['phone']!),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: AppColors.secondaryGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(store['hours']!),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
