import 'package:flutter/material.dart';
import 'package:barber_app/models/service.dart'; // Đảm bảo bạn có file này
import 'package:barber_app/utils/colors.dart'; // Đảm bảo bạn có file này

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Service> services = []; // Danh sách dịch vụ gốc
  bool isLoading = false;
  Map<int, int> selectedServices = {}; // serviceId: quantity

  TextEditingController _searchController = TextEditingController();
  List<Service> _filteredServices =
      []; // Danh sách dịch vụ sau khi tìm kiếm và lọc
  String _searchQuery = '';
  String? _selectedFilter; // Tiêu chí lọc hiện tại (null ban đầu)

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Hàm được gọi khi từ khóa tìm kiếm thay đổi
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFiltersAndSearch(); // Áp dụng cả tìm kiếm và lọc
    });
  }

  // Tải danh sách dịch vụ (giả lập)
  void _loadServices() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Giả lập độ trễ API
    setState(() {
      services = [
        Service(
          id: 1,
          name: 'Cắt - Gội - Xả thư giãn',
          description:
              'Stylist cắt - xả - vuốt sáp tạo kiểu (Không gội & thư giãn)',
          price: 90000,
          duration: 30,
          imageUrl:
              'https://via.placeholder.com/150/FF5733/FFFFFF?text=CatGoiXa',
        ),
        Service(
          id: 2,
          name: 'Cắt gội',
          description: 'Combo Cắt kỹ và Combo Gội Thư giãn',
          price: 120000,
          duration: 45,
          imageUrl: 'https://via.placeholder.com/150/33FF57/FFFFFF?text=CatGoi',
        ),
        Service(
          id: 3,
          name: 'ShineCombo 2',
          description:
              'Combo cắt kỹ, combo gội dưỡng sinh thư giãn có vai gáy, combo cao mặt sáng...',
          price: 199000,
          duration: 55,
          imageUrl:
              'https://via.placeholder.com/150/3357FF/FFFFFF?text=ShineCombo',
        ),
        Service(
          id: 4,
          name: 'Cắt + Gội',
          description:
              'Combo 3 Combo cắt kỹ, Combo chăm sóc da chuyên sâu sáng đẹp tự nhiên bằng thiết bị công...',
          price: 299000,
          duration: 65,
          imageUrl:
              'https://via.placeholder.com/150/FFFF33/000000?text=CatGoiSpa',
        ),
      ];
      _filteredServices =
          services; // Khởi tạo danh sách hiển thị bằng tất cả dịch vụ
      isLoading = false;
    });
  }

  // Hàm áp dụng cả tìm kiếm và lọc
  void _applyFiltersAndSearch() {
    List<Service> tempServices = services;

    // 1. Áp dụng tìm kiếm
    if (_searchQuery.isNotEmpty) {
      tempServices =
          tempServices.where((service) {
            return service.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                service.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // 2. Áp dụng lọc
    if (_selectedFilter == 'price_asc') {
      tempServices.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedFilter == 'price_desc') {
      tempServices.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedFilter == 'duration_asc') {
      tempServices.sort((a, b) => a.duration.compareTo(b.duration));
    } else if (_selectedFilter == 'duration_desc') {
      tempServices.sort((a, b) => b.duration.compareTo(a.duration));
    }

    setState(() {
      _filteredServices = tempServices;
    });
  }

  void _addServiceToCart(Service service) {
    setState(() {
      selectedServices.update(
        service.id,
        (quantity) => quantity + 1,
        ifAbsent: () => 1,
      );
    });
  }

  void _removeServiceFromCart(Service service) {
    setState(() {
      if (selectedServices.containsKey(service.id)) {
        if (selectedServices[service.id]! > 1) {
          selectedServices.update(service.id, (quantity) => quantity - 1);
        } else {
          selectedServices.remove(service.id);
        }
      }
    });
  }

  int get _totalSelectedServicesCount {
    return selectedServices.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double get _totalPrice {
    double total = 0;
    selectedServices.forEach((serviceId, quantity) {
      final service = services.firstWhere((s) => s.id == serviceId);
      total += service.price * quantity;
    });
    return total;
  }

  String _formatCurrency(double amount) {
    return '${amount.toInt().toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} VND';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkBlue,
        title: const Text(
          'Dịch vụ của Salon',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm dịch vụ...',
                prefixIcon: Icon(Icons.search, color: AppColors.secondaryGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.lightGrey.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 10,
                ),
              ),
              style: TextStyle(color: AppColors.primaryDarkBlue),
            ),
          ),
          // Bộ lọc
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Lọc theo:',
                  style: TextStyle(color: AppColors.secondaryGrey),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedFilter,
                  hint: Text(
                    'Chọn bộ lọc',
                    style: TextStyle(color: AppColors.secondaryGrey),
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text('Mặc định'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'price_asc',
                      child: Text('Giá: Thấp đến Cao'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'price_desc',
                      child: Text('Giá: Cao đến Thấp'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'duration_asc',
                      child: Text('Thời lượng: Ngắn nhất'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'duration_desc',
                      child: Text('Thời lượng: Dài nhất'),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue;
                      _applyFiltersAndSearch(); // Áp dụng lại khi bộ lọc thay đổi
                    });
                  },
                  style: TextStyle(color: AppColors.primaryDarkBlue),
                  dropdownColor: AppColors.secondaryWhite,
                  iconEnabledColor: AppColors.primaryDarkBlue,
                ),
              ],
            ),
          ),
          // Danh sách dịch vụ
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredServices.isEmpty
                    ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty || _selectedFilter != null
                            ? 'Không tìm thấy dịch vụ nào phù hợp với tiêu chí của bạn.'
                            : 'Không có dịch vụ nào để hiển thị.',
                        style: TextStyle(color: AppColors.secondaryGrey),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : GridView.builder(
                      padding: const EdgeInsets.all(8.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: _filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = _filteredServices[index];
                        final int quantity = selectedServices[service.id] ?? 0;
                        return Card(
                          color: AppColors.secondaryWhite,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child:
                                    service.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                          child: Image.network(
                                            service.imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Container(
                                                  color: AppColors.lightGrey,
                                                  child: Center(
                                                    child: Text(
                                                      'Lỗi tải ảnh',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors
                                                                .secondaryGrey,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        )
                                        : Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGrey,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(8),
                                                ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Không có ảnh',
                                              style: TextStyle(
                                                color: AppColors.secondaryGrey,
                                              ),
                                            ),
                                          ),
                                        ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: AppColors.secondaryGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${service.duration} phút',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.secondaryGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatCurrency(service.price),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      service.description,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryGrey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (service.id == 3) // For ShineCombo 2
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'MỚI',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    if (service.id == 4) // For Cắt + Gội
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          'Đi kèm thư giãn có vai gáy',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (quantity == 0)
                                          SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed:
                                                  () => _addServiceToCart(
                                                    service,
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.accentBlue,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                              child: const Text(
                                                'Thêm',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 32,
                                                height: 32,
                                                child: ElevatedButton(
                                                  onPressed:
                                                      () =>
                                                          _removeServiceFromCart(
                                                            service,
                                                          ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.lightGrey,
                                                    foregroundColor:
                                                        Colors.black,
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                child: Text(
                                                  '$quantity',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 32,
                                                height: 32,
                                                child: ElevatedButton(
                                                  onPressed:
                                                      () => _addServiceToCart(
                                                        service,
                                                      ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.accentBlue,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: EdgeInsets.zero,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          // Footer với tổng dịch vụ đã chọn và tổng thanh toán
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã chọn $_totalSelectedServicesCount dịch vụ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tổng thanh toán: ${_formatCurrency(_totalPrice)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed:
                        _totalSelectedServicesCount > 0
                            ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Bạn đã chọn $_totalSelectedServicesCount dịch vụ với tổng giá ${_formatCurrency(_totalPrice)}.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _totalSelectedServicesCount > 0
                              ? AppColors.accentBlue
                              : AppColors.lightGrey,
                      foregroundColor:
                          _totalSelectedServicesCount > 0
                              ? Colors.white
                              : Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
