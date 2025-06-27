// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/employee_model.dart'; // Import Employee model

class StorageService {
  static const String _keyUser = 'user';
  static const String _keyEmployee = 'employee'; // New key for employee data
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
      print('✅ User đã lưu thành công: ${user.fullName} (ID: ${user.userId})');
    } catch (e) {
      print('❌ Lỗi lưu user: $e');
      print('User data: ${user.toString()}');
      throw e;
    }
  }

  // --- NEW: Save Employee data ---
  static Future<void> saveEmployee(Employee employee) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeJson = jsonEncode(employee.toJson());
      await prefs.setString(_keyEmployee, employeeJson);
      print('✅ Employee đã lưu thành công: ${employee.fullName} (ID: ${employee.employeeId})');
    } catch (e) {
      print('❌ Lỗi lưu employee: $e');
      print('Employee data: ${employee.toString()}');
      throw e;
    }
  }


  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUser);

      if (userJson != null && userJson.isNotEmpty) {
        final userData = jsonDecode(userJson);
        final user = User.fromJson(userData);
        print('✅ Lấy user thành công: ${user.fullName} (ID: ${user.userId})');
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

  // --- NEW: Get Employee data ---
  static Future<Employee?> getEmployee() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeJson = prefs.getString(_keyEmployee);

      if (employeeJson != null && employeeJson.isNotEmpty) {
        final employeeData = jsonDecode(employeeJson);
        final employee = Employee.fromJson(employeeData);
        print('✅ Lấy employee thành công: ${employee.fullName} (ID: ${employee.employeeId})');
        return employee;
      } else {
        print('❌ Không tìm thấy employee trong storage');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi lấy employee: $e');
      return null;
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
        return null;
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
      final hasUser = prefs.containsKey(_keyUser) || prefs.containsKey(_keyEmployee); // User is logged in if either User or Employee data is present

      print('Storage status - Token: $hasToken, User/Employee data: $hasUser');

      return hasToken && hasUser;
    } catch (e) {
      print('❌ Lỗi kiểm tra trạng thái đăng nhập: $e');
      return false;
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
