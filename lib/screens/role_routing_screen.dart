// lib/screens/role_routing_screen.dart
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../screens/auth/login_screen.dart';
import 'home/home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'employee/employee_dashboard_screen.dart';

class RoleRoutingScreen extends StatefulWidget {
  const RoleRoutingScreen({super.key});

  @override
  State<RoleRoutingScreen> createState() => _RoleRoutingScreenState();
}

class _RoleRoutingScreenState extends State<RoleRoutingScreen> {
  @override
  void initState() {
    super.initState();
    _checkRoleAndNavigate();
  }

  Future<void> _checkRoleAndNavigate() async {
    try {
      // Kiểm tra xem có đăng nhập không
      final isLoggedIn = await StorageService.isLoggedIn();

      if (!isLoggedIn) {
        print('❌ Chưa đăng nhập, chuyển về login');
        _navigateToLogin();
        return;
      }

      // Kiểm tra role
      final userRole = await StorageService.getCurrentUserRole();
      print('🔍 Role hiện tại: $userRole');

      switch (userRole) {
        case 'ADMIN':
          print('👑 Chuyển đến Admin Dashboard');
          _navigateToAdminDashboard();
          break;
        case 'EMPLOYEE':
          print('👨‍💼 Chuyển đến Employee Dashboard');
          _navigateToEmployeeDashboard();
          break;
        case 'CUSTOMER':
          print('👤 Chuyển đến Customer Home');
          _navigateToCustomerHome();
          break;
        default:
          print('❌ Role không xác định ($userRole), chuyển về login');
          await StorageService.clearStorage();
          _navigateToLogin();
          break;
      }
    } catch (e) {
      print('❌ Lỗi kiểm tra role: $e');
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToAdminDashboard() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    }
  }

  void _navigateToEmployeeDashboard() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EmployeeDashboardScreen()),
      );
    }
  }

  void _navigateToCustomerHome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFF6B35),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Đang kiểm tra thông tin...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary Admin Dashboard Screen - replace with actual screen
class TempAdminDashboardScreen extends StatelessWidget {
  const TempAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('30SHINE - Quản trị viên'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await StorageService.clearStorage();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Color(0xFFFF6B35),
            ),
            SizedBox(height: 20),
            Text(
              'Giao diện Quản trị viên',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Chào mừng bạn đến với bảng điều khiển quản trị',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary Employee Dashboard Screen - replace with actual screen
class TempEmployeeDashboardScreen extends StatelessWidget {
  const TempEmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('30SHINE - Nhân viên'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await StorageService.clearStorage();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work,
              size: 80,
              color: Color(0xFFFF6B35),
            ),
            SizedBox(height: 20),
            Text(
              'Giao diện Nhân viên',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Chào mừng bạn đến với hệ thống quản lý',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}