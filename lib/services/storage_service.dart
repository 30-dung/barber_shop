// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class StorageService {
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';
  // Removed _keyIsLoggedIn as it's redundant with checking _keyToken and _keyUser

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      // Removed: await prefs.setBool(_keyIsLoggedIn, true);
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
      // Removed: await prefs.setBool(_keyIsLoggedIn, true);
      print('✅ User đã lưu thành công: ${user.fullName} (ID: ${user.userId})');
    } catch (e) {
      print('❌ Lỗi lưu user: $e');
      print('User data: ${user.toString()}');
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
      // If parsing fails or data is corrupt, treat as not logged in
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
      // If retrieval fails, treat as no token
      return null;
    }
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // User is considered logged in if a token AND user object are present.
      // This is robust as both are needed for API calls.
      final hasToken = prefs.containsKey(_keyToken);
      final hasUser = prefs.containsKey(_keyUser);

      print('Storage status - Token: $hasToken, User: $hasUser');

      return hasToken && hasUser;
    } catch (e) {
      print('❌ Lỗi kiểm tra trạng thái đăng nhập: $e');
      return false;
    }
  }

  static Future<void> clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Clearing all keys ensures a clean logout
      await prefs.clear();
      print('✅ Đã xóa toàn bộ storage');
    } catch (e) {
      print('❌ Lỗi xóa storage: $e');
    }
  }

  // Debug method (no changes, already good)
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
