import 'package:flutter/material.dart';
import 'package:shine_booking_app/screens/appointment/appointment_confirmation_screen.dart';
import 'package:shine_booking_app/services/api_employee.dart';
import '../../models/store_model.dart';
import '../../models/employee_model.dart'; // Ensure this is the updated model
import '../../services/api_service.dart';
import 'appointment_datetime_screen.dart'; // Navigate to booking date/time screen
import '../../models/store_service_model.dart'; // Import this

class EmployeeSelectionScreen extends StatefulWidget {
  final Store store;
  final StoreService storeService; // Change from ServiceDetail to StoreService

  const EmployeeSelectionScreen({
    super.key,
    required this.store,
    required this.storeService, // Update required field
  });

  @override
  State<EmployeeSelectionScreen> createState() =>
      _EmployeeSelectionScreenState();
}

class _EmployeeSelectionScreenState extends State<EmployeeSelectionScreen> {
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      // Fetch employees for the selected store using the new API endpoint
      // No serviceId parameter needed for this specific endpoint /api/employees/store/{storeId}
      final employees = await ApiEmployeeService.getEmployees(
        storeId: widget.store.storeId!,
      );
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách nhân viên: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chọn Nhân Viên tại ${widget.store.storeName}'),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _employees.isEmpty
              ? const Center(
                child: Text('Không có nhân viên nào cho dịch vụ này.'),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  return _buildEmployeeItem(employee);
                },
              ),
    );
  }

  Widget _buildEmployeeItem(Employee employee) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundImage:
              employee.avatarUrl != null && employee.avatarUrl!.isNotEmpty
                  ? NetworkImage(employee.avatarUrl!) // Use avatarUrl
                  : null,
          child:
              employee.avatarUrl == null || employee.avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
          backgroundColor: const Color(0xFFFF6B35).withOpacity(0.8),
        ),
        title: Text(
          employee.fullName, // Use fullName
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (employee.specialization != null &&
                employee.specialization!.isNotEmpty)
              Text(
                employee
                    .specialization!, // Use specialization for role/position
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            if (employee.averageRating != null) // Keep if backend sends rating
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                  const SizedBox(width: 4),
                  Text(
                    '${double.tryParse(employee.averageRating.toString())?.toStringAsFixed(1) ?? employee.averageRating.toString()} sao',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        // ...existing code...
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (context) => AppointmentDateTimeScreen(
                    store: widget.store,
                    storeService: widget.storeService,
                    employee: employee,
                  ),
            ),
          );
        },
        // ...existing code...
      ),
    );
  }
}
