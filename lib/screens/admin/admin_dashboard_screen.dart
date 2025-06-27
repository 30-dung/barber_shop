// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_services_screen.dart';
import 'manage_stores_screen.dart';
import 'manage_users_screen.dart';
import 'admin_statistics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFFF6B35),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF6B35).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng Admin!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Quản lý hệ thống 30Shine',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildDashboardCard(
                      context,
                      'Thống kê',
                      Icons.analytics,
                      Colors.blue,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminStatisticsScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Quản lý đặt lịch',
                      Icons.calendar_today,
                      Colors.green,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageBookingsScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Quản lý dịch vụ',
                      Icons.content_cut,
                      Colors.orange,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageServicesScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Quản lý cửa hàng',
                      Icons.store,
                      Colors.purple,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageStoresScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Quản lý người dùng',
                      Icons.people,
                      Colors.red,
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManageUsersScreen(),
                        ),
                      ),
                    ),
                    _buildDashboardCard(
                      context,
                      'Cài đặt',
                      Icons.settings,
                      Colors.grey,
                          () => _showSettingsDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt'),
        content: const Text('Tính năng cài đặt sẽ được cập nhật trong phiên bản tiếp theo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearStorage();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}