import 'dart:convert';
import 'package:barber_app/models/salon.dart';
import 'package:http/http.dart' as http;
import 'package:barber_app/utils/constants.dart';
import '../models/service.dart';

class ApiService {
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }

  Future<List<Salon>> getSalons() async {
    // Giả lập gọi API
    await Future.delayed(const Duration(seconds: 1));
    return [
      Salon(
        id: 1,
        name: 'Salon Tóc Nam Số 1',
        address: '123 Đường ABC, Quận 1, TP.HCM',
        imageUrl: 'https://via.placeholder.com/150/FF5733/FFFFFF?text=Salon1',
        rating: 4.8,
        reviewCount: 250,
      ),
      Salon(
        id: 2,
        name: 'Barber Shop Sài Gòn',
        address: '456 Phố XYZ, Quận 3, TP.HCM',
        imageUrl: 'https://via.placeholder.com/150/33FF57/FFFFFF?text=Salon2',
        rating: 4.5,
        reviewCount: 180,
      ),
      Salon(
        id: 3,
        name: 'The Gentlemen\'s Cut',
        address: '789 Đại lộ H, Quận 5, TP.HCM',
        imageUrl: 'https://via.placeholder.com/150/3357FF/FFFFFF?text=Salon3',
        rating: 4.9,
        reviewCount: 320,
      ),
    ];
  }

  Future<List<Service>> getServices() async {
    // Giả lập gọi API
    await Future.delayed(const Duration(seconds: 1));
    return [
      Service(
        id: 101,
        name: 'Cắt - Gội - Xả thư giãn',
        description:
            'Stylist cắt - xả - vuốt sáp tạo kiểu (Không gội & thư giãn)',
        price: 90000,
        duration: 30,
        imageUrl: 'https://via.placeholder.com/150/FF5733/FFFFFF?text=CatGoiXa',
      ),
      Service(
        id: 102,
        name: 'Cắt gội dưỡng sinh',
        description: 'Combo Cắt kỹ và Combo Gội Dưỡng Sinh Thư Giãn',
        price: 150000,
        duration: 60,
        imageUrl: 'https://via.placeholder.com/150/33FF57/FFFFFF?text=CatGoiDS',
      ),
      Service(
        id: 103,
        name: 'Uốn tóc nam',
        description: 'Uốn tóc theo phong cách Hàn Quốc/Châu Âu',
        price: 350000,
        duration: 90,
        imageUrl: 'https://via.placeholder.com/150/3357FF/FFFFFF?text=UonToc',
      ),
      Service(
        id: 104,
        name: 'Nhuộm tóc thời trang',
        description: 'Nhuộm các màu thời trang theo yêu cầu',
        price: 400000,
        duration: 120,
        imageUrl: 'https://via.placeholder.com/150/FFFF33/000000?text=NhuomToc',
      ),
    ];
  }
}
