import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryGrey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryOrange,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.secondaryWhite,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Nguyễn Văn A',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '0987654321',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              icon: Icons.history,
              title: 'Lịch sử đặt hẹn',
              onTap: () => _showBookingHistory(context),
            ),
            _buildMenuItem(
              icon: Icons.favorite,
              title: 'Dịch vụ yêu thích',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.wallet,
              title: 'Ví điểm thưởng',
              onTap: () => _showPointsWallet(context),
            ),
            _buildMenuItem(
              icon: Icons.location_on,
              title: 'Địa chỉ cửa hàng',
              onTap: () => _showStoreLocations(context),
            ),
            _buildMenuItem(
              icon: Icons.support_agent,
              title: 'Hỗ trợ khách hàng',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings,
              title: 'Cài đặt',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: () => _logout(context),
              isLogout: true,
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
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : AppColors.primaryOrange,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: AppColors.secondaryWhite,
      ),
    );
  }

  void _showBookingHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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

  void _showPointsWallet(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ví điểm thưởng'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wallet, size: 64, color: AppColors.primaryOrange),
                SizedBox(height: 16),
                Text(
                  '1,250 điểm',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bạn có thể sử dụng điểm để đổi quà hoặc giảm giá dịch vụ',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showStoreLocations(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder:
                (context, scrollController) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
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

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
