import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shine_booking_app/services/api_worktimeslot.dart';
import 'package:shine_booking_app/models/working_time_slot_model.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import 'dart:developer'; // Import for logging

class EmployeeScheduleScreen extends StatefulWidget {
  const EmployeeScheduleScreen({super.key});

  @override
  State<EmployeeScheduleScreen> createState() => _EmployeeScheduleScreenState();
}

class _EmployeeScheduleScreenState extends State<EmployeeScheduleScreen> {
  List<WorkingTimeSlot> _workingSlots = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime _selectedWeek = DateTime.now();
  Employee? _currentEmployee;

  @override
  void initState() {
    super.initState();
    _loadEmployeeAndWorkingSlots(); // Tải cả thông tin nhân viên và slot làm việc
  }

  Future<void> _loadEmployeeAndWorkingSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _currentEmployee = await StorageService.getEmployee();
      if (_currentEmployee == null || _currentEmployee!.employeeId == null) {
        _errorMessage =
            'Không tìm thấy thông tin nhân viên hoặc ID. Vui lòng đăng nhập lại.';
        return;
      }
      log('Loaded employee ID: ${_currentEmployee!.employeeId}');

      // Chỉ load slot làm việc khi có employeeId
      await _loadWorkingSlots();
    } catch (e) {
      log('Error loading employee or initial slots: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWorkingSlots() async {
    // Đảm bảo _currentEmployee và employeeId không null trước khi gọi API
    if (_currentEmployee?.employeeId == null) {
      _errorMessage = 'Không có ID nhân viên để tải lịch làm việc.';
      _isLoading = false;
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true here as well for refresh
      _errorMessage = null;
    });

    try {
      final slots = await ApiWorktimeslot.getEmployeeWorkTimeSlots(
        _currentEmployee!.employeeId!,
      );
      setState(() {
        _workingSlots = slots;
        _isLoading = false;
      });
      log('Successfully loaded ${_workingSlots.length} working slots.');
    } catch (e) {
      log('Error loading working slots: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime _getEndOfWeek(DateTime date) {
    return _getStartOfWeek(date).add(const Duration(days: 6));
  }

  List<WorkingTimeSlot> _getSlotsForDate(DateTime date) {
    return _workingSlots.where((slot) {
      if (slot.startTime == null) return false;
      final slotDate = DateTime(
        slot.startTime!.year,
        slot.startTime!.month,
        slot.startTime!.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return slotDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  void _changeWeek(int direction) {
    setState(() {
      _selectedWeek = _selectedWeek.add(Duration(days: 7 * direction));
    });
    _loadWorkingSlots(); // Tải lại slot cho tuần mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Lịch làm việc của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployeeAndWorkingSlots, // Refresh all data
          ),
        ],
      ),
      body: Column(
        children: [
          _buildWeekNavigator(),
          Expanded(
            child:
                _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                    ? _buildErrorState()
                    : _buildScheduleContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigator() {
    final startOfWeek = _getStartOfWeek(_selectedWeek);
    final endOfWeek = _getEndOfWeek(_selectedWeek);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B35),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeWeek(-1),
            icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Tuần ${DateFormat('dd/MM').format(startOfWeek)} - ${DateFormat('dd/MM/yyyy').format(endOfWeek)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_workingSlots.length} ca làm việc',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _changeWeek(1),
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFFF6B35)),
          SizedBox(height: 16),
          Text(
            'Đang tải lịch làm việc...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadEmployeeAndWorkingSlots, // Thử lại tải toàn bộ
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent() {
    if (_workingSlots.isEmpty) {
      return _buildEmptyState();
    }

    final startOfWeek = _getStartOfWeek(_selectedWeek);
    final weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: weekDays.length,
      itemBuilder: (context, index) {
        final date = weekDays[index];
        final slotsForDay = _getSlotsForDate(date);
        return _buildDayCard(date, slotsForDay);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Chưa có lịch làm việc nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lịch làm việc sẽ được hiển thị ở đây',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(DateTime date, List<WorkingTimeSlot> slots) {
    final isToday =
        DateTime.now().day == date.day &&
        DateTime.now().month == date.month &&
        DateTime.now().year == date.year;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isToday ? const Color(0xFFFF6B35) : Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE', 'vi_VN').format(date),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy').format(date),
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isToday ? Colors.white : const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${slots.length} ca',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isToday ? const Color(0xFFFF6B35) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (slots.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Không có ca làm việc',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Column(
              children: slots.map((slot) => _buildTimeSlotItem(slot)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotItem(WorkingTimeSlot slot) {
    final startTime =
        slot.startTime != null
            ? DateFormat('HH:mm').format(slot.startTime!)
            : '--:--';
    final endTime =
        slot.endTime != null
            ? DateFormat('HH:mm').format(slot.endTime!)
            : '--:--';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: slot.isAvailable == true ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$startTime - $endTime',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (slot.store?.storeName != null)
                  Row(
                    children: [
                      Icon(Icons.store, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          slot.store!.storeName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  slot.isAvailable == true
                      ? Colors.green[50]
                      : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: slot.isAvailable == true ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Text(
              slot.isAvailable == true ? 'Có thể làm' : 'Không thể làm',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color:
                    slot.isAvailable == true
                        ? Colors.green[700]
                        : Colors.orange[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
