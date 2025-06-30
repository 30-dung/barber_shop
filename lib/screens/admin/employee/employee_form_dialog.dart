// employee_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/role_model.dart';
import 'package:shine_booking_app/models/store_model.dart';
import 'package:decimal/decimal.dart'; // Ensure this is correctly configured or remove if not needed for simple parsing

class EmployeeFormDialog extends StatefulWidget {
  final Employee? employee;
  final Function(Employee employee) onSave;
  // Make these required as they are crucial data for the form
  final List<Store> availableStores;
  final List<Role> availableRoles;

  const EmployeeFormDialog({
    super.key,
    this.employee,
    required this.onSave,
    required this.availableStores, // Now required
    required this.availableRoles, // Now required
  });

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _specializationController;
  late TextEditingController _baseSalaryController;
  late TextEditingController _commissionRateController;
  late TextEditingController _employeeCodeController;

  // Form state
  Store? _selectedStore;
  Gender? _selectedGender;
  SalaryType? _selectedSalaryType;
  List<Role> _selectedRoles = [];
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _formError;

  // Focus nodes for better UX
  final FocusNode _employeeCodeFocus = FocusNode();
  final FocusNode _fullNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _specializationFocus = FocusNode();
  final FocusNode _baseSalaryFocus = FocusNode();
  final FocusNode _commissionRateFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeControllers(); // Now uses widget.availableStores and widget.availableRoles directly
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeControllers() {
    final emp = widget.employee;

    _fullNameController = TextEditingController(text: emp?.fullName ?? '');
    _emailController = TextEditingController(text: emp?.email ?? '');
    _passwordController = TextEditingController(
      text: '',
    ); // Always empty for edit or new
    _phoneController = TextEditingController(text: emp?.phoneNumber ?? '');
    _specializationController = TextEditingController(
      text: emp?.specialization ?? '',
    );
    _baseSalaryController = TextEditingController(
      text:
          emp?.baseSalary != null
              ? _formatBigDecimalToString(emp!.baseSalary)
              : '0',
    );
    _commissionRateController = TextEditingController(
      text:
          emp?.commissionRate != null
              ? _formatBigDecimalToString(emp!.commissionRate)
              : '0',
    );
    _employeeCodeController = TextEditingController(
      text: emp?.employeeCode ?? '',
    );

    // Initialize selected items based on employee data and available lists
    _selectedStore = widget.availableStores.firstWhere(
      (store) => store.storeId == emp?.store.storeId,
      orElse:
          () => null!, // Using null! cautiously, ensure your data is consistent
    );

    _selectedGender = emp?.gender;
    _selectedSalaryType = emp?.salaryType;
    _selectedRoles =
        widget.availableRoles
            .where(
              (role) =>
                  emp?.roles.any((empRole) => empRole.roleId == role.roleId) ??
                  false,
            )
            .toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _disposeControllers();
    _disposeFocusNodes();
    super.dispose();
  }

  void _disposeControllers() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _specializationController.dispose();
    _baseSalaryController.dispose();
    _commissionRateController.dispose();
    _employeeCodeController.dispose();
  }

  void _disposeFocusNodes() {
    _employeeCodeFocus.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    _specializationFocus.dispose();
    _baseSalaryFocus.dispose();
    _commissionRateFocus.dispose();
  }

  // Validators
  String? _validateEmployeeCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mã nhân viên không được để trống';
    }
    if (value.trim().length < 3) {
      return 'Mã nhân viên phải có ít nhất 3 ký tự';
    }
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(value.trim())) {
      return 'Mã nhân viên chỉ được chứa chữ, số, dấu gạch dưới và gạch ngang';
    }
    return null;
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Họ và tên không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên phải có ít nhất 2 ký tự';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(value.trim())) {
      return 'Họ và tên chỉ được chứa chữ cái và khoảng trắng';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (widget.employee == null) {
      // Creating new employee
      if (value == null || value.isEmpty) {
        return 'Mật khẩu không được để trống';
      }
      if (value.length < 6) {
        return 'Mật khẩu phải có ít nhất 6 ký tự';
      }
    } else {
      // Editing existing employee - password is optional
      if (value != null && value.isNotEmpty && value.length < 6) {
        return 'Mật khẩu phải có ít nhất 6 ký tự';
      }
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      if (!RegExp(r'^[0-9+\-\s\(\)]+$').hasMatch(value.trim())) {
        return 'Số điện thoại không đúng định dạng';
      }
      final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length < 10 || digitsOnly.length > 11) {
        return 'Số điện thoại phải có 10-11 chữ số';
      }
    }
    return null;
  }

  String? _validateSalary(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName phải là số hợp lệ';
    }
    if (number < 0) {
      return '$fieldName không được âm';
    }
    return null;
  }

  bool _validateRoles() {
    return _selectedRoles.isNotEmpty;
  }

  // Helper để định dạng BigDecimal thành chuỗi (không dấu phẩy)
  String _formatBigDecimalToString(BigDecimal value) {
    try {
      // Use toBigInt() for integer values if BigDecimal has this method and it's appropriate
      // Otherwise, check for .0 suffix and remove it for display
      String stringValue = value.toString();
      if (stringValue.endsWith('.0') || stringValue.endsWith('.00')) {
        // Remove trailing .0 or .00 if present
        return stringValue.substring(0, stringValue.indexOf('.'));
      }
      return stringValue;
    } catch (e) {
      print('Error formatting BigDecimal to string: $e');
      return value.toString(); // Fallback
    }
  }

  void _handleSave() async {
    setState(() {
      _formError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_validateRoles()) {
      setState(() {
        _formError = 'Vui lòng chọn ít nhất một vai trò';
      });
      return;
    }

    if (_selectedStore == null) {
      setState(() {
        _formError = 'Vui lòng chọn cửa hàng';
      });
      return;
    }

    if (_selectedSalaryType == null) {
      setState(() {
        _formError = 'Vui lòng chọn loại lương';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseSalary = BigDecimal(_baseSalaryController.text.trim());
      final commissionRate = BigDecimal(_commissionRateController.text.trim());
      final password = _passwordController.text; // Only used for new employee

      final newEmployee = Employee(
        employeeId: widget.employee?.employeeId,
        employeeCode: _employeeCodeController.text.trim(),
        store: _selectedStore!,
        roles: _selectedRoles,
        fullName: _fullNameController.text.trim(),
        avatarUrl: widget.employee?.avatarUrl,
        email: _emailController.text.trim(),
        password:
            widget.employee == null
                ? password
                : '', // Pass password only if creating new
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        gender: _selectedGender,
        dateOfBirth:
            widget
                .employee
                ?.dateOfBirth, // Keep existing or provide date picker
        specialization:
            _specializationController.text.trim().isEmpty
                ? null
                : _specializationController.text.trim(),
        baseSalary: baseSalary,
        commissionRate: commissionRate,
        salaryType: _selectedSalaryType!,
        isActive: widget.employee?.isActive ?? true,
        averageRating:
            widget.employee?.averageRating ?? const BigDecimal('0.00'),
        totalReviews: widget.employee?.totalReviews ?? 0,
        createdAt: widget.employee?.createdAt,
        updatedAt: DateTime.now(),
      );

      await widget.onSave(newEmployee);
      // The pop is now handled by the parent screen after successful save.
      // This allows the parent to show a snackbar and then pop the dialog.
    } catch (e) {
      setState(() {
        _formError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines = 1,
    String? helperText,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        textInputAction:
            nextFocus != null ? TextInputAction.next : TextInputAction.done,
        onFieldSubmitted: (_) {
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          }
        },
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required List<T> items,
    required String Function(T) getDisplayText,
    required void Function(T?) onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(getDisplayText(item)),
              );
            }).toList(),
        onChanged: onChanged,
        validator:
            isRequired
                ? (value) => value == null ? 'Vui lòng chọn $label' : null
                : null,
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vai trò *',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  widget.availableRoles.map((role) {
                    // Use widget.availableRoles
                    final isSelected = _selectedRoles.any(
                      (r) => r.roleId == role.roleId,
                    );
                    return FilterChip(
                      label: Text(
                        role.roleName.replaceFirst('ROLE_', ''),
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF6B35),
                      backgroundColor: Colors.white,
                      elevation: isSelected ? 2 : 0,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedRoles.add(role);
                          } else {
                            _selectedRoles.removeWhere(
                              (r) => r.roleId == role.roleId,
                            );
                          }
                          _formError =
                              null; // Clear error when user makes selection
                        });
                      },
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 16,
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
            maxWidth: 600,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(child: _buildContent()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              widget.employee == null ? Icons.person_add : Icons.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.employee == null
                  ? 'Thêm nhân viên mới'
                  : 'Chỉnh sửa nhân viên',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_formError != null) _buildErrorMessage(),

            // Basic Information Section
            _buildSectionTitle('Thông tin cơ bản'),
            _buildTextField(
              controller: _employeeCodeController,
              label: 'Mã nhân viên *',
              validator: _validateEmployeeCode,
              focusNode: _employeeCodeFocus,
              nextFocus: _fullNameFocus,
              enabled: widget.employee == null, // Enable only for new employee
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                LengthLimitingTextInputFormatter(20),
              ],
            ),

            _buildTextField(
              controller: _fullNameController,
              label: 'Họ và tên *',
              validator: _validateFullName,
              focusNode: _fullNameFocus,
              nextFocus: _emailFocus,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ỹ\s]')),
                LengthLimitingTextInputFormatter(50),
              ],
            ),

            _buildTextField(
              controller: _emailController,
              label: 'Email *',
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              focusNode: _emailFocus,
              nextFocus: _passwordFocus,
            ),

            if (widget.employee ==
                null) // Only show password field for new employee
              _buildTextField(
                controller: _passwordController,
                label: 'Mật khẩu *',
                validator: _validatePassword,
                obscureText: !_isPasswordVisible,
                focusNode: _passwordFocus,
                nextFocus: _phoneFocus,
                helperText: 'Tối thiểu 6 ký tự',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed:
                      () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                ),
              ),

            _buildTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              validator: _validatePhone,
              keyboardType: TextInputType.phone,
              focusNode: _phoneFocus,
              nextFocus: _specializationFocus,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                LengthLimitingTextInputFormatter(15),
              ],
            ),

            _buildTextField(
              controller: _specializationController,
              label: 'Chuyên môn',
              validator: (value) => null,
              focusNode: _specializationFocus,
              nextFocus: _baseSalaryFocus,
              maxLines: 2,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
            ),

            const SizedBox(height: 16),

            // Work Information Section
            _buildSectionTitle('Thông tin công việc'),

            _buildDropdown<Store>(
              value: _selectedStore,
              label: 'Cửa hàng *',
              items: widget.availableStores, // Use widget.availableStores
              getDisplayText: (store) => store.storeName ?? 'Unknown Store',
              onChanged: (value) => setState(() => _selectedStore = value),
              isRequired: true,
            ),

            _buildDropdown<Gender>(
              value: _selectedGender,
              label: 'Giới tính',
              items: Gender.values,
              getDisplayText: (gender) => _getGenderDisplayText(gender),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),

            _buildDropdown<SalaryType>(
              value: _selectedSalaryType,
              label: 'Loại lương *',
              items: SalaryType.values,
              getDisplayText: (type) => _getSalaryTypeDisplayText(type),
              onChanged: (value) => setState(() => _selectedSalaryType = value),
              isRequired: true,
            ),

            _buildTextField(
              controller: _baseSalaryController,
              label: 'Lương cơ bản (VNĐ) *',
              validator: (value) => _validateSalary(value, 'Lương cơ bản'),
              keyboardType: TextInputType.number,
              focusNode: _baseSalaryFocus,
              nextFocus: _commissionRateFocus,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
            ),

            _buildTextField(
              controller: _commissionRateController,
              label: 'Tỷ lệ hoa hồng (%) *',
              validator: (value) => _validateSalary(value, 'Tỷ lệ hoa hồng'),
              keyboardType: TextInputType.number,
              focusNode: _commissionRateFocus,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                LengthLimitingTextInputFormatter(5),
              ],
            ),

            const SizedBox(height: 16),

            // Roles Section
            _buildSectionTitle('Phân quyền'),
            _buildRoleSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _formError!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.employee == null ? Icons.add : Icons.save,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.employee == null ? 'Thêm' : 'Cập nhật',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  String _getGenderDisplayText(Gender gender) {
    switch (gender) {
      case Gender.MALE:
        return 'Nam';
      case Gender.FEMALE:
        return 'Nữ';
      case Gender.OTHER:
        return 'Khác';
      default:
        return gender.toString().split('.').last;
    }
  }

  String _getSalaryTypeDisplayText(SalaryType type) {
    switch (type) {
      case SalaryType.FIXED:
        return 'Cố định';
      case SalaryType.COMMISSION:
        return 'Hoa hồng';
      case SalaryType.MIXED:
        return 'Hỗn hợp';
      default: // Fallback for any other types
        return type.toString().split('.').last;
    }
  }
}
