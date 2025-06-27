// lib/screens/employee/employee_appointments_screen.dart
import 'package:flutter/material.dart';

class EmployeeAppointmentsScreen extends StatefulWidget {
  const EmployeeAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeAppointmentsScreen> createState() => _EmployeeAppointmentsScreenState();
}

class _EmployeeAppointmentsScreenState extends State<EmployeeAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuộc hẹn của tôi'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Hôm nay'),
            Tab(text: 'Sắp tới'),
            Tab(text: 'Lịch sử'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayAppointments(),
          _buildUpcomingAppointments(),
          _buildHistoryAppointments(),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments() {
    final todayAppointments = [
      {
        'time': '09:00',
        'customer': 'Nguyễn Văn B',
        'service': 'Cắt tóc nam',
        'duration': '30 phút',
        'price': '150,000đ',
        'status': 'confirmed',
      },
      {
        'time': '10:30',
        'customer': 'Trần Thị C',
        'service': 'Cắt + Gội + Sấy',
        'duration': '45 phút',
        'price': '200,000đ',
        'status': 'confirmed',
      },
      {
        'time': '14:00',
        'customer': 'Lê Văn D',
        'service': 'Cắt tóc + Tỉa râu',
        'duration': '40 phút',
        'price': '180,000đ',
        'status': 'waiting',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todayAppointments.length,
      itemBuilder: (context, index) {
        final appointment = todayAppointments[index];
        return _buildAppointmentCard(appointment, true);
      },
    );
  }

  Widget _buildUpcomingAppointments() {
    final upcomingAppointments = [
      {
        'date': '28/06/2025',
        'time': '09:30',
        'customer': 'Phạm Văn E',
        'service': 'Cắt tóc nam',
        'duration': '30 phút',
        'price': '150,000đ',
        'status': 'confirmed',
      },
      {
        'date': '29/06/2025',
        'time': '15:00',
        'customer': 'Hoàng Thị F',
        'service': 'Uốn tóc',
        'duration': '90 phút',
        'price': '350,000đ',
        'status': 'confirmed',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final appointment = upcomingAppointments[index];
        return _buildAppointmentCard(appointment, false);
      },
    );
  }

  Widget _buildHistoryAppointments() {
    final historyAppointments = [
      {
        'date': '25/06/2025',
        'time': '10:00',
        'customer': 'Đỗ Văn G',
        'service': 'Cắt tóc nam',
        'duration': '30 phút',
        'price': '150,000đ',
        'status': 'completed',
      },
      {
        'date': '24/06/2025',
        'time': '14:30',
        'customer': 'Vũ Thị H',
        'service': 'Nhuộm tóc',
        'duration': '120 phút',
        'price': '400,000đ',
        'status': 'completed',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: historyAppointments.length,
      itemBuilder: (context, index) {
        final appointment = historyAppointments[index];
        return _buildAppointmentCard(appointment, false);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, String> appointment, bool isToday) {
    Color statusColor;
    String statusText;

    switch (appointment['status']) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = 'Đã xác nhận';
        break;
      case 'waiting':
        statusColor = Colors.orange;
        statusText = 'Đang chờ';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'Hoàn thành';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.blue[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isToday ? appointment['time']! : '${appointment['date']} - ${appointment['time']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  appointment['customer']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.content_cut, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  appointment['service']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      appointment['duration']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                Text(
                  appointment['price']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            if (appointment['status'] == 'waiting') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showUpdateStatusDialog(context, appointment);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Xác nhận'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelDialog(context, appointment);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Map<String, String> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận cuộc hẹn'),
          content: Text('Bạn có chắc chắn muốn xác nhận cuộc hẹn với ${appointment['customer']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xác nhận cuộc hẹn!')),
                );
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, Map<String, String> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy cuộc hẹn'),
          content: Text('Bạn có chắc chắn muốn hủy cuộc hẹn với ${appointment['customer']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Không'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hủy cuộc hẹn!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hủy cuộc hẹn'),
            ),
          ],
        );
      },
    );
  }
}