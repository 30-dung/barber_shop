import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shine_booking_app/constants/app_constants.dart';
import '../models/store_model.dart';
import '../services/storage_service.dart';

class ApiStoreService {
  static String get baseUrl => AppConstants.baseUrl;

  // Lấy danh sách tất cả cửa hàng
  static Future<List<Store>> getStores() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store/all'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Store.fromJson(e)).toList();
    }
    throw Exception('Không thể tải danh sách cửa hàng');
  }

  // Lấy chi tiết 1 cửa hàng
  static Future<Store> getStoreById(int id) async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store/$id'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return Store.fromJson(json.decode(response.body));
    }
    throw Exception('Không tìm thấy cửa hàng');
  }

  // Thêm cửa hàng mới (có gửi token)
  static Future<Store> addStore(Map<String, dynamic> storeData) async {
    final token = await StorageService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/store/add'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(storeData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Store.fromJson(json.decode(response.body));
    }
    throw Exception('Không thể thêm cửa hàng');
  }

  // Sửa cửa hàng (có gửi token)
  static Future<Store> updateStore(
    int id,
    Map<String, dynamic> storeData,
  ) async {
    final token = await StorageService.getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/api/store/update/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(storeData),
    );
    if (response.statusCode == 200) {
      return Store.fromJson(json.decode(response.body));
    }
    throw Exception('Không thể cập nhật cửa hàng');
  }

  // Xóa cửa hàng (có gửi token)
  static Future<void> deleteStore(int id) async {
    final token = await StorageService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/store/delete/$id'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa cửa hàng');
    }
  }

  // Tìm kiếm cửa hàng (nếu backend hỗ trợ)
  static Future<List<Store>> searchStores(String query) async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store/locate?q=${Uri.encodeComponent(query)}'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Store.fromJson(e)).toList();
    }
    throw Exception('Không thể tìm kiếm cửa hàng');
  }

  // Lấy danh sách quận/huyện (loại bỏ trùng lặp)
  static Future<List<String>> getDistricts() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store/districts'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<String> raw = List<String>.from(json.decode(response.body));
      return raw.toSet().toList(); // Loại bỏ trùng lặp
    }
    throw Exception('Không thể lấy danh sách quận/huyện');
  }

  // Lấy danh sách thành phố/tỉnh (loại bỏ trùng lặp)
  static Future<List<String>> getCities() async {
    final token = await StorageService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/store/cities'),
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<String> raw = List<String>.from(json.decode(response.body));
      return raw.toSet().toList(); // Loại bỏ trùng lặp
    }
    throw Exception('Không thể lấy danh sách thành phố');
  }
}
