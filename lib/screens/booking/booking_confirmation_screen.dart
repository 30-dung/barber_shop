// lib/screens/booking/booking_confirmation_screen.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/employee_model.dart';
import '../../models/store_model.dart';
import '../../models/working_time_slot_model.dart';
import '../../models/store_service_model.dart';
import '../../services/api_service.dart';
import '../home/home_screen.dart';

const Color kPrimaryColor = Color(0xFFFF6B35);

class BookingConfirmationScreen extends StatefulWidget {
  final StoreService storeService;
  final Store store;
  final Employee employee;
  final WorkingTimeSlot slot;

  const BookingConfirmationScreen({
    super.key,
    required this.storeService,
    required this.store,
    required this.employee,
    required this.slot,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    try {
      final int storeServiceId = widget.storeService.storeServiceId;

      log('Confirming booking with:');
      log('- timeSlotId: ${widget.slot.timeSlotId}');
      log('- storeServiceId: $storeServiceId');
      log('- startTime: ${widget.slot.startTime}');
      log('- endTime: ${widget.slot.endTime}');
      log('- notes: ${_notesController.text}');

      // Call the API service to create the appointment
      final result = await ApiService.createAppointment(
        timeSlotId: widget.slot.timeSlotId,
        storeServiceId: storeServiceId,
        startTime: widget.slot.startTime,
        endTime: widget.slot.endTime,
        notes:
            _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
      );

      log('Booking created successfully: $result');

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 22),
                    const SizedBox(width: 8),
                    // FIX: Wrap Text with Expanded to prevent overflow
                    Expanded(child: Text('Đặt lịch thành công!')),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cảm ơn bạn đã đặt lịch hẹn!'),
                    const SizedBox(height: 8),
                    const Text(
                      'Chi tiết cuộc hẹn:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Dịch vụ: ${widget.storeService.service.serviceName}',
                    ),
                    Text(
                      '• Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(widget.slot.startTime))}',
                    ),
                    Text('• Cửa hàng: ${widget.store.name}'),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng kiểm tra mục "Lịch hẹn của tôi" để xem chi tiết.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Navigate back to the home screen and clear the navigation stack
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'VỀ TRANG CHỦ',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      log('Booking confirmation failed: $e');
      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 28),
                    const SizedBox(width: 8),
                    // FIX: Wrap Text with Expanded to prevent overflow
                    Expanded(child: Text('Đặt lịch thất bại')),
                  ],
                ),
                content: Text(
                  'Đã xảy ra lỗi khi đặt lịch: ${e.toString().replaceAll('Exception: ', '')}',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('THỬ LẠI'),
                  ),
                ],
              ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác Nhận Lịch Hẹn'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildNotesField(),
        ],
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi Tiết Lịch Hẹn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.cut_outlined,
              'Dịch vụ',
              widget.storeService.service.serviceName,
            ),
            _buildDetailRow(
              Icons.storefront_outlined,
              'Cửa hàng',
              widget.store.name,
            ),
            _buildDetailRow(
              Icons.person_outline,
              'Thực hiện bởi',
              widget.employee.fullName,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.calendar_month_outlined,
              'Ngày',
              DateFormat(
                'dd/MM/yyyy',
              ).format(DateTime.parse(widget.slot.startTime)),
            ),
            _buildDetailRow(
              Icons.access_time_outlined,
              'Giờ',
              '${DateFormat('HH:mm').format(DateTime.parse(widget.slot.startTime))} - ${DateFormat('HH:mm').format(DateTime.parse(widget.slot.endTime))}',
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.monetization_on_outlined,
              'Giá',
              '${NumberFormat('#,###', 'vi_VN').format(widget.storeService.price)}đ',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ghi chú (tùy chọn)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Ví dụ: tôi muốn thợ cắt chính, tôi bị dị ứng...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '${NumberFormat('#,###', 'vi_VN').format(widget.storeService.price)}đ',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                      : const Text(
                        'XÁC NHẬN & ĐẶT LỊCH',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
