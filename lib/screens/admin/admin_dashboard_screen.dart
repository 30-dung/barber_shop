import 'package:flutter/material.dart';
import 'package:shine_booking_app/screens/admin/appointments/manage_appointments_screen.dart';
import 'package:shine_booking_app/screens/admin/employee/manage_employees_screen.dart';
import '../../services/storage_service.dart';
import '../auth/login_screen.dart';
import 'service/manage_services_screen.dart';
import 'store/manage_stores_screen.dart';
import 'user/manage_users_screen.dart';
import 'admin_statistics_screen.dart';
import 'employee/manage_employees_screen.dart';
import 'salary/manage_salaries_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_DashboardItem> items = [
      _DashboardItem(
        title: 'Thống kê',
        subtitle: 'Xem báo cáo tổng quan',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF1976D2),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminStatisticsScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Quản lý đặt lịch',
        subtitle: 'Theo dõi lịch hẹn',
        icon: Icons.calendar_today_outlined,
        color: const Color(0xFF388E3C),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageAppointmentsScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Quản lý dịch vụ',
        subtitle: 'Cập nhật dịch vụ',
        icon: Icons.content_cut_outlined,
        color: const Color(0xFFFF9800),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageServicesScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Quản lý cửa hàng',
        subtitle: 'Thông tin chi nhánh',
        icon: Icons.store_outlined,
        color: const Color(0xFF7B1FA2),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageStoresScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Quản lý người dùng',
        subtitle: 'Danh sách khách hàng',
        icon: Icons.people_outline,
        color: const Color(0xFFD32F2F),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageUsersScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Quản lý nhân viên',
        subtitle: 'Thông tin nhân viên',
        icon: Icons.badge_outlined,
        color: const Color(0xFF00796B),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManageEmployeesScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Quản lý lương',
        subtitle: 'Bảng lương nhân viên',
        icon: Icons.payments_outlined,
        color: const Color(0xFF5D4037),
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminSalaryManagementScreen(),
              ),
            ),
      ),
      _DashboardItem(
        title: 'Cài đặt',
        subtitle: 'Tùy chỉnh hệ thống',
        icon: Icons.settings_outlined,
        color: const Color(0xFF455A64),
        onTap: () => _showSettingsDialog(context),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                _buildQuickStats(),
                const SizedBox(height: 24),
                const Text(
                  'Quản lý hệ thống',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardGrid(items),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF2C3E50),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          backgroundImage: const NetworkImage(
            'https://images.pexels.com/photos/2182970/pexels-photo-2182970.jpeg?_gl=1*ylcu2q*_ga*MTU0NjkwNDY0Ny4xNzQ2MTU2ODg0*_ga_8JE65Q40S6*czE3NTExMTIxMjYkbzkkZzEkdDE3NTExMTIxNTUkajMxJGwwJGgw',
          ),
          onBackgroundImageError: (exception, stackTrace) {},
          child: null,
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Admin Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '30Shine Management',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => _showNotifications(context),
        ),
        IconButton(
          icon: const Icon(Icons.logout_outlined, color: Colors.white),
          onPressed: () => _logout(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chào mừng trở lại!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quản lý hiệu quả hệ thống 30Shine',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Hôm nay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.admin_panel_settings, size: 60, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Tổng đặt lịch',
            '124',
            Icons.calendar_today,
            const Color(0xFF388E3C),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Doanh thu',
            '50M',
            Icons.attach_money,
            const Color(0xFF1976D2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Khách hàng',
            '1,234',
            Icons.people,
            const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid(List<_DashboardItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildDashboardCard(item);
      },
    );
  }

  Widget _buildDashboardCard(_DashboardItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 32, color: item.color),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.notifications,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text('Thông báo'),
              ],
            ),
            content: const Text('Không có thông báo mới.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Cài đặt'),
              ],
            ),
            content: const Text(
              'Tính năng cài đặt sẽ được cập nhật trong phiên bản tiếp theo.',
            ),
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
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.logout, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text('Đăng xuất'),
              ],
            ),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await StorageService.clearStorage();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );
  }
}

class _DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
