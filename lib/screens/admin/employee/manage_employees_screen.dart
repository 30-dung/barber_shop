// manage_employees_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle
import 'package:shine_booking_app/screens/admin/employee/employee_form_dialog.dart';
import '../../../models/employee_model.dart';
import '../../../models/store_model.dart'; // Import Store model
import '../../../models/role_model.dart'; // Import Role model
import '../../../services/api_employee.dart';
import '../../../services/api_store_service.dart'; // To fetch stores
// You might also need an ApiRoleService if roles are fetched from a separate API

enum EmployeeFilter { all, active, inactive }

class ManageEmployeesScreen extends StatefulWidget {
  const ManageEmployeesScreen({super.key});

  @override
  State<ManageEmployeesScreen> createState() => _ManageEmployeesScreenState();
}

class _ManageEmployeesScreenState extends State<ManageEmployeesScreen>
    with SingleTickerProviderStateMixin {
  List<Employee> employees = [];
  List<Store> allStores = []; // To hold all available stores
  List<Role> allRoles = []; // To hold all available roles
  bool isLoading = true;
  String? errorMsg;
  String searchQuery = '';
  EmployeeFilter currentFilter = EmployeeFilter.active;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadAllData(); // Load employees, stores, and roles
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      // Fetch employees
      employees = await ApiEmployeeService.getAllEmployees();

      // Fetch all stores (assuming you have an API for this in ApiStoreService)
      final storesData = await ApiStoreService.getStores();
      allStores =
          storesData.map<Store>((json) => Store.fromJson(json)).toList();

      // Fetch all roles (assuming you have an API for this, or mock it if not)
      // For now, let's mock roles or assume they are static if no API is available.
      // If you have an API like ApiRoleService.getAllRoles(), use it here.
      allRoles = [
        Role(roleId: 1, roleName: 'ROLE_ADMIN'),
        Role(roleId: 2, roleName: 'ROLE_CUSTOMER'),
        Role(roleId: 3, roleName: 'ROLE_EMPLOYEE'),
        // Add other roles as needed
      ];

      _animationController.forward(from: 0.0);
    } catch (e) {
      errorMsg = 'Lỗi tải dữ liệu: $e';
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Employee> get filteredEmployees {
    List<Employee> filtered = employees;
    // Filter by status
    switch (currentFilter) {
      case EmployeeFilter.active:
        filtered = filtered.where((emp) => emp.isActive == true).toList();
        break;
      case EmployeeFilter.inactive:
        filtered = filtered.where((emp) => emp.isActive == false).toList();
        break;
      case EmployeeFilter.all:
        break;
    }
    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (emp) =>
                    emp.fullName.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    emp.email.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    emp.employeeCode.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    (emp.phoneNumber ?? '').toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    (emp.specialization ?? '').toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }
    return filtered;
  }

  int get activeEmployeesCount =>
      employees.where((emp) => emp.isActive == true).length;
  int get inactiveEmployeesCount =>
      employees.where((emp) => emp.isActive == false).length;
  int get totalEmployeesCount => employees.length;

  void _showSnackBar(String msg, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
              isError ? const Color(0xFFE74C3C) : const Color(0xFF27AE60),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          elevation: 6,
        ),
      );
    }
  }

  // Helper function to create a JSON map compatible with AdminEmployeeUpdateDTO
  // This is crucial for sending correct data to the backend
  Map<String, dynamic> _createAdminUpdateDtoJson(Employee employee) {
    return {
      "employeeCode": employee.employeeCode,
      "storeId": employee.store.storeId, // Get Store ID
      "roleIds":
          employee.roles.map((r) => r.roleId).toList(), // Get list of Role IDs
      "fullName": employee.fullName,
      "avatarUrl": employee.avatarUrl,
      "email": employee.email,
      "phoneNumber": employee.phoneNumber,
      "gender": employee.gender?.name, // Convert enum to String
      "dateOfBirth":
          employee.dateOfBirth?.toIso8601String().split(
            'T',
          )[0], // Format LocalDate
      "specialization": employee.specialization,
      "baseSalary":
          employee.baseSalary.toDouble(), // Convert BigDecimal to double
      "commissionRate":
          employee.commissionRate.toDouble(), // Convert BigDecimal to double
      "salaryType": employee.salaryType?.name, // Convert enum to String
      "isActive": employee.isActive,
      // Do not include password here for update operation
    };
  }

  // Helper function to create a JSON map compatible with EmployeeRequestDTO for creation
  Map<String, dynamic> _createEmployeeRequestDtoJson(Employee employee) {
    return {
      "employeeCode": employee.employeeCode,
      "storeId": employee.store.storeId,
      "roleIds": employee.roles.map((r) => r.roleId).toList(),
      "fullName": employee.fullName,
      "avatarUrl": employee.avatarUrl,
      "email": employee.email,
      "password": employee.password, // Password is required for creation
      "phoneNumber": employee.phoneNumber,
      "gender": employee.gender?.name,
      "dateOfBirth": employee.dateOfBirth?.toIso8601String().split('T')[0],
      "specialization": employee.specialization,
      "baseSalary": employee.baseSalary.toDouble(),
      "commissionRate": employee.commissionRate.toDouble(),
      "salaryType": employee.salaryType?.name,
    };
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => EmployeeFormDialog(
            availableStores: allStores, // Pass available stores
            availableRoles: allRoles, // Pass available roles
            onSave: (employee) async {
              try {
                // No need to pop here, it's done within _handleSave of dialog
                await ApiEmployeeService.createEmployee(
                  _createEmployeeRequestDtoJson(employee),
                );
                await _loadAllData(); // Refresh all data
                _showSnackBar(
                  'Thêm nhân viên "${employee.fullName}" thành công!',
                );
              } catch (e) {
                _showSnackBar('Lỗi: $e', isError: true);
              }
            },
          ),
    );
  }

  void _showEditEmployeeDialog(Employee employee) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => EmployeeFormDialog(
            employee: employee,
            availableStores: allStores, // Pass available stores
            availableRoles: allRoles, // Pass available roles
            onSave: (updatedEmployee) async {
              try {
                // No need to pop here, it's done within _handleSave of dialog
                if (updatedEmployee.employeeId != null) {
                  await ApiEmployeeService.adminUpdateEmployeeProfile(
                    updatedEmployee.employeeId!,
                    _createAdminUpdateDtoJson(
                      updatedEmployee,
                    ), // Use the helper function here
                  );
                  await _loadAllData(); // Refresh all data
                  _showSnackBar(
                    'Cập nhật nhân viên "${updatedEmployee.fullName}" thành công!',
                  );
                } else {
                  _showSnackBar(
                    'Lỗi: Không tìm thấy ID nhân viên để cập nhật.',
                    isError: true,
                  );
                }
              } catch (e) {
                _showSnackBar('Lỗi: $e', isError: true);
              }
            },
          ),
    );
  }

  Future<void> _toggleEmployeeStatus(Employee employee) async {
    try {
      // Calling the dedicated API for status update
      await ApiEmployeeService.updateEmployeeStatus(
        employee.employeeId!,
        !employee.isActive, // Toggle status
      );

      // CẬP NHẬT TRẠNG THÁI CỤC BỘ TRƯỚC KHI TẢI LẠI TOÀN BỘ DỮ LIỆU
      // Tìm nhân viên trong danh sách hiện tại và cập nhật isActive của nó
      setState(() {
        final index = employees.indexWhere(
          (emp) => emp.employeeId == employee.employeeId,
        );
        if (index != -1) {
          // Tạo một bản sao của đối tượng Employee với trạng thái isActive mới
          // Điều này giúp Flutter nhận diện thay đổi và rebuild widget hiệu quả hơn
          employees[index] = employee.copyWith(
            isActive: !employee.isActive,
          ); // Now employee.copyWith will work
        }
      });

      // Sau đó tải lại toàn bộ dữ liệu (nếu cần thiết để cập nhật các thống kê tổng thể, v.v.)
      // Hoặc chỉ cần gọi setState nếu chỉ thay đổi một mục
      // await _loadAllData(); // Bỏ comment nếu bạn muốn tải lại toàn bộ danh sách

      _showSnackBar(
        '${employee.isActive ? "Vô hiệu hóa" : "Kích hoạt"} nhân viên "${employee.fullName}" thành công!',
      );
    } catch (e) {
      _showSnackBar('Lỗi: $e', isError: true);
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 10,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Color(0xFFE74C3C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Xác nhận xóa',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Bạn có chắc chắn muốn xóa nhân viên "${employee.fullName}"?\n\nHành động này không thể hoàn tác.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE74C3C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Xóa',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        if (employee.employeeId != null) {
          await ApiEmployeeService.deleteEmployee(employee.employeeId!);
          await _loadAllData(); // Refresh all data
          _showSnackBar('Xóa nhân viên thành công!');
        } else {
          _showSnackBar(
            'Lỗi: Không tìm thấy ID nhân viên để xóa.',
            isError: true,
          );
        }
      } catch (e) {
        _showSnackBar('Lỗi: $e', isError: true);
      }
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            'Lọc theo:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'Đang hoạt động',
                    EmployeeFilter.active,
                    const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Không hoạt động',
                    EmployeeFilter.inactive,
                    const Color(0xFFE74C3C),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Tất cả',
                    EmployeeFilter.all,
                    const Color(0xFF3498DB),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, EmployeeFilter filter, Color color) {
    final isSelected = currentFilter == filter;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          currentFilter = filter;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(color: color, width: 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showEditEmployeeDialog(employee),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B35),
                            const Color(0xFFFF6B35).withOpacity(0.8),
                          ],
                        ),
                      ),
                      child:
                          employee.avatarUrl != null &&
                                  employee.avatarUrl!.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  employee.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => Center(
                                        child: Text(
                                          employee.fullName.isNotEmpty
                                              ? employee.fullName[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                ),
                              )
                              : Center(
                                child: Text(
                                  employee.fullName.isNotEmpty
                                      ? employee.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(width: 16),
                    // Employee Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  employee.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      employee.isActive
                                          ? const Color(
                                            0xFF27AE60,
                                          ).withOpacity(0.1)
                                          : const Color(
                                            0xFFE74C3C,
                                          ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  employee.isActive ? 'Hoạt động' : 'Tạm ngưng',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        employee.isActive
                                            ? const Color(0xFF27AE60)
                                            : const Color(0xFFE74C3C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mã NV: ${employee.employeeCode}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            employee.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Employee Details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            employee.phoneNumber ?? 'Chưa có SĐT',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.store, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              employee.store.storeName ?? 'Chưa rõ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      if (employee.specialization != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.work, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                employee.specialization!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              employee.roles
                                  .map(
                                    (r) => r.roleName.replaceFirst('ROLE_', ''),
                                  )
                                  .join(', '),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _toggleEmployeeStatus(employee),
                        icon: Icon(
                          employee.isActive ? Icons.pause : Icons.play_arrow,
                          size: 18,
                        ),
                        label: Text(
                          employee.isActive ? 'Tạm ngưng' : 'Kích hoạt',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              employee.isActive
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFF27AE60),
                          side: BorderSide(
                            color:
                                employee.isActive
                                    ? const Color(0xFFE74C3C)
                                    : const Color(0xFF27AE60),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditEmployeeDialog(employee),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          'Chỉnh sửa',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delete Button
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      color: const Color(0xFFE74C3C),
                      onPressed: () => _deleteEmployee(employee),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for action buttons (like delete) to maintain consistent style
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Quản lý nhân viên',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF2C3E50),
          statusBarIconBrightness: Brightness.light,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadAllData, // Changed to _loadAllData to refresh all
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                ),
              )
              : errorMsg != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Color(0xFFE74C3C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      errorMsg!,
                      style: const TextStyle(
                        color: Color(0xFFE74C3C),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadAllData, // Changed to _loadAllData
                      icon: const Icon(Icons.refresh_rounded),
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
              )
              : Column(
                children: [
                  // Statistics Section
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Tổng nhân viên',
                                totalEmployeesCount.toString(),
                                const Color(0xFF3498DB),
                                Icons.people,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Đang hoạt động',
                                activeEmployeesCount.toString(),
                                const Color(0xFF27AE60),
                                Icons.check_circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Tạm ngưng',
                                inactiveEmployeesCount.toString(),
                                const Color(0xFFE74C3C),
                                Icons.pause_circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Search Bar
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE9ECEF)),
                          ),
                          child: TextField(
                            onChanged:
                                (value) => setState(() => searchQuery = value),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm nhân viên...',
                              hintStyle: TextStyle(
                                color: Color(0xFF6C757D),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Color(0xFFFF6B35),
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter Section
                  _buildFilterChips(),
                  // Employees List
                  Expanded(
                    child:
                        filteredEmployees.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.people_alt_rounded,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'Chưa có nhân viên nào'
                                        : 'Không tìm thấy nhân viên',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    searchQuery.isEmpty
                                        ? 'Hãy thêm nhân viên đầu tiên của bạn'
                                        : 'Thử tìm kiếm với từ khóa khác',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: filteredEmployees.length,
                              itemBuilder: (context, index) {
                                return _buildEmployeeCard(
                                  filteredEmployees[index],
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEmployeeDialog,
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm nhân viên',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
