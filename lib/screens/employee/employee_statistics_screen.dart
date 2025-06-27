// lib/screens/employee/employee_statistics_screen.dart
import 'package:flutter/material.dart';

class EmployeeStatisticsScreen extends StatefulWidget {
  const EmployeeStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeStatisticsScreen> createState() => _EmployeeStatisticsScreenState();
}

class _EmployeeStatisticsScreenState extends State<EmployeeStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedMonth = '06/2025';

  final List<String> months = [
    '06/2025', '05/2025', '04/2025', '03/2025', '02/2025', '01/2025'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Thống kê cá nhân'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tháng này'),
            Tab(text: 'Tổng quan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyStats(),
          _buildOverallStats(),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return SingleChildScrollView(
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
                  Icon(Icons.calendar_month, color: Colors.purple[700]),
                  const SizedBox(width: 12),
                  const Text(
                    'Tháng:',
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

          // Monthly Performance Card
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.purple[600]!, Colors.purple[400]!],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Hiệu suất tháng này',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPerformanceItem('Khách hàng', '85', Icons.people),
                      _buildPerformanceItem('Doanh thu', '12.5M', Icons.attach_money),
                      _buildPerformanceItem('Đánh giá', '4.8⭐', Icons.star),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Statistics Grid
          const Text(
            'Thống kê chi tiết',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildStatCard('Cuộc hẹn\nhoàn thành', '82', '85', Colors.green),
              _buildStatCard('Cuộc hẹn\nbị hủy', '3', '85', Colors.red),
              _buildStatCard('Thời gian\nlàm việc', '176h', '180h', Colors.blue),
              _buildStatCard('Khách hàng\nmới', '25', '85', Colors.orange),
            ],
          ),

          const SizedBox(height: 20),

          // Service Breakdown
          const Text(
            'Phân tích dịch vụ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _buildServiceItem('Cắt tóc nam', 45, 85, Colors.blue),
          _buildServiceItem('Cắt tóc nữ', 20, 85, Colors.pink),
          _buildServiceItem('Nhuộm tóc', 12, 85, Colors.purple),
          _buildServiceItem('Uốn tóc', 8, 85, Colors.orange),

          const SizedBox(height: 20),

          // Daily Performance Chart
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hiệu suất theo ngày',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    child: _buildDailyChart(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Performance
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.indigo[600]!, Colors.indigo[400]!],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tổng quan hiệu suất',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPerformanceItem('Tổng KH', '520', Icons.people),
                      _buildPerformanceItem('Doanh thu', '75M', Icons.trending_up),
                      _buildPerformanceItem('Kinh nghiệm', '2 năm', Icons.work),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Achievement Cards
          const Text(
            'Thành tích',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _buildAchievementCard(
            'Nhân viên xuất sắc tháng 5',
            'Đạt doanh thu cao nhất tháng',
            Icons.emoji_events,
            Colors.amber,
          ),
          _buildAchievementCard(
            'Khách hàng yêu thích',
            'Đánh giá trung bình 4.8/5 sao',
            Icons.favorite,
            Colors.red,
          ),
          _buildAchievementCard(
            'Chuyên gia cắt tóc',
            'Hoàn thành 500+ lượt cắt tóc',
            Icons.content_cut,
            Colors.blue,
          ),

          const SizedBox(height: 20),

          // 6-Month Trend
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'xu hướng 6 tháng gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: _buildTrendChart(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Skills Progress
          const Text(
            'Tiến độ kỹ năng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          _buildSkillProgress('Cắt tóc nam', 0.9),
          _buildSkillProgress('Cắt tóc nữ', 0.8),
          _buildSkillProgress('Nhuộm tóc', 0.7),
          _buildSkillProgress('Tạo kiểu', 0.85),
          _buildSkillProgress('Tư vấn khách hàng', 0.95),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String total, Color color) {
    double percentage = (int.parse(value) / int.parse(total.replaceAll('h', ''))) * 100;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
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
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String service, int count, int total, Color color) {
    double percentage = (count / total) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$count lần',
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 4),
            Text(
              '${percentage.toStringAsFixed(1)}% tổng dịch vụ',
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

  Widget _buildDailyChart() {
    // Simplified chart representation
    final List<int> dailyValues = [3, 5, 2, 7, 4, 6, 8, 3, 5, 4, 6, 7, 5, 3];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: dailyValues.map((value) {
        return Container(
          width: 15,
          height: (value * 15).toDouble(),
          decoration: BoxDecoration(
            color: Colors.purple[400],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrendChart() {
    // Simplified trend chart
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Tháng', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('KH', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('DT(M)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Divider(),
          _buildTrendRow('01/2025', '65', '9.2'),
          _buildTrendRow('02/2025', '72', '10.1'),
          _buildTrendRow('03/2025', '78', '11.5'),
          _buildTrendRow('04/2025', '81', '12.0'),
          _buildTrendRow('05/2025', '83', '12.2'),
          _buildTrendRow('06/2025', '85', '12.5'),
        ],
      ),
    );
  }

  Widget _buildTrendRow(String month, String customers, String revenue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: const TextStyle(fontSize: 12)),
          Text(customers, style: const TextStyle(fontSize: 12)),
          Text(revenue, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String description, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Icon(Icons.emoji_events, color: color),
      ),
    );
  }

  Widget _buildSkillProgress(String skill, double progress) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.purple.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
            ),
          ],
        ),
      ),
    );
  }
}