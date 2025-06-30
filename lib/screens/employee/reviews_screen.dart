// lib/screens/employee/reviews_screen.dart
import 'package:flutter/material.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/store_model.dart'; // Import Store model
import 'package:shine_booking_app/services/storage_service.dart';
import 'package:shine_booking_app/screens/employee/store_details_review_screen.dart'; // Import StoreDetailScreen

class EmployeeReviewsScreen extends StatefulWidget {
  const EmployeeReviewsScreen({super.key});

  @override
  State<EmployeeReviewsScreen> createState() => _EmployeeReviewsScreenState();
}

class _EmployeeReviewsScreenState extends State<EmployeeReviewsScreen> {
  Employee? _employee;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final employee = await StorageService.getEmployee();
      if (mounted) {
        setState(() {
          _employee = employee;
          _isLoading = false;
          if (_employee == null) {
            _errorMessage =
                'Không tìm thấy dữ liệu nhân viên. Vui lòng đăng nhập lại.';
          } else if (_employee!.store == null) {
            _errorMessage = 'Bạn chưa được phân công cửa hàng.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khi tải dữ liệu nhân viên: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá cửa hàng của bạn'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadEmployeeData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
              : _employee!.store != null
              ? _buildStoreReviewSection(_employee!.store!)
              : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront, size: 80, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'Bạn chưa được phân công cửa hàng.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      'Vui lòng liên hệ quản lý để được phân công.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildStoreReviewSection(Store store) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cửa hàng của bạn: ${store.storeName ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.cityProvince != null
                              ? '${store.cityProvince}, ${store.district ?? ''}'
                              : 'Chưa có địa chỉ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.openingTime != null
                              ? 'Giờ mở cửa: ${store.openingTime} - ${store.closingTime}'
                              : 'Chưa có giờ mở cửa',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => StoreDetailScreen(store: store),
                          ),
                        );
                      },
                      icon: const Icon(Icons.rate_review),
                      label: const Text('Xem đánh giá chi tiết'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Có thể thêm các phần khác liên quan đến đánh giá nhân viên (của chính nhân viên) nếu có API
          const Text(
            'Thống kê đánh giá của bạn (sẽ phát triển sau)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Placeholder for employee specific reviews if needed
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Thống kê và đánh giá riêng của bạn sẽ được hiển thị tại đây.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
