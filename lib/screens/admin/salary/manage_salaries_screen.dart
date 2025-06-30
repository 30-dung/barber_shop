import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/payroll_summary_model.dart';
import 'package:shine_booking_app/screens/employee/salary_screen.dart';
import 'package:shine_booking_app/services/api_employee.dart';
import 'package:shine_booking_app/services/api_salary.dart';

class AdminSalaryManagementScreen extends StatefulWidget {
  const AdminSalaryManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdminSalaryManagementScreen> createState() =>
      _AdminSalaryManagementScreenState();
}

class _AdminSalaryManagementScreenState
    extends State<AdminSalaryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Employee> _employees = [];
  List<PayrollSummary> _monthlyPayrolls = [];
  String _selectedMonth = DateFormat('MM').format(DateTime.now());
  String _selectedYear = DateFormat('yyyy').format(DateTime.now());

  final _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );
  final _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      await _loadEmployees();
      await _loadMonthlyPayrolls();
    } catch (e) {
      _showErrorSnackBar('Lỗi tải dữ liệu ban đầu: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await ApiEmployeeService.getAllEmployees();
      if (mounted) {
        setState(() => _employees = employees);
      }
    } catch (e) {
      throw Exception('Không thể tải danh sách nhân viên: $e');
    }
  }

  Future<void> _loadMonthlyPayrolls() async {
    setState(() => _isLoading = true);
    try {
      final payrolls = await ApiSalaryService.getAllPayrollsForMonth(
        year: int.parse(_selectedYear),
        month: int.parse(_selectedMonth),
      );
      if (mounted) {
        setState(() => _monthlyPayrolls = payrolls);
      }
    } catch (e) {
      print('Error loading all monthly payrolls for admin: $e');
      if (mounted) {
        _showErrorSnackBar('Lỗi tải bảng lương tháng (Admin): ${e.toString()}');
      }
      setState(() => _monthlyPayrolls = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _processUnprocessedAppointments() async {
    setState(() => _isLoading = true);
    try {
      await ApiSalaryService.processUnprocessedAppointments();
      _showSuccessSnackBar('Đã xử lý tất cả appointments chưa được tính lương');
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadMonthlyPayrolls();
    } catch (e) {
      _showErrorSnackBar('Lỗi xử lý appointments: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePayroll(Employee employee, int month, int year) async {
    setState(() => _isLoading = true);
    try {
      await ApiSalaryService.generatePayroll(
        employeeId: employee.employeeId!,
        year: year,
        month: month,
      );
      _showSuccessSnackBar(
        'Đã tạo bảng lương cho ${employee.fullName} thành công',
      );
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadMonthlyPayrolls();
    } catch (e) {
      _showErrorSnackBar('Lỗi tạo bảng lương: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePayrollForAllEmployees() async {
    setState(() => _isLoading = true);
    try {
      int successCount = 0;
      int errorCount = 0;

      for (Employee employee in _employees) {
        try {
          await ApiSalaryService.generatePayroll(
            employeeId: employee.employeeId!,
            year: int.parse(_selectedYear),
            month: int.parse(_selectedMonth),
          );
          successCount++;
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          errorCount++;
          print('Error generating payroll for ${employee.fullName}: $e');
        }
      }

      if (successCount > 0) {
        _showSuccessSnackBar(
          'Đã tạo bảng lương cho $successCount nhân viên' +
              (errorCount > 0 ? ' ($errorCount lỗi)' : ''),
        );
        await Future.delayed(const Duration(milliseconds: 1000));
        await _loadMonthlyPayrolls();
      } else {
        _showErrorSnackBar('Không thể tạo bảng lương cho nhân viên nào');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi tạo bảng lương: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approvePayroll(int payrollId) async {
    setState(() => _isLoading = true);
    try {
      await ApiSalaryService.approvePayroll(payrollId);
      _showSuccessSnackBar('Đã phê duyệt bảng lương');
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadMonthlyPayrolls();
    } catch (e) {
      _showErrorSnackBar('Lỗi phê duyệt: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsPaid(int payrollId) async {
    setState(() => _isLoading = true);
    try {
      await ApiSalaryService.markAsPaid(payrollId);
      _showSuccessSnackBar('Đã đánh dấu đã thanh toán');
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadMonthlyPayrolls();
    } catch (e) {
      _showErrorSnackBar('Lỗi cập nhật trạng thái: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lương nhân viên'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Tổng quan', icon: Icon(Icons.dashboard)),
            Tab(text: 'Bảng lương', icon: Icon(Icons.payment)),
            Tab(text: 'Nhân viên', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildPayrollTab(),
                  _buildEmployeesTab(),
                ],
              ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthYearSelector(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 20),
          Expanded(child: _buildSummaryCards()),
        ],
      ),
    );
  }

  Widget _buildMonthYearSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedMonth,
                decoration: const InputDecoration(
                  labelText: 'Tháng',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: List.generate(12, (index) {
                  final month = (index + 1).toString().padLeft(2, '0');
                  return DropdownMenuItem(
                    value: month,
                    child: Text('Tháng $month'),
                  );
                }),
                onChanged: (value) {
                  setState(() => _selectedMonth = value!);
                  _loadMonthlyPayrolls();
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: const InputDecoration(
                  labelText: 'Năm',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: List.generate(5, (index) {
                  final year = (DateTime.now().year - 2 + index).toString();
                  return DropdownMenuItem(
                    value: year,
                    child: Text('Năm $year'),
                  );
                }),
                onChanged: (value) {
                  setState(() => _selectedYear = value!);
                  _loadMonthlyPayrolls();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _processUnprocessedAppointments,
            icon: const Icon(Icons.sync),
            label: const Text('Xử lý appointments chưa tính lương'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _generatePayrollForAllEmployees,
            icon: const Icon(Icons.calculate),
            label: Text(
              'Tạo bảng lương tất cả NV $_selectedMonth/$_selectedYear',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalPayrolls = _monthlyPayrolls.length;
    final totalAmount = _monthlyPayrolls.fold<double>(
      0.0,
      (sum, payroll) => sum + payroll.totalAmount,
    );
    final pendingPayrolls =
        _monthlyPayrolls.where((p) => p.status == PayrollStatus.PENDING).length;
    final approvedPayrolls =
        _monthlyPayrolls
            .where((p) => p.status == PayrollStatus.APPROVED)
            .length;
    final paidPayrolls =
        _monthlyPayrolls.where((p) => p.status == PayrollStatus.PAID).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Tổng bảng lương',
          totalPayrolls.toString(),
          Icons.receipt_long,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Tổng tiền lương',
          _currencyFormatter.format(totalAmount),
          Icons.attach_money,
          Colors.green,
        ),
        _buildSummaryCard(
          'Chờ phê duyệt',
          pendingPayrolls.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Đã phê duyệt',
          approvedPayrolls.toString(),
          Icons.check_circle_outline,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Đã thanh toán',
          paidPayrolls.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildSummaryCard(
          'Tổng NV',
          _employees.length.toString(),
          Icons.people,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollTab() {
    return RefreshIndicator(
      onRefresh: _loadMonthlyPayrolls,
      child:
          _monthlyPayrolls.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có bảng lương nào',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _monthlyPayrolls.length,
                itemBuilder: (context, index) {
                  final payroll = _monthlyPayrolls[index];
                  return _buildPayrollCard(payroll);
                },
              ),
    );
  }

  Widget _buildPayrollCard(PayrollSummary payroll) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payroll.employee?.fullName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        payroll.employee?.store?.storeName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(payroll.status.toString() as PayrollStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Kỳ lương: ${_dateFormatter.format(payroll.periodStartDate)} - ${_dateFormatter.format(payroll.periodEndDate)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lương cơ bản:'),
                      Text(
                        _currencyFormatter.format(payroll.baseSalary),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hoa hồng:'),
                      Text(
                        _currencyFormatter.format(payroll.totalCommission),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _currencyFormatter.format(payroll.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${payroll.totalAppointments} lịch hẹn'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'DT: ${_currencyFormatter.format(payroll.totalRevenue)}',
                    ),
                  ],
                ),
              ],
            ),
            if (payroll.approvedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Phê duyệt: ${_dateFormatter.format(payroll.approvedAt!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (payroll.paidAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Thanh toán: ${_dateFormatter.format(payroll.paidAt!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            _buildPayrollActions(payroll),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PayrollStatus status) {
    Color color;
    String text;

    switch (status) {
      case PayrollStatus.DRAFT:
        color = Colors.blueGrey;
        text = 'Nháp';
        break;
      case PayrollStatus.PENDING:
        color = Colors.orange;
        text = 'Chờ duyệt';
        break;
      case PayrollStatus.APPROVED:
        color = Colors.blue;
        text = 'Đã duyệt';
        break;
      case PayrollStatus.PAID:
        color = Colors.green;
        text = 'Đã trả';
        break;
      case PayrollStatus.CANCELLED:
        color = Colors.red;
        text = 'Đã hủy';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildPayrollActions(PayrollSummary payroll) {
    List<Widget> actions = [];

    if (payroll.status == PayrollStatus.PENDING) {
      actions.add(
        ElevatedButton.icon(
          onPressed:
              _isLoading ? null : () => _approvePayroll(payroll.payrollId!),
          icon: const Icon(Icons.check, size: 16),
          label: const Text('Phê duyệt'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (payroll.status == PayrollStatus.APPROVED) {
      actions.add(
        ElevatedButton.icon(
          onPressed: _isLoading ? null : () => _markAsPaid(payroll.payrollId!),
          icon: const Icon(Icons.payment, size: 16),
          label: const Text('Đánh dấu đã trả'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children:
          actions
              .map(
                (action) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: action,
                ),
              )
              .toList(),
    );
  }

  Widget _buildEmployeesTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadEmployees();
        await _loadMonthlyPayrolls();
      },
      child:
          _employees.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Chưa có nhân viên nào',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _employees.length,
                itemBuilder: (context, index) {
                  final employee = _employees[index];
                  return _buildEmployeeCard(employee);
                },
              ),
    );
  }

  Widget _buildEmployeeCard(Employee employee) {
    final hasPayroll = _monthlyPayrolls.any(
      (payroll) => payroll.employee?.employeeId == employee.employeeId,
    );

    final PayrollSummary? employeePayroll =
        hasPayroll
            ? _monthlyPayrolls.firstWhere(
              (payroll) => payroll.employee?.employeeId == employee.employeeId,
            )
            : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    employee.fullName?.substring(0, 1).toUpperCase() ?? 'N',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.fullName ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        employee.email ?? 'N/A',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'SĐT: ${employee.phoneNumber ?? 'N/A'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                if (hasPayroll)
                  _buildStatusChip(employeePayroll!.status as PayrollStatus)
                else
                  const Chip(
                    label: Text('Chưa có BL', style: TextStyle(fontSize: 10)),
                    backgroundColor: Colors.grey,
                    labelStyle: TextStyle(color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lương cơ bản:'),
                      Text(
                        _currencyFormatter.format(
                          employee.baseSalary.toDouble(),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tỷ lệ hoa hồng:'),
                      Text(
                        '${(employee.commissionRate?.toDouble() ?? 0 * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (hasPayroll && employeePayroll != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng lịch hẹn:'),
                        Text(
                          '${employeePayroll.totalAppointments}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Doanh thu:'),
                        Text(
                          _currencyFormatter.format(
                            employeePayroll.totalRevenue,
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!hasPayroll)
                  ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : () => _generatePayroll(
                              employee,
                              int.parse(_selectedMonth),
                              int.parse(_selectedYear),
                            ),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Tạo bảng lương'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => SalaryScreen(
                              employeeId: employee.employeeId!.toString(),
                              employeeName: employee.fullName ?? 'N/A',
                              initialMonth: int.parse(_selectedMonth),
                              initialYear: int.parse(_selectedYear),
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Chi tiết'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum PayrollStatus { DRAFT, PENDING, APPROVED, PAID, CANCELLED }
