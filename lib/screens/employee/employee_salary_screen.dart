// lib/screens/employee/employee_salary_screen.dart
import 'package:flutter/material.dart';

class EmployeeSalaryScreen extends StatefulWidget {
  const EmployeeSalaryScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeSalaryScreen> createState() => _EmployeeSalaryScreenState();
}

class _EmployeeSalaryScreenState extends State<EmployeeSalaryScreen> {
  String selectedMonth = '06/2025';
  final List<String> months = [
    '06/2025', '05/2025', '04/2025', '03/2025', '02/2025', '01/2025'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lương của tôi'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    const Text(
                      'Chọn tháng:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        isExpanded: true,
                        underline: Container(),
                        items: months.map((month) {
                          return DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMonth = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Salary Summary
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[400]!],
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tổng lương tháng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '12,500,000đ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Đã nhận lương',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Salary Breakdown
            const Text(
              'Chi tiết lương',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            _buildSalaryItem('Lương cơ bản', '8,000,000đ', Colors.blue),
            _buildSalaryItem('Hoa hồng dịch vụ', '3,200,000đ', Colors.green),
            _buildSalaryItem('Thưởng KPI', '1,500,000đ', Colors.orange),
            _buildSalaryItem('Phụ cấp', '300,000đ', Colors.purple),
            _buildSalaryItem('Bảo hiểm xã hội', '-500,000đ', Colors.red),

            const SizedBox(height: 20),

            // Work Statistics
            const Text(
              'Thống kê công việc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Số ngày làm việc',
                    '22',
                    'ngày',
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tổng giờ làm',
                    '176',
                    'giờ',
                    Icons.access_time,
                    Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng khách hàng',
                    '128',
                    'khách',
                    Icons.people,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Doanh thu tạo ra',
                    '16M',
                    'đồng',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Salary History
            const Text(
              'Lịch sử lương',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            _buildSalaryHistoryItem('05/2025', '11,800,000đ', true),
            _buildSalaryHistoryItem('04/2025', '12,200,000đ', true),
            _buildSalaryHistoryItem('03/2025', '10,500,000đ', true),
            _buildSalaryHistoryItem('02/2025', '9,800,000đ', true),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryItem(String title, String amount, Color color) {
    bool isDeduction = amount.startsWith('-');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isDeduction ? Icons.remove : Icons.add,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDeduction ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryHistoryItem(String month, String amount, bool isPaid) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.pending,
            color: isPaid ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(
          'Tháng $month',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isPaid ? 'Đã thanh toán' : 'Chưa thanh toán',
          style: TextStyle(
            color: isPaid ? Colors.green : Colors.orange,
            fontSize: 12,
          ),
        ),
        trailing: Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        onTap: () {
          _showSalaryDetail(month, amount);
        },
      ),
    );
  }

  void _showSalaryDetail(String month, String amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết lương tháng $month'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Lương cơ bản:', '8,000,000đ'),
              _buildDetailRow('Hoa hồng:', '2,800,000đ'),
              _buildDetailRow('Thưởng:', '1,200,000đ'),
              _buildDetailRow('Phụ cấp:', '300,000đ'),
              const Divider(),
              _buildDetailRow('Bảo hiểm:', '-500,000đ'),
              const Divider(),
              _buildDetailRow('Tổng cộng:', amount, isTotal: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.green[700] :
              value.startsWith('-') ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}