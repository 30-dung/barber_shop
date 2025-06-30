import 'package:flutter/material.dart';
import 'package:shine_booking_app/screens/employee/store_details_review_screen.dart';
import '../../../models/store_model.dart';
import '../../../services/api_store.dart';
import 'store_form_dialog.dart';

class ManageStoresScreen extends StatefulWidget {
  const ManageStoresScreen({super.key});

  @override
  State<ManageStoresScreen> createState() => _ManageStoresScreenState();
}

class _ManageStoresScreenState extends State<ManageStoresScreen> {
  List<Store> stores = [];
  List<Store> filteredStores = [];
  bool isLoading = true;
  String selectedFilter = 'all';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStores();
    searchController.addListener(_filterStores);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStores() async {
    setState(() => isLoading = true);
    try {
      stores = await ApiStoreService.getStores();
      _applyFilters();
    } catch (e) {
      _showErrorSnackBar('Lỗi tải cửa hàng: $e');
    }
    setState(() => isLoading = false);
  }

  void _filterStores() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredStores =
          stores.where((store) {
            final matchesSearch =
                query.isEmpty ||
                (store.storeName?.toLowerCase().contains(query) ?? false) ||
                (store.cityProvince?.toLowerCase().contains(query) ?? false) ||
                (store.district?.toLowerCase().contains(query) ?? false);

            final matchesFilter =
                selectedFilter == 'all' ||
                (selectedFilter == 'high_rated' &&
                    (store.averageRating ?? 0) >= 4.0) ||
                (selectedFilter == 'new' && store.storeId != null);

            return matchesSearch && matchesFilter;
          }).toList();
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showAddStoreDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StoreFormDialog(
            onSaved: () {
              _showSuccessSnackBar('Thêm cửa hàng thành công!');
              _fetchStores();
            },
            onError: _showErrorSnackBar,
          ),
    );
  }

  void _showEditStoreDialog(Store store) {
    showDialog(
      context: context,
      builder:
          (context) => StoreFormDialog(
            store: store,
            onSaved: () {
              _showSuccessSnackBar('Cập nhật cửa hàng thành công!');
              _fetchStores();
            },
            onError: _showErrorSnackBar,
          ),
    );
  }

  Future<void> _deleteStore(Store store) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: const Row(
              children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('Xác nhận xóa'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bạn có chắc chắn muốn xóa cửa hàng "${store.storeName}"?',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hành động này không thể hoàn tác.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirmed == true && store.storeId != null) {
      try {
        await ApiStoreService.deleteStore(store.storeId!);
        _showSuccessSnackBar('Xóa cửa hàng thành công!');
        _fetchStores();
      } catch (e) {
        _showErrorSnackBar('Lỗi xóa cửa hàng: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          _buildStatsCards(),
          Expanded(child: _buildStoresList()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Quản lý cửa hàng',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _fetchStores,
          icon: const Icon(Icons.refresh),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    final filters = [
      {'key': 'all', 'label': 'Tất cả', 'icon': Icons.store},
      {'key': 'high_rated', 'label': 'Đánh giá cao', 'icon': Icons.star},
      {'key': 'new', 'label': 'Mới nhất', 'icon': Icons.new_releases},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  filters.map((filter) {
                    final isSelected = selectedFilter == filter['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedFilter = filter['key'] as String;
                            _applyFilters();
                          });
                        },
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              filter['icon'] as IconData,
                              size: 16,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFFFF6B35),
                            ),
                            const SizedBox(width: 4),
                            Text(filter['label'] as String),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFFFF6B35),
                        labelStyle: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFFFF6B35),
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? const Color(0xFFFF6B35)
                                    : Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm cửa hàng...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B35)),
          suffixIcon:
              searchController.text.isNotEmpty
                  ? IconButton(
                    onPressed: () {
                      searchController.clear();
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear, color: Colors.grey),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Tổng cửa hàng',
              stores.length.toString(),
              Icons.store,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Đánh giá cao',
              stores
                  .where((s) => (s.averageRating ?? 0) >= 4.0)
                  .length
                  .toString(),
              Icons.star,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Hiển thị',
              filteredStores.length.toString(),
              Icons.visibility,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStoresList() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF6B35)),
            SizedBox(height: 16),
            Text('Đang tải cửa hàng...'),
          ],
        ),
      );
    }

    if (filteredStores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              stores.isEmpty ? Icons.store_mall_directory : Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              stores.isEmpty
                  ? 'Chưa có cửa hàng nào'
                  : 'Không tìm thấy kết quả phù hợp',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stores.isEmpty
                  ? 'Thêm cửa hàng đầu tiên của bạn'
                  : 'Thử thay đổi từ khóa tìm kiếm',
              style: TextStyle(color: Colors.grey[500]),
            ),
            if (stores.isEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showAddStoreDialog,
                icon: const Icon(Icons.add),
                label: const Text('Thêm cửa hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchStores,
      color: const Color(0xFFFF6B35),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredStores.length,
        itemBuilder: (context, index) => _buildStoreCard(filteredStores[index]),
      ),
    );
  }

  Widget _buildStoreCard(Store store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StoreDetailScreen(store: store)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        store.storeImages != null &&
                                store.storeImages!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                store.storeImages!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (c, e, s) => const Icon(
                                      Icons.store,
                                      color: Color(0xFFFF6B35),
                                      size: 24,
                                    ),
                              ),
                            )
                            : const Icon(
                              Icons.store,
                              color: Color(0xFFFF6B35),
                              size: 24,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.storeName ?? 'Không có tên',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${store.district ?? ''}, ${store.cityProvince ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditStoreDialog(store);
                          break;
                        case 'delete':
                          _deleteStore(store);
                          break;
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (store.description?.isNotEmpty == true) ...[
                Text(
                  store.description!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  if (store.phoneNumber?.isNotEmpty == true) ...[
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      store.phoneNumber!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (store.averageRating != null) ...[
                    Icon(Icons.star, size: 14, color: Colors.orange[600]),
                    const SizedBox(width: 4),
                    Text(
                      store.averageRating!.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.orange[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                  if (store.openingTime != null &&
                      store.closingTime != null) ...[
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${store.openingTime} - ${store.closingTime}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _showAddStoreDialog,
      backgroundColor: const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Thêm cửa hàng'),
    );
  }
}
