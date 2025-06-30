import 'package:flutter/material.dart';
import 'package:shine_booking_app/services/api_store_service.dart';
import 'package:shine_booking_app/models/store_model.dart'; // Import Store model
import 'service_price_dialog.dart';

class StoreListDialog extends StatefulWidget {
  const StoreListDialog({super.key});

  @override
  State<StoreListDialog> createState() => _StoreListDialogState();
}

class _StoreListDialogState extends State<StoreListDialog> {
  List<Store> stores = []; // Thay đổi kiểu dữ liệu thành List<Store>
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      final storesData = await ApiStoreService.getStores();
      // Chuyển đổi dữ liệu JSON thành danh sách các đối tượng Store
      stores = storesData.map<Store>((json) => Store.fromJson(json)).toList();
    } catch (e) {
      errorMsg = 'Lỗi tải danh sách cửa hàng: $e';
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showServicePriceDialog(Store store) {
    // Thay đổi kiểu dữ liệu tham số
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => ServicePriceDialog(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (giữ nguyên)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.store, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Chọn cửa hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadStores,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      )
                      : stores.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.store_outlined,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có cửa hàng nào',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE9ECEF),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => _showServicePriceDialog(store),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(
                                                0xFFFF6B35,
                                              ).withOpacity(0.1),
                                              const Color(
                                                0xFFFF6B35,
                                              ).withOpacity(0.05),
                                            ],
                                          ),
                                        ),
                                        child:
                                            store.storeImages !=
                                                    null // Sử dụng store.storeImages
                                                ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: Image.network(
                                                    store
                                                        .storeImages!, // Sử dụng store.storeImages
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                              Icons.store,
                                                              color: Color(
                                                                0xFFFF6B35,
                                                              ),
                                                              size: 28,
                                                            ),
                                                  ),
                                                )
                                                : const Icon(
                                                  Icons.store,
                                                  color: Color(0xFFFF6B35),
                                                  size: 28,
                                                ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              store.storeName ??
                                                  'Không có tên', // Sử dụng store.name
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF2C3E50),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              store
                                                  .cityProvince!, // Sử dụng computed property fullAddress
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFFFF6B35),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
