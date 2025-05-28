import 'package:barber_app/screens/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkBlue,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header với avatar
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.secondaryWhite,
                    child: Icon(
                      Icons.person,
                      size: 35,
                      color: AppColors.primaryDarkBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Chưa có hàng thành viên',
                    style: TextStyle(
                      color: AppColors.secondaryWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 14,
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
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on,
                      title: 'Địa chỉ của anh',
                      onTap: () => _showStoreLocations(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.shopping_bag,
                      title: 'Đơn hàng',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.local_offer,
                      title: 'Ưu đãi',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Lịch sử cắt',
                      onTap: () => _showBookingHistory(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite,
                      title: 'Sở thích phục vụ',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Hiệu để phục vụ anh tốt hơn',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.security,
                      title: 'Lấy OTP xác thực giao dịch',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.language,
                      title: 'Hệ thống salon của 30Shine',
                      onTap: () => _showStoreLocations(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryDarkBlue, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.secondaryGrey,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
