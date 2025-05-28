import 'package:flutter/material.dart';
import 'package:barber_app/models/product.dart';
import 'package:barber_app/utils/colors.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<Product> products = [];
  bool isLoading = false;
  Map<int, int> selectedProducts = {}; // productId: quantity

  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFiltersAndSearch();
    });
  }

  void _loadProducts() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      products = [
        Product(
          id: 1,
          name: 'Sáp vuốt tóc',
          description: 'Tạo kiểu tóc nam, giữ nếp lâu.',
          price: 120000,
          imageUrl: 'https://via.placeholder.com/150/FF5733/FFFFFF?text=Sap',
        ),
        Product(
          id: 2,
          name: 'Gôm xịt tóc',
          description: 'Giữ nếp tóc tự nhiên, không bết dính.',
          price: 90000,
          imageUrl: 'https://via.placeholder.com/150/33FF57/FFFFFF?text=Gom',
        ),
        Product(
          id: 3,
          name: 'Dầu gội đầu',
          description: 'Làm sạch tóc, dưỡng tóc mềm mượt.',
          price: 150000,
          imageUrl:
              'https://via.placeholder.com/150/3357FF/FFFFFF?text=Shampoo',
        ),
        Product(
          id: 4,
          name: 'Lược tạo kiểu',
          description: 'Lược chuyên dụng cho tóc nam.',
          price: 50000,
          imageUrl: 'https://via.placeholder.com/150/FFFF33/000000?text=Luoc',
        ),
      ];
      _filteredProducts = products;
      isLoading = false;
    });
  }

  void _applyFiltersAndSearch() {
    List<Product> tempProducts = products;

    // Tìm kiếm
    if (_searchQuery.isNotEmpty) {
      tempProducts =
          tempProducts.where((product) {
            return product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Lọc
    if (_selectedFilter == 'price_asc') {
      tempProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedFilter == 'price_desc') {
      tempProducts.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filteredProducts = tempProducts;
    });
  }

  void _addProductToCart(Product product) {
    setState(() {
      selectedProducts.update(
        product.id,
        (quantity) => quantity + 1,
        ifAbsent: () => 1,
      );
    });
  }

  void _removeProductFromCart(Product product) {
    setState(() {
      if (selectedProducts.containsKey(product.id)) {
        if (selectedProducts[product.id]! > 1) {
          selectedProducts.update(product.id, (quantity) => quantity - 1);
        } else {
          selectedProducts.remove(product.id);
        }
      }
    });
  }

  int get _totalSelectedProductsCount {
    return selectedProducts.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double get _totalPrice {
    double total = 0;
    selectedProducts.forEach((productId, quantity) {
      final product = products.firstWhere((p) => p.id == productId);
      total += product.price * quantity;
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
          'Cửa hàng sản phẩm',
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
                hintText: 'Tìm kiếm sản phẩm...',
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
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedFilter = newValue;
                      _applyFiltersAndSearch();
                    });
                  },
                  style: TextStyle(color: AppColors.primaryDarkBlue),
                  dropdownColor: AppColors.secondaryWhite,
                  iconEnabledColor: AppColors.primaryDarkBlue,
                ),
              ],
            ),
          ),
          // Danh sách sản phẩm
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredProducts.isEmpty
                    ? Center(
                      child: Text(
                        _searchQuery.isNotEmpty || _selectedFilter != null
                            ? 'Không tìm thấy sản phẩm nào phù hợp.'
                            : 'Không có sản phẩm nào để hiển thị.',
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
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        final int quantity = selectedProducts[product.id] ?? 0;
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
                                    product.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(8),
                                              ),
                                          child: Image.network(
                                            product.imageUrl,
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
                                      product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      product.description,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryGrey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatCurrency(product.price.toDouble()),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentBlue,
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
                                                  () => _addProductToCart(
                                                    product,
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
                                                          _removeProductFromCart(
                                                            product,
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
                                                      () => _addProductToCart(
                                                        product,
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
          // Footer với tổng sản phẩm đã chọn và tổng thanh toán
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
                        'Đã chọn $_totalSelectedProductsCount sản phẩm',
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
                        _totalSelectedProductsCount > 0
                            ? () {
                              final cartProducts =
                                  products
                                      .where(
                                        (p) =>
                                            selectedProducts.containsKey(p.id),
                                      )
                                      .toList();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CartScreen(
                                        cartProducts: cartProducts,
                                        quantities: Map<int, int>.from(
                                          selectedProducts,
                                        ),
                                      ),
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _totalSelectedProductsCount > 0
                              ? AppColors.accentBlue
                              : AppColors.lightGrey,
                      foregroundColor:
                          _totalSelectedProductsCount > 0
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
