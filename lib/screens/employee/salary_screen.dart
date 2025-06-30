import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shine_booking_app/models/dto/my_payroll_response_model.dart';
import 'package:shine_booking_app/models/payroll_summary_model.dart';
import 'package:shine_booking_app/services/api_salary.dart';

class SalaryScreen extends StatefulWidget {
  final String employeeId;
  final String employeeName;
  final int? initialMonth;
  final int? initialYear;

  const SalaryScreen({
    super.key,
    required this.employeeId,
    required this.employeeName,
    this.initialMonth,
    this.initialYear,
  });

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  MyPayrollResponse? _payrollData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth ?? DateTime.now().month;
    _selectedYear = widget.initialYear ?? DateTime.now().year;
    _loadPayroll();
  }

  Future<void> _loadPayroll() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _payrollData = null;
    });
    try {
      final data = await ApiSalaryService.getPayrollByEmployeeId(
        employeeId: widget.employeeId,
        year: _selectedYear,
        month: _selectedMonth,
      );
      if (mounted) {
        setState(() {
          _payrollData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth, 1),
      firstDate: DateTime(now.year - 2, 1, 1),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDatePickerMode: DatePickerMode.year,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFFFF6B35),
            colorScheme: const ColorScheme.light(primary: Color(0xFFFF6B35)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null &&
        (_selectedMonth != pickedDate.month ||
            _selectedYear != pickedDate.year)) {
      setState(() {
        _selectedMonth = pickedDate.month;
        _selectedYear = pickedDate.year;
      });
      _loadPayroll();
    }
  }

  String _formatCurrency(double amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bảng lương của ${widget.employeeName}'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorState()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthYearPicker(),
                    const SizedBox(height: 20),
                    if (_payrollData != null &&
                        _payrollData!.payrolls.isNotEmpty)
                      ..._payrollData!.payrolls
                          .map((payroll) => _buildPayrollSummaryCard(payroll))
                          .toList()
                    else
                      _buildEmptyState(),
                  ],
                ),
              ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn tháng/năm bảng lương:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Tháng ${_selectedMonth} Năm ${_selectedYear}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFFF6B35)),
                  onPressed: () => _selectMonthYear(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollSummaryCard(PayrollSummary payroll) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bảng lương ${DateFormat('MM/yyyy').format(payroll.periodStartDate)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(
              Icons.calendar_today,
              'Từ ngày',
              DateFormat('dd/MM/yyyy').format(payroll.periodStartDate),
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Đến ngày',
              DateFormat('dd/MM/yyyy').format(payroll.periodEndDate),
            ),
            _buildInfoRow(
              Icons.work,
              'Lương cơ bản',
              _formatCurrency(payroll.baseSalary),
            ),
            _buildInfoRow(
              Icons.attach_money,
              'Tổng hoa hồng',
              _formatCurrency(payroll.totalCommission),
            ),
            _buildInfoRow(
              Icons.receipt_long,
              'Tổng cuộc hẹn',
              payroll.totalAppointments.toString(),
            ),
            _buildInfoRow(
              Icons.bar_chart,
              'Tổng doanh thu',
              _formatCurrency(payroll.totalRevenue),
            ),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(
              Icons.payment,
              'Tổng thực nhận',
              _formatCurrency(payroll.totalAmount),
              valueColor: Colors.green.shade700,
              valueWeight: FontWeight.bold,
            ),
            _buildStatusRow(payroll.status),
            if (payroll.notes != null && payroll.notes!.isNotEmpty)
              _buildInfoRow(Icons.notes, 'Ghi chú', payroll.notes!),
            if (payroll.approvedAt != null)
              _buildInfoRow(
                Icons.check_circle_outline,
                'Duyệt lúc',
                DateFormat('dd/MM/yyyy HH:mm').format(payroll.approvedAt!),
              ),
            if (payroll.paidAt != null)
              _buildInfoRow(
                Icons.paid,
                'Thanh toán lúc',
                DateFormat('dd/MM/yyyy HH:mm').format(payroll.paidAt!),
              ),
            if (payroll.approvedBy != null)
              _buildInfoRow(
                Icons.verified_user,
                'Duyệt bởi',
                payroll.approvedBy?.fullName ?? 'N/A',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15,
                fontWeight: valueWeight ?? FontWeight.normal,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(PayrollStatus status) {
    Color statusColor;
    String statusText;
    switch (status) {
      case PayrollStatus.DRAFT:
        statusColor = Colors.blueGrey;
        statusText = 'Nháp';
        break;
      case PayrollStatus.PENDING:
        statusColor = Colors.orange;
        statusText = 'Chờ duyệt';
        break;
      case PayrollStatus.APPROVED:
        statusColor = Colors.blue;
        statusText = 'Đã duyệt';
        break;
      case PayrollStatus.PAID:
        statusColor = Colors.green;
        statusText = 'Đã thanh toán';
        break;
      case PayrollStatus.CANCELLED:
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
    }
    return _buildInfoRow(
      Icons.info_outline,
      'Trạng thái',
      statusText,
      valueColor: statusColor,
      valueWeight: FontWeight.bold,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monetization_on, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Không tìm thấy bảng lương cho tháng này.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Vui lòng chọn tháng/năm khác hoặc liên hệ quản lý.',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
          const SizedBox(height: 20),
          Text(
            'Đã xảy ra lỗi khi tải bảng lương.',
            style: TextStyle(fontSize: 18, color: Colors.red[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? 'Vui lòng thử lại sau.',
            style: TextStyle(fontSize: 14, color: Colors.red[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loadPayroll, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
