import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/appointment_model.dart';
import '../../services/api_appointments.dart';
import '../../utils/dialog_utils.dart';
import 'review_appointment_screen.dart'; // Import the new review screen
import '../../services/api_review.dart'; // Import ApiReviewService
import '../employee/store_details_review_screen.dart'; // Import StoreDetailScreen
import '../../services/api_service.dart'; // Import ApiService to get Store by ID

const Color kPrimaryColor = Color(0xFFFF6B35);

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Appointment _currentAppointment;
  bool _isCancelling = false;
  bool _hasReviewed = false; // State to track if reviewed
  bool _isLoadingReviewStatus = true; // New state for loading review status

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.appointment;
    _checkIfReviewed(); // Check on init
  }

  // Check if the appointment has already been reviewed
  Future<void> _checkIfReviewed() async {
    if (_currentAppointment.appointmentId == null) {
      setState(() {
        _isLoadingReviewStatus = false;
        _hasReviewed = false;
      });
      return;
    }

    setState(() {
      _isLoadingReviewStatus = true;
    });

    try {
      final bool exists =
          await ApiReviewService.checkReviewExistsForAppointment(
            _currentAppointment.appointmentId!,
          );
      if (mounted) {
        setState(() {
          _hasReviewed = exists;
          _isLoadingReviewStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviewStatus = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kiểm tra trạng thái đánh giá: $e')),
        );
      }
    }
  }

  Color _getStatusColor(Status status) {
    switch (status) {
      case Status.PENDING:
        return Colors.orange;
      case Status.CONFIRMED:
        return Colors.blue;
      case Status.COMPLETED:
        return Colors.green;
      case Status.CANCELED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(Status status) {
    switch (status) {
      case Status.PENDING:
        return 'Chờ xác nhận';
      case Status.CONFIRMED:
        return 'Đã xác nhận';
      case Status.COMPLETED:
        return 'Hoàn thành';
      case Status.CANCELED:
        return 'Đã hủy';
      default:
        return status.toString();
    }
  }

  IconData _getStatusIcon(Status status) {
    switch (status) {
      case Status.PENDING:
        return Icons.schedule;
      case Status.CONFIRMED:
        return Icons.check_circle_outline;
      case Status.COMPLETED:
        return Icons.check_circle;
      case Status.CANCELED:
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Future<void> _cancelAppointment() async {
    final bool? confirm = await DialogUtils.showConfirmationDialog(
      context,
      'Xác nhận hủy lịch hẹn?',
      'Bạn có chắc chắn muốn hủy lịch hẹn này? Thao tác này không thể hoàn tác.',
      confirmButtonText: 'Hủy lịch',
      cancelButtonText: 'Không',
    );

    if (confirm != true) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await ApiAppointmentsService.cancelAppointment(
        _currentAppointment.appointmentId!,
      );
      setState(() {
        _currentAppointment = _currentAppointment.copyWith(
          status: Status.CANCELED,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lịch hẹn đã được hủy thành công!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
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

  Future<void> _navigateToReviewScreen() async {
    final bool? reviewed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ReviewAppointmentScreen(appointment: _currentAppointment),
      ),
    );

    if (reviewed == true) {
      setState(() {
        _hasReviewed = true; // Cập nhật trạng thái đã đánh giá
      });
      Navigator.pop(context, true);
    }
  }

  Future<void> _navigateToStoreReviewSummary() async {
    if (_currentAppointment.storeService.storeId != null) {
      try {
        // Lấy thông tin Store đầy đủ trước khi điều hướng
        final store = await ApiService.getStoreById(
          _currentAppointment.storeService.storeId!,
        );
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => StoreDetailScreen(
                    store: store, // Truyền đối tượng Store đầy đủ
                  ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể tải chi tiết cửa hàng: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có thông tin cửa hàng để xem đánh giá.'),
        ),
      );
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
    final statusColor = _getStatusColor(_currentAppointment.status);
    final statusText = _getStatusText(_currentAppointment.status);
    final statusIcon = _getStatusIcon(_currentAppointment.status);

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
                        'Mã đặt lịch: ${_currentAppointment.slug}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Appointment Details Card
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
                      _currentAppointment.storeService.serviceName,
                    ),
                    _buildDetailRow(
                      Icons.storefront_outlined,
                      'Cửa hàng',
                      _currentAppointment.storeService.storeName ?? '',
                    ),
                    _buildDetailRow(
                      Icons.person_outline,
                      'Nhân viên',
                      _currentAppointment.employee.fullName,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.calendar_month_outlined,
                      'Ngày',
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(_currentAppointment.startTime),
                    ),
                    _buildDetailRow(
                      Icons.access_time_outlined,
                      'Giờ',
                      '${DateFormat('HH:mm').format(_currentAppointment.startTime)} - ${DateFormat('HH:mm').format(_currentAppointment.endTime)}',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.monetization_on_outlined,
                      'Giá',
                      _currentAppointment.invoice != null
                          ? '${NumberFormat('#,###', 'vi_VN').format(_currentAppointment.invoice!.totalAmount)}đ'
                          : 'Chưa có',
                      valueColor: kPrimaryColor,
                      valueWeight: FontWeight.bold,
                    ),
                    if (_currentAppointment.notes != null &&
                        _currentAppointment.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        Icons.note,
                        'Ghi chú',
                        _currentAppointment.notes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons (Cancel/Review/View Review)
            if (_currentAppointment.status == Status.PENDING ||
                _currentAppointment.status == Status.CONFIRMED)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCancelling ? null : _cancelAppointment,
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
            if (_currentAppointment.status == Status.COMPLETED)
              _isLoadingReviewStatus // Show loading for review status
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                  : !_hasReviewed
                  ? Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToReviewScreen,
                        icon: const Icon(Icons.star),
                        label: const Text('ĐÁNH GIÁ CUỘC HẸN'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  )
                  : Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            _navigateToStoreReviewSummary, // Điều hướng đến màn hình chi tiết đánh giá
                        icon: const Icon(Icons.rate_review),
                        label: const Text('XEM ĐÁNH GIÁ CỬA HÀNG'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
