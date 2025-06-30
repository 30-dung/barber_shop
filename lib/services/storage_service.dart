// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/employee_model.dart';

class StorageService {
  static const String _keyUser = 'user';
  static const String _keyEmployee = 'employee';
  static const String _keyToken = 'token';

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      print('✅ Token đã lưu thành công');
    } catch (e) {
      print('❌ Lỗi lưu token: $e');
      throw e;
    }
  }

  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_keyUser, userJson);
      print(
        '✅ User đã lưu thành công: ${user.fullName} (ID: ${user.userId}, Role: ${user.role.toString().split('.').last})',
      );
    } catch (e) {
      print('❌ Lỗi lưu user: $e');
      print('User data: ${user.toString()}');
      throw e;
    }
  }

  static Future<void> saveEmployee(Employee employee) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeJson = jsonEncode(employee.toJson());
      await prefs.setString(_keyEmployee, employeeJson);
      print(
        '✅ Employee đã lưu thành công: ${employee.fullName} (ID: ${employee.employeeId})',
      );
    } catch (e) {
      print('❌ Lỗi lưu employee: $e');
      print('Employee data: ${employee.toString()}');
      throw e;
    }
  }

  // Thêm vào class StorageService
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming 'user_id' is stored directly as an int or within the user object
    final userJson = prefs.getString(_keyUser);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final userData = jsonDecode(userJson);
        return User.fromJson(userData).userId; // Get userId from User model
      } catch (e) {
        print('❌ Lỗi parse user data để lấy userId: $e');
        return null;
      }
    }
    return null;
  }

  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUser);

      if (userJson != null && userJson.isNotEmpty) {
        final userData = jsonDecode(userJson);
        final user = User.fromJson(userData);
        print(
          '✅ Lấy user thành công: ${user.fullName} (ID: ${user.userId}, Role: ${user.role.toString().split('.').last})',
        );
        return user;
      } else {
        print('❌ Không tìm thấy user trong storage');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi lấy user: $e');
      return null;
    }
  }

  static Future<Employee?> getEmployee() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeJson = prefs.getString(_keyEmployee);

      if (employeeJson != null && employeeJson.isNotEmpty) {
        final employeeData = jsonDecode(employeeJson);
        if (employeeData is Map<String, dynamic>) {
          final employee = Employee.fromJson(employeeData);
          print(
            '✅ Lấy employee thành công: ${employee.fullName} (ID: ${employee.employeeId})',
          );
          return employee;
        } else {
          print(
            '❌ Employee data không phải Map<String, dynamic>: $employeeData',
          );
          return null;
        }
      } else {
        print('❌ Không tìm thấy employee trong storage');
        return StorageService.clearStorage().then((_) => null);
        ;
      }
    } catch (e) {
      print('❌ Lỗi lấy employee: $e');
      return StorageService.clearStorage().then((_) => null);
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keyToken);

      if (token != null && token.isNotEmpty) {
        print('✅ Lấy token thành công: ${token.substring(0, 20)}...');
        return token;
      } else {
        print('❌ Không tìm thấy token trong storage');
        return StorageService.clearStorage().then((_) => null);
      }
    } catch (e) {
      print('❌ Lỗi lấy token: $e');
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasToken = prefs.containsKey(_keyToken);
      final hasUser =
          prefs.containsKey(_keyUser) || prefs.containsKey(_keyEmployee);

      print('Storage status - Token: $hasToken, User/Employee data: $hasUser');
      return hasToken && hasUser;
    } catch (e) {
      print('❌ Lỗi kiểm tra trạng thái đăng nhập: $e');
      return false;
    }
  }

  // UPDATED: Phương thức kiểm tra role hiện tại với hỗ trợ admin
  static Future<String?> getCurrentUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Kiểm tra xem có employee data không (Employee role)
      if (prefs.containsKey(_keyEmployee)) {
        final employeeJson = prefs.getString(_keyEmployee);
        if (employeeJson != null && employeeJson.isNotEmpty) {
          print('✅ Phát hiện role: EMPLOYEE');
          return 'EMPLOYEE';
        }
      }

      // Kiểm tra xem có user data không (có thể là Admin hoặc Customer)
      if (prefs.containsKey(_keyUser)) {
        final userJson = prefs.getString(_keyUser);
        if (userJson != null && userJson.isNotEmpty) {
          try {
            final userData = jsonDecode(userJson);
            final user = User.fromJson(userData);

            // Kiểm tra role cụ thể từ User object
            final roleString =
                user.role.toString().split('.').last.toLowerCase();

            if (roleString == 'admin') {
              print('✅ Phát hiện role: ADMIN');
              return 'ADMIN';
            } else {
              print('✅ Phát hiện role: CUSTOMER');
              return 'CUSTOMER'; // Đã thêm dòng này để đảm bảo có return
            }
          } catch (e) {
            print('❌ Lỗi parse user data, mặc định là CUSTOMER: $e');
            return 'CUSTOMER';
          }
        }
      }

      print('❌ Không tìm thấy role nào');
      return null;
    } catch (e) {
      print('❌ Lỗi kiểm tra role: $e');
      return null;
    }
  }

  // NEW: Phương thức lấy UserRole enum
  static Future<Object?> getCurrentUserRoleEnum() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Kiểm tra employee trước
      if (prefs.containsKey(_keyEmployee)) {
        final employeeJson = prefs.getString(_keyEmployee);
        if (employeeJson != null && employeeJson.isNotEmpty) {
          final employeeData = jsonDecode(employeeJson);
          final employee = Employee.fromJson(employeeData);
          return employee.roles;
        }
      }

      // Sau đó kiểm tra user
      if (prefs.containsKey(_keyUser)) {
        final userJson = prefs.getString(_keyUser);
        if (userJson != null && userJson.isNotEmpty) {
          final userData = jsonDecode(userJson);
          final user = User.fromJson(userData);
          return user.role;
        }
      }

      return null;
    } catch (e) {
      print('❌ Lỗi lấy UserRole enum: $e');
      return null;
    }
  }

  // Phương thức clear data theo role
  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUser);
      print('✅ Đã xóa user data');
    } catch (e) {
      print('❌ Lỗi xóa user data: $e');
    }
  }

  static Future<void> clearEmployeeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyEmployee);
      print('✅ Đã xóa employee data');
    } catch (e) {
      print('❌ Lỗi xóa employee data: $e');
    }
  }

  static Future<void> clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ Đã xóa toàn bộ storage');
    } catch (e) {
      print('❌ Lỗi xóa storage: $e');
    }
  }

  static Future<void> debugStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      print('=== DEBUG STORAGE ===');
      print('Các key có trong storage: $keys');

      for (String key in keys) {
        final value = prefs.get(key);
        if (key == _keyToken && value is String) {
          print('$key: ${value.substring(0, 20)}...');
        } else {
          print('$key: $value');
        }
      }
      print('===================');
    } catch (e) {
      print('❌ Lỗi debug storage: $e');
    }
  }
}
