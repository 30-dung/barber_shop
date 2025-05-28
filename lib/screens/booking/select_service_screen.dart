import 'package:flutter/material.dart';
import 'package:barber_app/models/service.dart';
import 'package:barber_app/services/api_service.dart';
import 'package:barber_app/utils/colors.dart';

class SelectServiceScreen extends StatefulWidget {
  final List<Service> initialSelectedServices; // Dịch vụ đã chọn ban đầu

  const SelectServiceScreen({Key? key, this.initialSelectedServices = const []})
    : super(key: key);

  @override
  State<SelectServiceScreen> createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  final ApiService _apiService = ApiService();
  List<Service> _allServices = [];
  bool _isLoading = true;
  List<Service> _currentSelectedServices =
      []; // Dịch vụ đang được chọn trong màn hình này

  @override
  void initState() {
    super.initState();
    _currentSelectedServices = List.from(
      widget.initialSelectedServices,
    ); // Sao chép danh sách ban đầu
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _allServices = await _apiService.getServices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách dịch vụ: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isServiceSelected(Service service) {
    return _currentSelectedServices.any((s) => s.id == service.id);
  }

  void _toggleServiceSelection(Service service) {
    setState(() {
      if (_isServiceSelected(service)) {
        _currentSelectedServices.removeWhere((s) => s.id == service.id);
      } else {
        _currentSelectedServices.add(service);
      }
    });
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Dịch vụ'),
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              Navigator.pop(
                context,
                _currentSelectedServices,
              ); // Trả về danh sách dịch vụ đã chọn
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _allServices.isEmpty
              ? const Center(child: Text('Không có dịch vụ nào để hiển thị.'))
              : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _allServices.length,
                itemBuilder: (context, index) {
                  final service = _allServices[index];
                  final isSelected = _isServiceSelected(service);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () => _toggleServiceSelection(service),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                service.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 70,
                                      height: 70,
                                      color: AppColors.lightGrey,
                                      child: const Icon(
                                        Icons.cut,
                                        size: 35,
                                        color: AppColors.secondaryGrey,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDarkBlue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${service.duration} phút',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondaryGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCurrency(service.price),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                _toggleServiceSelection(service);
                              },
                              activeColor: AppColors.accentBlue,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryDarkBlue,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã chọn ${_currentSelectedServices.length} dịch vụ',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _currentSelectedServices);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
