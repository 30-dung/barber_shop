// lib/screens/employee/employee_dashboard_screen.dart
import 'package:flutter/material.dart';

import '../../services/storage_service.dart';
import '../auth/login_screen.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeDashboardScreen> createState() => _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển nhân viên'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[50]!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chào mừng trở lại!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Nguyễn Văn A',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Thợ cắt tóc senior',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Hôm nay',
                      '8',
                      'Cuộc hẹn',
                      Icons.today,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      'Thàng này',
                      '45',
                      'Cuộc hẹn',
                      Icons.calendar_view_week,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Menu List
              const Text(
                'Chức năng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildMenuCard(
                    'Cuộc hẹn của tôi',
                    Icons.calendar_today,
                    Colors.blue,
                        () => Navigator.pushNamed(context, '/employee/appointments'),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    'Lương của tôi',
                    Icons.attach_money,
                    Colors.green,
                        () => Navigator.pushNamed(context, '/employee/salary'),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    'Thống kê cá nhân',
                    Icons.bar_chart,
                    Colors.purple,
                        () => Navigator.pushNamed(context, '/employee/statistics'),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    'Đăng ký ca làm',
                    Icons.schedule,
                    Colors.orange,
                        () => Navigator.pushNamed(context, '/employee/schedule'),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuCard(
                    'Đăng xuất',
                    Icons.logout,
                    Colors.red,
                        () => _logout(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 35,
                  color: color,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
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