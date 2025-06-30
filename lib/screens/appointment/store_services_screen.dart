import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/store_model.dart';
import '../../models/store_service_model.dart';
import 'employee_selection_screen.dart'; // Navigate to EmployeeSelectionScreen

class StoreServicesScreen extends StatefulWidget {
  final Store store;

  const StoreServicesScreen({super.key, required this.store});

  @override
  State<StoreServicesScreen> createState() => _StoreServicesScreenState();
}

class _StoreServicesScreenState extends State<StoreServicesScreen> {
  List<StoreService> _storeServices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreServices();
  }

  _loadStoreServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await ApiService.getServicesByStoreId(
        widget.store.storeId!,
      );
      setState(() {
        _storeServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dịch vụ của cửa hàng: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dịch vụ tại ${widget.store.storeName}')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _storeServices.isEmpty
              ? const Center(child: Text('Cửa hàng này chưa có dịch vụ nào.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _storeServices.length,
                itemBuilder: (context, index) {
                  final storeService = _storeServices[index];
                  return _buildStoreServiceItem(storeService);
                },
              ),
    );
  }

  Widget _buildStoreServiceItem(StoreService storeService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading:
            storeService.service.serviceImg != null &&
                    storeService.service.serviceImg!.isNotEmpty
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    storeService.service.serviceImg!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: const Color(0xFFFF6B35).withOpacity(0.1),
                          child: const Icon(
                            Icons.content_cut,
                            color: Color(0xFFFF6B35),
                            size: 30,
                          ),
                        ),
                  ),
                )
                : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: Color(0xFFFF6B35),
                    size: 30,
                  ),
                ),
        title: Text(
          storeService.service.serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              storeService.service.description ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${storeService.service.durationMinutes} phút',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                Text(
                  '${storeService.price.toDouble()}đ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to EmployeeSelectionScreen, passing the store and the selected StoreService
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => EmployeeSelectionScreen(
                    store: widget.store,
                    storeService:
                        storeService, // Truyền toàn bộ đối tượng StoreService
                  ),
            ),
          );
        },
      ),
    );
  }
}
