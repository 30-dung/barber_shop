import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/constants/app_constants.dart';
import 'storage_service.dart';

class ApiStoreService {
  static String get baseUrl => AppConstants.baseUrl;

  static Future<List<dynamic>> getServices() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/services'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Không thể tải danh sách dịch vụ: ${response.statusCode}');
  }

  static Future<List<dynamic>> getStores() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store/all'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Không thể tải danh sách cửa hàng: ${response.statusCode}');
  }

  static Future<void> createService(Map<String, dynamic> data) async {
    final token = await StorageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/services'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      String message = 'Không thể thêm dịch vụ';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<void> updateService(int id, Map<String, dynamic> data) async {
    final token = await StorageService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/services/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      String message = 'Không thể cập nhật dịch vụ';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<void> deleteService(int id) async {
    final token = await StorageService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/services/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      String message = 'Không thể xóa dịch vụ';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<void> createServicePrice(Map<String, dynamic> data) async {
    final token = await StorageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/store-service/price'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      String message =
          'Dịch vụ này đã tồn tại cho cửa hàng này. Vui lòng cập nhật thay vì tạo mới.';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        } else if (body is String) {
          message = body;
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<void> updateServicePrice(
    int id,
    Map<String, dynamic> data,
  ) async {
    final token = await StorageService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/store-service/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      String message = 'Không thể cập nhật giá dịch vụ';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<void> deleteServicePrice(int storeServiceId) async {
    final token = await StorageService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/store-service/$storeServiceId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      String message = 'Không thể xóa dịch vụ khỏi cửa hàng';
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'];
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  // Phương thức API mới để lấy dịch vụ của một cửa hàng cụ thể
  static Future<List<dynamic>> getStoreServicesByStoreId(int storeId) async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store-service/store/$storeId'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(
      'Không thể tải dịch vụ của cửa hàng: ${response.statusCode}',
    );
  }
}
