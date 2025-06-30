import 'package:flutter/material.dart';
import 'package:shine_booking_app/models/store_model.dart';
import 'package:shine_booking_app/services/api_store.dart';
import 'package:image_picker/image_picker.dart';

class StoreFormDialog extends StatefulWidget {
  final Store? store;
  final VoidCallback onSaved;
  final Function(String) onError;

  const StoreFormDialog({
    super.key,
    this.store,
    required this.onSaved,
    required this.onError,
  });

  @override
  State<StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<StoreFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController ratingCtrl;
  late final TextEditingController imgCtrl;

  String? selectedCity;
  String? selectedDistrict;
  TimeOfDay? openingTime;
  TimeOfDay? closingTime;

  List<String> cities = [];
  List<String> filteredDistricts = [];

  bool isLoading = false;
  bool isLoadingData = true;

  // Dữ liệu mẫu cho cities và districts (thay thế bằng API thực tế)
  final Map<String, List<String>> cityDistrictMap = {
    'Hà Nội': [
      'Ba Đình',
      'Hoàn Kiếm',
      'Tây Hồ',
      'Long Biên',
      'Cầu Giấy',
      'Đống Đa',
      'Hai Bà Trưng',
      'Hoàng Mai',
      'Thanh Xuân',
      'Nam Từ Liêm',
      'Bắc Từ Liêm',
      'Hà Đông',
      'Sơn Tây',
      'Ba Vì',
      'Chương Mỹ',
    ],
    'TP Hồ Chí Minh': [
      'Quận 1',
      'Quận 2',
      'Quận 3',
      'Quận 4',
      'Quận 5',
      'Quận 6',
      'Quận 7',
      'Quận 8',
      'Quận 9',
      'Quận 10',
      'Quận 11',
      'Quận 12',
      'Thủ Đức',
      'Bình Thạnh',
      'Gò Vấp',
      'Phú Nhuận',
      'Tân Bình',
      'Tân Phú',
      'Bình Tân',
      'Củ Chi',
      'Hóc Môn',
      'Bình Chánh',
      'Nhà Bè',
      'Cần Giờ',
    ],
    'Đà Nẵng': [
      'Hải Châu',
      'Thanh Khê',
      'Sơn Trà',
      'Ngũ Hành Sơn',
      'Liên Chiểu',
      'Cẩm Lệ',
      'Hòa Vang',
    ],
    'Hải Phòng': [
      'Hồng Bàng',
      'Ngô Quyền',
      'Lê Chân',
      'Hải An',
      'Kiến An',
      'Đồ Sơn',
      'Dương Kinh',
    ],
    'Cần Thơ': [
      'Ninh Kiều',
      'Ô Môn',
      'Bình Thuỷ',
      'Cái Răng',
      'Thốt Nốt',
      'Vĩnh Thạnh',
      'Cờ Đỏ',
      'Phong Điền',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    nameCtrl = TextEditingController(text: widget.store?.storeName ?? '');
    phoneCtrl = TextEditingController(text: widget.store?.phoneNumber ?? '');
    descCtrl = TextEditingController(text: widget.store?.description ?? '');
    ratingCtrl = TextEditingController(
      text: widget.store?.averageRating?.toString() ?? '',
    );
    imgCtrl = TextEditingController(text: widget.store?.storeImages ?? '');

    selectedCity = widget.store?.cityProvince;
    selectedDistrict = widget.store?.district;

    // Parse thời gian
    if (widget.store?.openingTime != null) {
      final parts = widget.store!.openingTime!.split(':');
      if (parts.length >= 2) {
        openingTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    if (widget.store?.closingTime != null) {
      final parts = widget.store!.closingTime!.split(':');
      if (parts.length >= 2) {
        closingTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Loại bỏ trùng lặp thành phố
      cities = cityDistrictMap.keys.toSet().toList();

      // Đảm bảo selectedCity hợp lệ
      if (selectedCity != null && !cities.contains(selectedCity)) {
        selectedCity = null;
      }
      if (selectedCity != null) {
        _updateDistricts(selectedCity!);
      } else {
        filteredDistricts = [];
      }
    } catch (e) {
      cities = cityDistrictMap.keys.toSet().toList();
    } finally {
      setState(() => isLoadingData = false);
    }
  }

  void _updateDistricts(String city) {
    setState(() {
      // Loại bỏ trùng lặp quận/huyện
      filteredDistricts = (cityDistrictMap[city] ?? []).toSet().toList();
      // Đảm bảo selectedDistrict hợp lệ
      if (selectedDistrict != null &&
          !filteredDistricts.contains(selectedDistrict)) {
        selectedDistrict = null;
      }
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    descCtrl.dispose();
    ratingCtrl.dispose();
    imgCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chọn ảnh cửa hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceButton(
                        Icons.photo_library,
                        'Thư viện',
                        ImageSource.gallery,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageSourceButton(
                        Icons.camera_alt,
                        'Máy ảnh',
                        ImageSource.camera,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );

    if (result != null) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: result);
      if (picked != null) {
        setState(() {
          imgCtrl.text = picked.path;
        });
      }
    }
  }

  Widget _buildImageSourceButton(
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, source),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFFFF6B35)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isOpening}) async {
    final time = await showTimePicker(
      context: context,
      initialTime:
          isOpening
              ? openingTime ?? const TimeOfDay(hour: 8, minute: 0)
              : closingTime ?? const TimeOfDay(hour: 22, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: const Color(0xFFFF6B35),
              dayPeriodTextColor: const Color(0xFFFF6B35),
              dialHandColor: const Color(0xFFFF6B35),
              dialTextColor: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        if (isOpening) {
          openingTime = time;
        } else {
          closingTime = time;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  String _displayTime(TimeOfDay? time) {
    if (time == null) return 'Chọn giờ';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCity == null) {
      widget.onError('Vui lòng chọn tỉnh/thành phố');
      return;
    }

    if (selectedDistrict == null) {
      widget.onError('Vui lòng chọn quận/huyện');
      return;
    }

    if (openingTime == null || closingTime == null) {
      widget.onError('Vui lòng chọn giờ mở cửa và đóng cửa');
      return;
    }

    setState(() => isLoading = true);

    final data = {
      "storeName": nameCtrl.text.trim(),
      "phoneNumber": phoneCtrl.text.trim(),
      "cityProvince": selectedCity!,
      "district": selectedDistrict!,
      "openingTime": _formatTime(openingTime),
      "closingTime": _formatTime(closingTime),
      "description": descCtrl.text.trim(),
      "averageRating": double.tryParse(ratingCtrl.text) ?? 0.0,
      "storeImages": imgCtrl.text.trim(),
    };

    try {
      if (widget.store == null) {
        await ApiStoreService.addStore(data);
      } else {
        await ApiStoreService.updateStore(widget.store!.storeId!, data);
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      widget.onError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (isLoadingData)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              _buildForm(),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.store == null ? Icons.add_business : Icons.edit_note,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.store == null
                      ? 'Thêm cửa hàng mới'
                      : 'Chỉnh sửa cửa hàng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.store == null
                      ? 'Tạo thông tin cửa hàng mới'
                      : 'Cập nhật thông tin cửa hàng',
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
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Thông tin cơ bản', Icons.info_outline),
              const SizedBox(height: 16),

              _buildTextField(
                controller: nameCtrl,
                label: 'Tên cửa hàng',
                icon: Icons.store,
                validator:
                    (value) =>
                        value?.isEmpty == true
                            ? 'Vui lòng nhập tên cửa hàng'
                            : null,
              ),

              _buildTextField(
                controller: phoneCtrl,
                label: 'Số điện thoại',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value?.isEmpty == true
                            ? 'Vui lòng nhập số điện thoại'
                            : null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Địa chỉ', Icons.location_on),
              const SizedBox(height: 16),

              _buildDropdown(
                value: selectedCity,
                items: cities,
                label: 'Tỉnh/Thành phố',
                icon: Icons.location_city,
                onChanged: (value) {
                  setState(() {
                    selectedCity = value;
                    selectedDistrict = null;
                  });
                  if (value != null) {
                    _updateDistricts(value);
                  }
                },
              ),

              _buildDropdown(
                value: selectedDistrict,
                items: filteredDistricts,
                label: 'Quận/Huyện',
                icon: Icons.map,
                onChanged: (value) => setState(() => selectedDistrict = value),
                enabled: selectedCity != null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Giờ hoạt động', Icons.access_time),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker('Giờ mở cửa', openingTime, true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker('Giờ đóng cửa', closingTime, false),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Thông tin bổ sung', Icons.description),
              const SizedBox(height: 16),

              _buildTextField(
                controller: descCtrl,
                label: 'Mô tả cửa hàng',
                icon: Icons.description,
                maxLines: 3,
                hintText: 'Mô tả ngắn về cửa hàng...',
              ),

              _buildTextField(
                controller: ratingCtrl,
                label: 'Đánh giá trung bình',
                icon: Icons.star,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                hintText: '0.0 - 5.0',
              ),

              _buildImagePicker(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF6B35), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          prefixIcon: Icon(icon, color: const Color(0xFFFF6B35)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?) onChanged,
    bool enabled = true,
  }) {
    // Loại bỏ trùng lặp và đảm bảo value hợp lệ
    final uniqueItems = items.toSet().toList();
    String? safeValue = value;
    if (safeValue != null && !uniqueItems.contains(safeValue)) {
      safeValue = null;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        items:
            uniqueItems
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: enabled ? onChanged : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFFFF6B35) : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
          ),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) => value == null ? 'Vui lòng chọn $label' : null,
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, bool isOpening) {
    return InkWell(
      onTap: () => _pickTime(isOpening: isOpening),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              isOpening ? Icons.login : Icons.logout,
              color: const Color(0xFFFF6B35),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _displayTime(time),
                    style: TextStyle(
                      fontSize: 16,
                      color: time != null ? Colors.black87 : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.access_time, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: isLoading ? null : _pickImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
              ),
              child: Column(
                children: [
                  Icon(
                    imgCtrl.text.isEmpty
                        ? Icons.add_photo_alternate
                        : Icons.photo,
                    color: const Color(0xFFFF6B35),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    imgCtrl.text.isEmpty ? 'Chọn ảnh cửa hàng' : 'Đã chọn ảnh',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (imgCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Nhấn để thay đổi',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: const Text(
                'Hủy',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child:
                  isLoading
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
                      : Text(
                        widget.store == null ? 'Thêm cửa hàng' : 'Cập nhật',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
