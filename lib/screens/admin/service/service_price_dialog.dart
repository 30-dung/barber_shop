import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_booking_app/models/service_detail_model.dart';
import 'package:shine_booking_app/services/api_store_service.dart';
import 'package:shine_booking_app/models/store_model.dart';
import 'package:shine_booking_app/models/store_service_model.dart';

class ServicePriceDialog extends StatefulWidget {
  final Store store;

  const ServicePriceDialog({super.key, required this.store});

  @override
  State<ServicePriceDialog> createState() => _ServicePriceDialogState();
}

class _ServicePriceDialogState extends State<ServicePriceDialog> {
  List<ServiceDetail> allServices = [];
  List<StoreService> storeServices = [];
  Map<int, bool> selectedServices = {};
  Map<int, TextEditingController> priceControllers = {};
  bool isLoading = true;
  String? errorMsg;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadServicesAndStoreServices();
  }

  @override
  void dispose() {
    for (var controller in priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadServicesAndStoreServices() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      // Load tất cả dịch vụ
      final servicesData = await ApiStoreService.getServices();
      allServices =
          servicesData
              .map<ServiceDetail>((json) => ServiceDetail.fromJson(json))
              .toList();

      // Load dịch vụ hiện có của cửa hàng - sử dụng storeId thay vì id
      final storeId = widget.store.storeId ?? widget.store.storeId;
      if (storeId != null) {
        final storeServicesData =
            await ApiStoreService.getStoreServicesByStoreId(storeId);
        storeServices =
            storeServicesData
                .map<StoreService>((json) => StoreService.fromJson(json))
                .toList();
      }

      // Khởi tạo trạng thái checkbox và controller giá dựa trên dịch vụ hiện có
      for (var service in allServices) {
        final existingStoreService = storeServices.firstWhereOrNull(
          (ss) => ss.service.serviceId == service.serviceId,
        );

        selectedServices[service.serviceId] = existingStoreService != null;

        // Format price từ number thành string với dấu phẩy
        String priceText = '';
        if (existingStoreService != null) {
          // API trả về price dưới dạng number, cần convert thành string và format
          final priceValue = existingStoreService.price;
          if (priceValue is num) {
            priceText = _formatPrice(priceValue.toInt().toString());
          } else if (priceValue.toString().isNotEmpty) {
            priceText = _formatPrice(priceValue.toString());
          }
        }

        priceControllers[service.serviceId] = TextEditingController(
          text: priceText,
        );
      }
    } catch (e) {
      errorMsg = 'Lỗi tải dữ liệu: $e';
      print('Error loading data: $e'); // Debug log
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleService(int? serviceId, bool selected) {
    if (serviceId == null) return;
    setState(() {
      selectedServices[serviceId] = selected;
      if (!selected) {
        priceControllers[serviceId]?.clear();
      }
    });
  }

  Future<void> _saveServicePrices() async {
    List<String> errors = [];
    Map<int, double> servicesToProcess = {};

    for (var entry in selectedServices.entries) {
      if (entry.value) {
        final serviceId = entry.key;
        final priceText = priceControllers[serviceId]?.text ?? '';

        if (priceText.isEmpty) {
          final service = allServices.firstWhere(
            (s) => s.serviceId == serviceId,
          );
          errors.add('Chưa nhập giá cho dịch vụ "${service.serviceName}"');
        } else {
          // Xóa dấu phẩy trước khi parse
          final price = double.tryParse(priceText.replaceAll(',', ''));
          if (price == null || price <= 0) {
            final service = allServices.firstWhere(
              (s) => s.serviceId == serviceId,
            );
            errors.add('Giá không hợp lệ cho dịch vụ "${service.serviceName}"');
          } else {
            servicesToProcess[serviceId] = price;
          }
        }
      }
    }

    if (errors.isNotEmpty) {
      _showSnackBar(errors.first, isError: true);
      return;
    }

    if (servicesToProcess.isEmpty && storeServices.isEmpty) {
      _showSnackBar('Vui lòng chọn ít nhất một dịch vụ', isError: true);
      return;
    }

    setState(() => isSaving = true);

    try {
      // Lấy storeId đúng cách
      final storeId = widget.store.storeId ?? widget.store.storeId;

      // Danh sách các dịch vụ cần xóa khỏi cửa hàng
      List<int> servicesToDelete = [];
      for (var existingService in storeServices) {
        if (!selectedServices.containsKey(existingService.service.serviceId) ||
            !selectedServices[existingService.service.serviceId]!) {
          servicesToDelete.add(existingService.storeServiceId!);
        }
      }

      // Xóa các dịch vụ không còn được chọn
      for (var storeServiceId in servicesToDelete) {
        await ApiStoreService.deleteServicePrice(storeServiceId);
      }

      // Xử lý thêm mới hoặc cập nhật
      for (var entry in servicesToProcess.entries) {
        final serviceId = entry.key;
        final price = entry.value;

        final existingStoreService = storeServices.firstWhereOrNull(
          (ss) => ss.service.serviceId == serviceId,
        );

        final data = {
          'storeId': storeId,
          'serviceId': serviceId,
          'price': price,
        };

        if (existingStoreService != null) {
          // Cập nhật dịch vụ
          await ApiStoreService.updateServicePrice(
            existingStoreService.storeServiceId!,
            data,
          );
        } else {
          // Thêm mới dịch vụ
          await ApiStoreService.createServicePrice(data);
        }
      }

      _showSnackBar('Cập nhật dịch vụ cho cửa hàng thành công!');
      Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Lỗi: $e', isError: true);
      print('Error saving: $e'); // Debug log
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatPrice(String value) {
    if (value.isEmpty) return value;

    // Remove all non-digit characters
    String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanValue.isEmpty) return '';

    // Add thousand separators
    final formatter = RegExp(r'(\d)(?=(\d{3})+(?!\d))');
    return cleanValue.replaceAllMapped(formatter, (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.price_change, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Thêm giá dịch vụ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.store.storeName ??
                              widget.store.storeName ??
                              'Cửa hàng',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child:
                  isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                      )
                      : errorMsg != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[400],
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                errorMsg!,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      : allServices.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Chưa có dịch vụ nào',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                      : Column(
                        children: [
                          // Instructions
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF6B35).withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'Tích chọn các dịch vụ và nhập giá cho từng dịch vụ',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          // Services List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: allServices.length,
                              itemBuilder: (context, index) {
                                final service = allServices[index];
                                final isSelected =
                                    selectedServices[service.serviceId] ??
                                    false;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? const Color(0xFFFF6B35)
                                              : const Color(0xFFE9ECEF),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    color:
                                        isSelected
                                            ? const Color(
                                              0xFFFF6B35,
                                            ).withOpacity(0.05)
                                            : Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Checkbox
                                            Checkbox(
                                              value: isSelected,
                                              onChanged:
                                                  (value) => _toggleService(
                                                    service.serviceId,
                                                    value ?? false,
                                                  ),
                                              activeColor: const Color(
                                                0xFFFF6B35,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),

                                            // Service Info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    service.serviceName,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          isSelected
                                                              ? const Color(
                                                                0xFFFF6B35,
                                                              )
                                                              : const Color(
                                                                0xFF2C3E50,
                                                              ),
                                                    ),
                                                  ),
                                                  if (service.description !=
                                                      null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      service.description!,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF3498DB,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${service.durationMinutes} phút',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Color(
                                                          0xFF3498DB,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Price Input
                                        if (isSelected) ...[
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            controller:
                                                priceControllers[service
                                                    .serviceId],
                                            decoration: InputDecoration(
                                              labelText: 'Giá dịch vụ (VNĐ)',
                                              prefixIcon: const Icon(
                                                Icons.attach_money,
                                                color: Color(0xFFFF6B35),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFFFF6B35),
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Colors.white,
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                            onChanged: (value) {
                                              final formatted = _formatPrice(
                                                value,
                                              );
                                              if (formatted != value) {
                                                priceControllers[service
                                                        .serviceId]
                                                    ?.value = TextEditingValue(
                                                  text: formatted,
                                                  selection:
                                                      TextSelection.collapsed(
                                                        offset:
                                                            formatted.length,
                                                      ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đã chọn: ${selectedServices.values.where((v) => v).length} dịch vụ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed:
                            isSaving ? null : () => Navigator.pop(context),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: isSaving ? null : _saveServicePrices,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          elevation: 2,
                        ),
                        icon:
                            isSaving
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Icon(Icons.check, size: 20),
                        label: Text(isSaving ? 'Đang lưu...' : 'Xác nhận'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension để hỗ trợ firstWhereOrNull
extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
