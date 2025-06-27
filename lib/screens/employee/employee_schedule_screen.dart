// lib/screens/employee/employee_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import để định dạng ngày

class EmployeeScheduleScreen extends StatefulWidget {
  const EmployeeScheduleScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeScheduleScreen> createState() => _EmployeeScheduleScreenState();
}

class _EmployeeScheduleScreenState extends State<EmployeeScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();

  // Sample schedule data for "Lịch của tôi" tab
  Map<String, List<String>> weeklySchedule = {
    'Monday': ['morning', 'afternoon'],
    'Tuesday': ['morning', 'evening'],
    'Wednesday': ['afternoon', 'evening'],
    'Thursday': ['morning'],
    'Friday': ['morning', 'afternoon', 'evening'],
    'Saturday': ['morning', 'afternoon'],
    'Sunday': [],
  };

  // Sample available shifts for "Đăng ký ca" tab - this would typically come from an API
  // Key: day of week (e.g., 'Monday'), Value: list of available shift types ('morning', 'afternoon', 'evening')
  Map<String, List<String>> availableShiftsForWeek = {
    'Monday': ['morning', 'afternoon', 'evening'],
    'Tuesday': ['morning', 'afternoon', 'evening'],
    'Wednesday': ['morning', 'afternoon', 'evening'],
    'Thursday': ['morning', 'afternoon', 'evening'],
    'Friday': ['morning', 'afternoon', 'evening'],
    'Saturday': ['morning', 'afternoon', 'evening'],
    'Sunday': ['morning', 'afternoon'], // Ví dụ Chủ nhật có ca sáng/chiều
  };

  // State to hold selected shifts for registration
  Set<String> _selectedShiftsForDate = {}; // Stores 'morning', 'afternoon', 'evening'

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

  // Helper to format date for display
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(date); // Định dạng tiếng Việt
  }

  // Helper to display shift types in Vietnamese
  String _getShiftDisplayName(String shift) {
    switch (shift) {
      case 'morning':
        return 'Ca Sáng (8h - 12h)';
      case 'afternoon':
        return 'Ca Chiều (13h - 17h)';
      case 'evening':
        return 'Ca Tối (18h - 22h)';
      default:
        return shift;
    }
  }

  // Helper to select a date for shift registration
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(), // Không cho chọn ngày quá khứ
      lastDate: DateTime.now().add(const Duration(days: 90)), // Cho phép chọn trong 90 ngày tới
      locale: const Locale('vi', 'VN'), // Đặt locale cho DatePicker
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // Reset selected shifts when date changes
        _selectedShiftsForDate = {};
      });
    }
  }

  // Placeholder function for registering shifts
  void _registerShifts() {
    if (_selectedShiftsForDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một ca để đăng ký!')),
      );
      return;
    }
    // TODO: Implement API call to register shifts for selectedDate and _selectedShiftsForDate
    print('Đăng ký ca cho ngày: ${DateFormat('yyyy-MM-dd').format(selectedDate)}');
    print('Các ca đã chọn: ${_selectedShiftsForDate.join(', ')}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã đăng ký các ca: ${_selectedShiftsForDate.map((s) => _getShiftDisplayName(s)).join(', ')} cho ngày ${_formatDate(selectedDate)}')),
    );

    // After successful registration, you might want to refresh my schedule tab
    // _loadMySchedule(); // If you had an actual method to reload my schedule
    setState(() {
      _selectedShiftsForDate = {}; // Clear selections after registration
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký ca làm'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Lịch của tôi'),
            Tab(text: 'Đăng ký ca'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMySchedule(),
          _buildRegisterShift(),
        ],
      ),
    );
  }

  // --- Widget for "Lịch của tôi" tab ---
  Widget _buildMySchedule() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Week Summary
          Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [Colors.orange[600]!, Colors.orange[400]!],
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tuần này',
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
                      _buildWeekSummaryItem('Tổng ca', '12', Icons.schedule),
                      _buildWeekSummaryItem('Giờ làm', '48h', Icons.access_time),
                      _buildWeekSummaryItem('Ngày làm', '6', Icons.calendar_today),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Weekly Schedule
          const Text(
            'Lịch làm việc tuần',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          ...weeklySchedule.entries.map((entry) {
            return _buildDayScheduleCard(entry.key, entry.value);
          }).toList(),

          const SizedBox(height: 20),

          // Next Week Preview
          Card(
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
                      const Text(
                        'Tuần tiếp theo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _tabController.animateTo(1);
                        },
                        child: const Text('Đăng ký thêm'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đã đăng ký 8/21 ca có thể làm tuần sau',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 8 / 21,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for week summary items
  Widget _buildWeekSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Helper for daily schedule card
  Widget _buildDayScheduleCard(String day, List<String> shifts) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                _getDayDisplayName(day),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: shifts.isEmpty
                  ? Text(
                'Không có ca làm',
                style: TextStyle(color: Colors.grey[600]),
              )
                  : Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: shifts.map((shift) {
                  return Chip(
                    label: Text(_getShiftDisplayName(shift)),
                    backgroundColor: Colors.orange[100],
                    labelStyle: TextStyle(color: Colors.orange[800]),
                    avatar: Icon(Icons.access_time, size: 18, color: Colors.orange[800]),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for day name in Vietnamese
  String _getDayDisplayName(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Thứ Hai';
      case 'tuesday':
        return 'Thứ Ba';
      case 'wednesday':
        return 'Thứ Tư';
      case 'thursday':
        return 'Thứ Năm';
      case 'friday':
        return 'Thứ Sáu';
      case 'saturday':
        return 'Thứ Bảy';
      case 'sunday':
        return 'Chủ Nhật';
      default:
        return day;
    }
  }


  // --- Widget for "Đăng ký ca" tab ---
  Widget _buildRegisterShift() {
    // Get the list of available shifts for the selected date's day of week
    // This simulates fetching available shifts from backend for a specific date
    String dayOfWeek = DateFormat('EEEE').format(selectedDate); // e.g., 'Monday'
    List<String> availableShiftsToday = availableShiftsForWeek[dayOfWeek] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chọn ngày muốn đăng ký', // Changed text for clarity
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Shift Registration Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Các ca có thể đăng ký trong ngày',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (availableShiftsToday.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'Không có ca làm nào khả dụng cho ngày này.',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: availableShiftsToday.map((shiftType) {
                        return CheckboxListTile(
                          title: Text(
                            _getShiftDisplayName(shiftType),
                            style: const TextStyle(fontSize: 16),
                          ),
                          value: _selectedShiftsForDate.contains(shiftType),
                          onChanged: (bool? newValue) {
                            setState(() {
                              if (newValue == true) {
                                _selectedShiftsForDate.add(shiftType);
                              } else {
                                _selectedShiftsForDate.remove(shiftType);
                              }
                            });
                          },
                          activeColor: Colors.orange[700],
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading, // Checkbox ở bên trái
                          contentPadding: EdgeInsets.zero, // Loại bỏ padding mặc định
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerShifts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50), // Full width button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Đăng ký ca làm',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
