// lib/screens/booking/booking_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import '../../utils/dialog_utils.dart'; // Import tiện ích Dialog

const Color kPrimaryColor = Color(0xFFFF6B35);

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late Booking _currentBooking;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELED': // Đảm bảo khớp với enum CANCELED của backend
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ xác nhận';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'CANCELED': // Đảm bảo khớp với enum CANCELED của backend
        return 'Đã hủy';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
        return Icons.check_circle_outline;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'CANCELED': // Đảm bảo khớp với enum CANCELED của backend
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _cancelBooking() async {
    // Hiển thị hộp thoại xác nhận trước khi hủy
    final bool? confirm = await DialogUtils.showConfirmationDialog(
      context,
      'Xác nhận hủy lịch hẹn?',
      'Bạn có chắc chắn muốn hủy lịch hẹn này? Thao tác này không thể hoàn tác.',
      confirmButtonText: 'Hủy lịch',
      cancelButtonText: 'Không',
    );

    if (confirm != true) {
      return; // Người dùng đã hủy hộp thoại
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      await ApiService.cancelAppointment(
        _currentBooking.appointmentId,
      ); // Gọi API hủy
      // Cập nhật trạng thái cục bộ thành CANCELED sau khi gọi API thành công
      setState(() {
        _currentBooking = Booking(
          appointmentId: _currentBooking.appointmentId,
          slug: _currentBooking.slug,
          startTime: _currentBooking.startTime,
          endTime: _currentBooking.endTime,
          status: 'CANCELED', // Đặt trạng thái thành CANCELED
          createdAt: _currentBooking.createdAt,
          storeName: _currentBooking.storeName,
          serviceName: _currentBooking.serviceName,
          employeeFullName: _currentBooking.employeeFullName,
          totalAmount: _currentBooking.totalAmount,
          userFullName: _currentBooking.userFullName,
          notes: _currentBooking.notes,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lịch hẹn đã được hủy thành công!')),
        );
        // Thông báo cho màn hình trước đó để làm mới dữ liệu
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error cancelling booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hủy lịch thất bại: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: valueWeight ?? FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_currentBooking.status);
    final statusText = _getStatusText(_currentBooking.status);
    final statusIcon = _getStatusIcon(_currentBooking.status);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Lịch Hẹn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, color: statusColor, size: 30),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã đặt lịch: ${_currentBooking.slug}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Booking Details Card
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
                      'Thông tin lịch hẹn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.cut_outlined,
                      'Dịch vụ',
                      _currentBooking.serviceName,
                    ),
                    _buildDetailRow(
                      Icons.storefront_outlined,
                      'Cửa hàng',
                      _currentBooking.storeName,
                    ),
                    _buildDetailRow(
                      Icons.person_outline,
                      'Nhân viên',
                      _currentBooking.employeeFullName,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.calendar_month_outlined,
                      'Ngày',
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(_currentBooking.startTime),
                    ),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Giờ',
                      '${DateFormat('HH:mm').format(_currentBooking.startTime)} - ${DateFormat('HH:mm').format(_currentBooking.endTime)}',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.monetization_on_outlined,
                      'Giá',
                      '${NumberFormat('#,###', 'vi_VN').format(_currentBooking.totalAmount)}đ',
                      valueColor: kPrimaryColor,
                      valueWeight: FontWeight.bold,
                    ),
                    if (_currentBooking.notes != null &&
                        _currentBooking.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.note,
                        'Ghi chú',
                        _currentBooking.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nút hủy lịch (chỉ hiển thị có điều kiện)
            if (_currentBooking.status.toUpperCase() == 'PENDING' ||
                _currentBooking.status.toUpperCase() == 'CONFIRMED')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCancelling ? null : _cancelBooking,
                  icon:
                      _isCancelling
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.cancel_outlined),
                  label: Text(_isCancelling ? 'Đang hủy...' : 'HỦY LỊCH HẸN'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
