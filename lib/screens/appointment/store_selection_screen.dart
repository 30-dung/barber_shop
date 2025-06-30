import 'package:flutter/material.dart';
import '../../models/location_count_model.dart';
import '../../models/store_model.dart';
import '../../models/service_detail_model.dart'; // Import ServiceDetail
import '../../services/api_service.dart';
import 'store_services_screen.dart'; // Navigate to this new screen

class StoreSelectionScreen extends StatefulWidget {
  // Optional parameters for initial selection if coming from a different flow
  final ServiceDetail? serviceDetail;
  final Store? selectedStore;

  const StoreSelectionScreen({
    super.key,
    this.serviceDetail,
    this.selectedStore,
  });

  @override
  State<StoreSelectionScreen> createState() => _StoreSelectionScreenState();
}

class _StoreSelectionScreenState extends State<StoreSelectionScreen> {
  List<Store> _stores = [];
  List<LocationCount> _cities = [];
  List<LocationCount> _districts = [];

  LocationCount? _selectedCity;
  LocationCount? _selectedDistrict;

  bool _isPageLoading = true;
  bool _isStoreListLoading = false;
  bool _isDistrictLoading = false;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => _isPageLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getStores(),
        ApiService.getStoreCities(),
      ]);
      setState(() {
        _stores = results[0] as List<Store>;
        _cities = results[1] as List<LocationCount>;

        // Set initial selected city if provided and exists in _cities
        if (widget.selectedStore != null) {
          final initialCity = _cities.firstWhereOrNull(
            (c) => c.name == widget.selectedStore!.cityProvince,
          );
          if (initialCity != null) {
            _selectedCity = initialCity;
            _loadDistricts(
              initialCity.name,
            ); // Load districts for the initial city
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPageLoading = false);
    }
  }

  Future<void> _loadStores() async {
    setState(() => _isStoreListLoading = true);
    try {
      final stores = await ApiService.getStores(
        city: _selectedCity?.name,
        district: _selectedDistrict?.name,
      );
      setState(() => _stores = stores);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải cửa hàng: $e')));
      }
    } finally {
      if (mounted) setState(() => _isStoreListLoading = false);
    }
  }

  Future<void> _loadDistricts(String cityName) async {
    setState(() {
      _isDistrictLoading = true;
      _districts = [];
      _selectedDistrict = null; // Clear selected district when city changes
    });
    try {
      final districts = await ApiService.getStoreDistricts(cityName);
      setState(() => _districts = districts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải quận/huyện: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDistrictLoading = false);
    }
  }

  void _onCityChanged(LocationCount? newCity) {
    if (newCity == null || newCity == _selectedCity) return;
    setState(() {
      _selectedCity = newCity;
      _selectedDistrict = null; // Reset district when city changes
    });
    _loadDistricts(newCity.name);
    _loadStores();
  }

  void _onDistrictChanged(LocationCount? newDistrict) {
    if (newDistrict == _selectedDistrict) return;
    setState(() => _selectedDistrict = newDistrict);
    _loadStores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn Cửa Hàng')),
      body:
          _isPageLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildFilters(),
                  Expanded(
                    child:
                        _isStoreListLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _stores.isEmpty
                            ? const Center(
                              child: Text('Không tìm thấy cửa hàng nào.'),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: _stores.length,
                              itemBuilder: (context, index) {
                                return _buildStoreItem(_stores[index]);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<LocationCount>(
              value: _selectedCity,
              hint: const Text('Tỉnh/Thành phố'),
              isExpanded: true,
              items:
                  _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text('${city.name} (${city.count})'),
                    );
                  }).toList(),
              onChanged: _onCityChanged,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<LocationCount>(
              value: _selectedDistrict,
              hint: const Text('Quận/Huyện'),
              isExpanded: true,
              items:
                  _districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text('${district.name} (${district.count})'),
                    );
                  }).toList(),
              onChanged: _onDistrictChanged,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon:
                    _isDistrictLoading
                        ? const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
              ),
              disabledHint:
                  _selectedCity == null ? const Text('Chọn TP trước') : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreItem(Store store) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          child: Icon(Icons.storefront),
        ),
        title: Text(
          store.storeName ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text('${store.district}, ${store.cityProvince}'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => StoreServicesScreen(store: store),
            ),
          );
        },
      ),
    );
  }
}

// Extension to help find firstWhereOrNull for LocationCount
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
