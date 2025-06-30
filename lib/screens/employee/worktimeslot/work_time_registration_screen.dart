// lib/screens/employee/work_time_registration_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shine_booking_app/services/api_worktimeslot.dart';
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/services/storage_service.dart';
import 'package:shine_booking_app/models/dto/work_time_registration_request.dart';
import 'dart:developer'; // Import for logging

class WorkTimeRegistrationScreen extends StatefulWidget {
  const WorkTimeRegistrationScreen({super.key});

  @override
  State<WorkTimeRegistrationScreen> createState() =>
      _WorkTimeRegistrationScreenState();
}

class _WorkTimeRegistrationScreenState
    extends State<WorkTimeRegistrationScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Employee? _currentEmployee;
  bool _isLoadingEmployee = true;
  String? _employeeError;
  bool _isRegistering = false;
  String? _registrationError;

  // Danh sách ca đã chọn
  Set<int> _selectedShifts = <int>{};

  // Khung giờ làm việc chuyên nghiệp (3 ca, mỗi ca 5 tiếng)
  final List<Map<String, dynamic>> _shifts = [
    {
      'name': 'Ca Sáng',
      'startTime': '08:00',
      'endTime': '13:00',
      'icon': Icons.wb_sunny_outlined,
      'color': const Color(0xFFFFB74D),
      'description': '8:00 - 13:00',
    },
    {
      'name': 'Ca Chiều',
      'startTime': '13:00',
      'endTime': '18:00',
      'icon': Icons.wb_cloudy_outlined,
      'color': const Color(0xFF64B5F6),
      'description': '13:00 - 18:00',
    },
    {
      'name': 'Ca Tối',
      'startTime': '18:00',
      'endTime': '23:00',
      'icon': Icons.nightlight_round_outlined,
      'color': const Color(0xFF9575CD),
      'description': '18:00 - 23:00',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCurrentEmployee();
  }

  Future<void> _loadCurrentEmployee() async {
    setState(() {
      _isLoadingEmployee = true;
      _employeeError = null;
    });
    try {
      _currentEmployee = await StorageService.getEmployee();
      if (_currentEmployee == null) {
        _employeeError =
            'Không tìm thấy thông tin nhân viên. Vui lòng đăng nhập lại.';
      } else if (_currentEmployee!.store == null ||
          _currentEmployee!.store!.storeId == null) {
        _employeeError = 'Nhân viên chưa được phân công cửa hàng.';
      }
    } catch (e) {
      _employeeError = 'Lỗi tải thông tin nhân viên: $e';
      log('Load employee error: $e'); // Log lỗi để debug
    } finally {
      setState(() {
        _isLoadingEmployee = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _registrationError = null;
        _selectedShifts.clear(); // Clear selected shifts when changing day
      });
    }
  }

  void _toggleShiftSelection(int shiftIndex) {
    setState(() {
      if (_selectedShifts.contains(shiftIndex)) {
        _selectedShifts.remove(shiftIndex);
      } else {
        if (_selectedShifts.length >= 2) {
          _showSnackBar('Chỉ được chọn tối đa 2 ca làm việc.', isError: true);
          return;
        }
        _selectedShifts.add(shiftIndex);
      }
      _registrationError = null;
    });
  }

  String _formatDateForAPI(DateTime date) {
    // Format ngày thành yyyy-MM-DD
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmRegistration() async {
    if (_selectedDay == null) {
      _showSnackBar('Vui lòng chọn ngày làm việc.', isError: true);
      return;
    }

    if (_selectedShifts.isEmpty) {
      _showSnackBar('Vui lòng chọn ít nhất một ca làm việc.', isError: true);
      return;
    }

    if (_currentEmployee == null ||
        _currentEmployee!.employeeId == null ||
        _currentEmployee!.store == null ||
        _currentEmployee!.store!.storeId == null) {
      _showSnackBar(
        'Không thể đăng ký lịch làm. Thiếu thông tin nhân viên hoặc cửa hàng.',
        isError: true,
      );
      return;
    }

    // Show confirmation dialog
    final shouldRegister = await _showConfirmationDialog();
    if (!shouldRegister) return;

    setState(() {
      _isRegistering = true;
      _registrationError = null;
    });

    try {
      final dateString = _formatDateForAPI(_selectedDay!);
      log('Registering shifts for date: $dateString');
      log('Selected shifts count: ${_selectedShifts.length}');

      // Register each selected shift
      for (int shiftIndex in _selectedShifts) {
        final shift = _shifts[shiftIndex];

        // Use the fromDateAndTime factory constructor to ensure correct formatting
        final request = WorkTimeRegistrationRequest.fromDateAndTime(
          employeeId: _currentEmployee!.employeeId!,
          storeId: _currentEmployee!.store!.storeId!,
          date: dateString,
          startTimeOnly: shift['startTime']!,
          endTimeOnly: shift['endTime']!,
        );

        log('Sending request: ${request.toJson()}');

        try {
          final result = await ApiWorktimeslot.registerWorkTimeSlot(
            request.toJson(),
          );
          log(
            'Registration successful for shift ${shift['name']}: ${result.toJson()}',
          );
        } catch (shiftError) {
          // Ghi lại lỗi cụ thể cho từng ca và ném lại để hiển thị tổng quan
          log('Error registering shift ${shift['name']}: $shiftError');
          throw Exception('Lỗi đăng ký ${shift['name']}: $shiftError');
        }
      }

      final selectedShiftNames = _selectedShifts
          .map((index) => _shifts[index]['name'])
          .join(', ');

      _showSnackBar(
        'Đăng ký $selectedShiftNames ngày ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year} thành công!',
      );

      // Clear selections after successful registration
      setState(() {
        _selectedShifts.clear();
      });
    } catch (e) {
      log('Registration error: $e'); // Log lỗi tổng quát
      setState(() {
        _registrationError = 'Lỗi đăng ký: $e';
      });
      _showSnackBar('Lỗi đăng ký lịch làm: $e', isError: true);
    } finally {
      setState(() {
        _isRegistering = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog() async {
    final selectedShiftNames = _selectedShifts
        .map((index) => _shifts[index]['name'])
        .join(', ');

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Text('Xác nhận đăng ký'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bạn có chắc chắn muốn đăng ký:'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.date_range,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ngày: ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Ca làm: $selectedShiftNames',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
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
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor:
              isError ? const Color(0xFFE57373) : const Color(0xFF66BB6A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Đăng ký lịch làm việc',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoadingEmployee
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF3B82F6),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải thông tin...',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              )
              : _employeeError != null
              ? _buildErrorState(_employeeError!)
              : _currentEmployee == null ||
                  _currentEmployee!.store == null ||
                  _currentEmployee!.store!.storeId == null
              ? _buildErrorState(
                'Thông tin nhân viên hoặc cửa hàng không hợp lệ. Vui lòng liên hệ quản trị viên.',
              )
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildEmployeeInfo(),
                          _buildCalendarSection(),
                          _buildShiftSection(),
                        ],
                      ),
                    ),
                  ),
                  _buildConfirmButton(),
                ],
              ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentEmployee?.fullName ?? 'Tên nhân viên',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentEmployee?.store?.storeName ?? 'Cửa hàng',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Chọn ngày làm việc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    final now = DateTime.now();
    // Cho phép đăng ký lịch trong vòng 3 tháng tới
    final lastSelectableDay = DateTime(now.year, now.month + 3, now.day);

    return TableCalendar(
      firstDay: now,
      lastDay: lastSelectableDay, // Mở rộng range để có thể chuyển tháng
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Tháng'},
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Color(0xFF1E293B),
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF64748B)),
        rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF64748B)),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3B82F6), width: 2),
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF3B82F6),
          shape: BoxShape.circle,
        ),
        weekendTextStyle: const TextStyle(color: Color(0xFFEF4444)),
        defaultTextStyle: const TextStyle(color: Color(0xFF1E293B)),
        todayTextStyle: const TextStyle(
          color: Color(0xFF3B82F6),
          fontWeight: FontWeight.w600,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        disabledDecoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        disabledTextStyle: const TextStyle(color: Color(0xFFCBD5E1)),
      ),
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          // Reset selected day và shifts khi chuyển tháng
          _selectedDay = null;
          _selectedShifts.clear();
          _registrationError = null;
        });
      },
      enabledDayPredicate: (day) {
        // Chỉ cho phép chọn từ hôm nay trở đi
        return !day.isBefore(
          DateTime.now().copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          ),
        );
      },
    );
  }

  Widget _buildShiftSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Chọn ca làm việc (tối đa 2 ca)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selectedDay != null) ...[
            Text(
              'Ngày ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            if (_selectedShifts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Đã chọn ${_selectedShifts.length}/2 ca',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            const Text(
              'Vui lòng chọn ngày trước khi chọn ca làm việc',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_registrationError != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _registrationError!,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _buildShiftGrid(),
        ],
      ),
    );
  }

  Widget _buildShiftGrid() {
    return Column(
      children:
          _shifts.asMap().entries.map((entry) {
            final index = entry.key;
            final shift = entry.value;
            return _buildShiftCard(shift, index);
          }).toList(),
    );
  }

  Widget _buildShiftCard(Map<String, dynamic> shift, int index) {
    final isSelected = _selectedShifts.contains(index);
    final canSelect =
        (_selectedShifts.length < 2 || isSelected) && _selectedDay != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color:
            isSelected
                ? const Color(0xFF3B82F6).withOpacity(0.05)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: isSelected ? 4 : 2,
        shadowColor:
            isSelected
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
        child: InkWell(
          onTap: canSelect ? () => _toggleShiftSelection(index) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected
                        ? const Color(0xFF3B82F6)
                        : (shift['color'] as Color).withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF3B82F6).withOpacity(0.1)
                            : (shift['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    shift['icon'] as IconData,
                    color:
                        isSelected
                            ? const Color(0xFF3B82F6)
                            : shift['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift['name']!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shift['description']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '5 giờ làm việc',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected
                                  ? const Color(0xFF3B82F6)
                                  : shift['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!canSelect)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedDay == null ? Icons.event_busy : Icons.block,
                      color: Colors.grey,
                      size: 20,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF3B82F6).withOpacity(0.1)
                              : const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? Icons.check : Icons.add,
                      color:
                          isSelected
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _selectedShifts.isNotEmpty &&
                        !_isRegistering &&
                        _selectedDay != null
                    ? _confirmRegistration
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child:
                _isRegistering
                    ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Đang đăng ký...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDay == null
                              ? 'Chọn ngày để tiếp tục'
                              : _selectedShifts.isEmpty
                              ? 'Chọn ca làm việc để tiếp tục'
                              : 'Xác nhận đăng ký (${_selectedShifts.length} ca)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Có lỗi xảy ra',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCurrentEmployee,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
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
      ),
    );
  }
}
