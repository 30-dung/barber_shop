// lib/screens/appointment/appointment_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Make sure this is imported
import 'package:shine_booking_app/models/employee_model.dart';
import 'package:shine_booking_app/models/store_model.dart';
import 'package:shine_booking_app/models/store_service_model.dart';
import 'package:shine_booking_app/models/working_time_slot_model.dart';
import 'package:shine_booking_app/services/api_appointments.dart'; // Import ApiAppointmentsService

class AppointmentConfirmationScreen extends StatefulWidget {
  final StoreService storeService;
  final Store store;
  final Employee employee;
  final WorkingTimeSlot slot;

  const AppointmentConfirmationScreen({
    Key? key,
    required this.storeService,
    required this.store,
    required this.employee,
    required this.slot,
  }) : super(key: key);

  @override
  State<AppointmentConfirmationScreen> createState() =>
      _AppointmentConfirmationScreenState();
}

class _AppointmentConfirmationScreenState
    extends State<AppointmentConfirmationScreen> {
  final TextEditingController _notesController = TextEditingController();
  bool _isBooking = false;

  // Helper method to parse and format time
  String _formatTime(dynamic timeValue) {
    try {
      if (timeValue == null) return 'N/A';

      DateTime dateTime;
      if (timeValue is String) {
        dateTime = DateTime.parse(timeValue);
      } else if (timeValue is DateTime) {
        dateTime = timeValue;
      } else {
        return 'N/A';
      }

      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      print('Error formatting time: $e');
      return 'N/A';
    }
  }

  String _formatDate(dynamic timeValue) {
    try {
      if (timeValue == null) return 'N/A';

      DateTime dateTime;
      if (timeValue is String) {
        dateTime = DateTime.parse(timeValue);
      } else if (timeValue is DateTime) {
        dateTime = timeValue;
      } else {
        return 'N/A';
      }

      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return 'N/A';
    }
  }

  Future<void> _confirmBooking() async {
    if (_isBooking) return;

    setState(() {
      _isBooking = true;
    });

    try {
      // Prepare start and end time
      DateTime startDateTime;

      // Ensure widget.slot.startTime is a DateTime object
      if (widget.slot.startTime is String) {
        startDateTime = DateTime.parse(widget.slot.startTime as String);
      } else if (widget.slot.startTime is DateTime) {
        startDateTime = widget.slot.startTime as DateTime;
      } else {
        throw Exception("Invalid startTime format in slot.");
      }

      // Calculate end time based on service duration (assume 60 minutes if not specified)
      int durationMinutes = widget.storeService.duration ?? 60;
      DateTime endDateTime = startDateTime.add(
        Duration(minutes: durationMinutes),
      );

      // FIX: Format DateTime to ISO 8601 string without milliseconds for Java backend
      // Using 'yyyy-MM-ddTHH:mm:ss' which matches Java's LocalDateTime default parsing
      final String formattedStartTime = DateFormat(
        "yyyy-MM-ddTHH:mm:ss",
      ).format(startDateTime);
      final String formattedEndTime = DateFormat(
        "yyyy-MM-ddTHH:mm:ss",
      ).format(endDateTime);

      // Create appointment using the API
      final result = await ApiAppointmentsService.createAppointment(
        timeSlotId: widget.slot.timeSlotId!,
        storeServiceId: widget.storeService.storeServiceId!,
        startTime: formattedStartTime, // Sử dụng định dạng đã sửa
        endTime: formattedEndTime, // Sử dụng định dạng đã sửa
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 8),
                  Text('Đặt lịch thành công!'),
                ],
              ),
              content: const Text(
                'Cuộc hẹn của bạn đã được tạo thành công. Bạn có thể xem chi tiết trong mục "Lịch hẹn của tôi".',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst); // Go back to home
                  },
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đặt lịch: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận lịch hẹn'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết đặt lịch',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoRow(
                      Icons.store,
                      'Cửa hàng',
                      widget.store.storeName!,
                    ),
                    _buildInfoRow(
                      Icons.build,
                      'Dịch vụ',
                      widget.storeService.service.serviceName,
                    ),
                    _buildInfoRow(
                      Icons.person,
                      'Nhân viên',
                      widget.employee.fullName,
                    ),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Ngày',
                      _formatDate(widget.slot.startTime),
                    ),
                    _buildInfoRow(
                      Icons.access_time,
                      'Giờ',
                      _formatTime(widget.slot.startTime),
                    ),

                    if (widget.storeService.duration != null)
                      _buildInfoRow(
                        Icons.timer,
                        'Thời gian',
                        '${widget.storeService.duration} phút',
                      ),

                    if (widget.storeService.price != null)
                      _buildInfoRow(
                        Icons.attach_money,
                        'Giá tiền',
                        '${NumberFormat('#,###', 'vi_VN').format(widget.storeService.price)} VNĐ',
                        valueColor: Colors.green,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ghi chú (Tùy chọn)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập ghi chú cho cuộc hẹn...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child:
                    _isBooking
                        ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Đang đặt lịch...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                        : const Text(
                          'Xác nhận đặt lịch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 16),

            // Note Card
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vui lòng đến đúng giờ. Nếu cần thay đổi, hãy liên hệ cửa hàng trước ít nhất 2 giờ.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
