// lib/screens/employee/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/services/api_employee.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import 'package:intl/intl.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen>
    with TickerProviderStateMixin {
  Employee? _employee;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isEditing = false;
  bool _isSaving = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Text Controllers for editable fields
  late TextEditingController _fullNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _specializationController;
  late TextEditingController _emailController;
  late TextEditingController
  _avatarUrlController; // Thêm controller cho avatarUrl

  // For dropdowns
  Gender? _selectedGender;
  DateTime? _selectedDateOfBirth;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProfileData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _specializationController.dispose();
    _emailController.dispose();
    _avatarUrlController.dispose(); // Dispose controller
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Không tìm thấy token. Vui lòng đăng nhập lại.');
      }

      _employee = await ApiEmployeeService.getEmployeeDetails(token);

      if (_employee != null) {
        _initializeControllers();
        _animationController.forward();
      } else {
        _errorMessage = 'Không tìm thấy dữ liệu hồ sơ.';
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải hồ sơ: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(text: _employee!.fullName);
    _phoneNumberController = TextEditingController(
      text: _employee!.phoneNumber ?? '',
    );
    _specializationController = TextEditingController(
      text: _employee!.specialization ?? '',
    );
    _emailController = TextEditingController(text: _employee!.email);
    _avatarUrlController = TextEditingController(
      text: _employee!.avatarUrl ?? '',
    ); // Khởi tạo controller avatar
    _selectedGender = _employee!.gender;
    _selectedDateOfBirth = _employee!.dateOfBirth;
  }

  Future<void> _saveProfileData() async {
    if (_employee == null || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final Map<String, dynamic> updateData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(), // Bỏ comment để gửi email đi
        'phoneNumber':
            _phoneNumberController.text.trim().isEmpty
                ? null
                : _phoneNumberController.text.trim(),
        'gender': _selectedGender?.name,
        'dateOfBirth': _selectedDateOfBirth?.toIso8601String().split('T')[0],
        'specialization':
            _specializationController.text.trim().isEmpty
                ? null
                : _specializationController.text.trim(),
        'avatarUrl':
            _avatarUrlController.text.trim().isEmpty
                ? null
                : _avatarUrlController.text
                    .trim(), // Thêm avatarUrl vào dữ liệu cập nhật
      };

      await ApiEmployeeService.updateEmployeeProfile(updateData);
      await _loadProfileData(); // Tải lại dữ liệu để cập nhật UI
      _showSnackBar('Cập nhật hồ sơ thành công!', isSuccess: true);

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      _showSnackBar('Lỗi cập nhật hồ sơ: $e', isError: true);
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _initializeControllers(); // Khôi phục lại dữ liệu ban đầu
    });
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline
                    : (isSuccess
                        ? Icons.check_circle_outline
                        : Icons.info_outline),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
              isError
                  ? const Color(0xFFE53E3E)
                  : (isSuccess
                      ? const Color(0xFF38A169)
                      : const Color(0xFF3182CE)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFFFF6B35)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.grey[50], body: _buildBody());
  }

  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              ),
            ),
          )
        else if (_errorMessage != null)
          SliverFillRemaining(child: _buildErrorState())
        else if (_employee == null)
          const SliverFillRemaining(
            child: Center(child: Text('Không có dữ liệu hồ sơ để hiển thị.')),
          )
        else
          _buildContent(),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
            ),
          ),
        ),
      ),
      actions: [
        if (_isEditing) ...[
          IconButton(
            icon:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfileData,
            tooltip: 'Lưu hồ sơ',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isSaving ? null : _cancelEditing,
            tooltip: 'Hủy chỉnh sửa',
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => setState(() => _isEditing = true),
            tooltip: 'Chỉnh sửa hồ sơ',
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 16),
                  _buildWorkInfoSection(),
                  const SizedBox(height: 16),
                  _buildSecuritySection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700], fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadProfileData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFF6B35), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _employee!.avatarUrl != null &&
                              _employee!.avatarUrl!.isNotEmpty
                          ? NetworkImage(_employee!.avatarUrl!)
                          : null,
                  backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
                  child:
                      _employee!.avatarUrl == null ||
                              _employee!.avatarUrl!.isEmpty
                          ? Text(
                            _employee!.fullName.isNotEmpty
                                ? _employee!.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          )
                          : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _employee!.isActive ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    _employee!.isActive ? Icons.check : Icons.pause,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _employee!.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          // Email không còn hiển thị ở đây vì đã có trường thông tin riêng
          // Text(
          //   _employee!.email,
          //   style: TextStyle(
          //     fontSize: 16,
          //     color: Colors.grey[600],
          //   ),
          // ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _employee!.roles
                  .map((r) => r.roleName.replaceFirst('ROLE_', ''))
                  .join(', '),
              style: const TextStyle(
                color: Color(0xFFFF6B35),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLines,
    bool readOnly = false, // Thêm thuộc tính readOnly
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly || !_isEditing, // Sử dụng thuộc tính readOnly
            maxLines: maxLines ?? 1,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFFFF6B35), size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF6B35),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor:
                  (readOnly || !_isEditing)
                      ? Colors.grey[50]
                      : Colors.white, // Điều chỉnh màu nền
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              color:
                  (readOnly || !_isEditing) ? Colors.grey[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFFF6B35), size: 18),
          ),
          const SizedBox(width: 16),
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
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giới tính',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Gender>(
            value: _selectedGender,
            items:
                Gender.values
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender.displayName),
                      ),
                    )
                    .toList(),
            onChanged:
                _isEditing
                    ? (value) => setState(() => _selectedGender = value)
                    : null,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.person_outline,
                color: Color(0xFFFF6B35),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFFF6B35),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: _isEditing ? Colors.white : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày sinh',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _isEditing ? () => _selectDateOfBirth(context) : null,
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFF6B35),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF6B35),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                _selectedDateOfBirth == null
                    ? 'Chọn ngày sinh'
                    : DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!),
                style: TextStyle(
                  fontSize: 16,
                  color:
                      _selectedDateOfBirth == null
                          ? Colors.grey[600]
                          : Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildInfoCard(
      title: 'Thông tin cá nhân',
      icon: Icons.person_outline,
      children: [
        _buildEditableField(
          icon: Icons.badge_outlined,
          label: 'Họ và tên',
          controller: _fullNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Họ và tên không được để trống';
            }
            return null;
          },
        ),
        _buildGenderField(),
        _buildDateField(),
        _buildEditableField(
          icon: Icons.phone_outlined,
          label: 'Số điện thoại',
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                !RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
              return 'Số điện thoại không hợp lệ';
            }
            return null;
          },
        ),
        _buildEditableField(
          icon: Icons.email_outlined,
          label: 'Email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: true, // Email không được sửa
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email không được để trống';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        // Thêm trường cập nhật Avatar URL
        _buildEditableField(
          icon: Icons.link_outlined,
          label: 'Đường dẫn ảnh đại diện (URL)',
          controller: _avatarUrlController,
          keyboardType: TextInputType.url,
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                !Uri.tryParse(value)!.hasAbsolutePath == true) {
              return 'Đường dẫn ảnh không hợp lệ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWorkInfoSection() {
    return _buildInfoCard(
      title: 'Thông tin công việc',
      icon: Icons.work_outline,
      children: [
        _buildReadOnlyField(
          icon: Icons.vpn_key_outlined,
          label: 'Mã nhân viên',
          value: _employee!.employeeCode,
        ),
        _buildReadOnlyField(
          icon: Icons.store_outlined,
          label: 'Cửa hàng',
          value: _employee!.store.storeName as String,
        ),
        _buildEditableField(
          icon: Icons.school_outlined,
          label: 'Chuyên môn',
          controller: _specializationController,
          maxLines: 2,
        ),
        _buildReadOnlyField(
          icon: Icons.star_outline,
          label: 'Đánh giá trung bình',
          value: _employee!.averageRating.toDouble().toStringAsFixed(2),
          valueColor: Colors.amber[700],
        ),
        _buildReadOnlyField(
          icon: Icons.reviews_outlined,
          label: 'Tổng số đánh giá',
          value: _employee!.totalReviews.toString(),
        ),
        _buildReadOnlyField(
          icon: Icons.attach_money_outlined,
          label: 'Loại lương',
          value: _employee!.salaryType.displayName,
        ),
        _buildReadOnlyField(
          icon: Icons.money,
          label: 'Lương cơ bản',
          value:
              '${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(_employee!.baseSalary.toDouble())}',
        ),
        _buildReadOnlyField(
          icon: Icons.percent_outlined,
          label: 'Tỷ lệ hoa hồng',
          value: '${_employee!.commissionRate.toDouble().toStringAsFixed(2)}%',
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildInfoCard(
      title: 'Bảo mật & Trạng thái',
      icon: Icons.security_outlined,
      children: [
        _buildReadOnlyField(
          icon: Icons.lock_outline,
          label: 'Mật khẩu',
          value: '************',
        ),
        _buildReadOnlyField(
          icon: Icons.verified_user_outlined,
          label: 'Trạng thái tài khoản',
          value: _employee!.isActive ? 'Đang hoạt động' : 'Đã vô hiệu hóa',
          valueColor: _employee!.isActive ? Colors.green[700] : Colors.red[700],
        ),
        _buildReadOnlyField(
          icon: Icons.calendar_today_outlined,
          label: 'Ngày tạo tài khoản',
          value:
              _employee!.createdAt != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(_employee!.createdAt!)
                  : 'N/A',
        ),
        _buildReadOnlyField(
          icon: Icons.update_outlined,
          label: 'Cập nhật lần cuối',
          value:
              _employee!.updatedAt != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(_employee!.updatedAt!)
                  : 'N/A',
        ),
      ],
    );
  }
}
