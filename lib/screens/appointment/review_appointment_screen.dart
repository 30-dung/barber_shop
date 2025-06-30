import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:shine_booking_app/models/appointment_model.dart';
import 'package:shine_booking_app/models/review_target_type_model.dart';
import 'package:shine_booking_app/services/api_review.dart';
import 'package:shine_booking_app/utils/dialog_utils.dart';
import 'package:shine_booking_app/services/storage_service.dart'; // Import StorageService

const Color kPrimaryColor = Color(0xFFFF6B35);

class ReviewAppointmentScreen extends StatefulWidget {
  final Appointment appointment;

  const ReviewAppointmentScreen({super.key, required this.appointment});

  @override
  State<ReviewAppointmentScreen> createState() =>
      _ReviewAppointmentScreenState();
}

class _ReviewAppointmentScreenState extends State<ReviewAppointmentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Ratings for each category
  int _storeRating = 0;
  int _serviceRating = 0;
  int _employeeRating = 0;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReviews() async {
    if (_storeRating == 0 || _serviceRating == 0 || _employeeRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá đầy đủ tất cả các mục'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final comment = _commentController.text.trim();
      final user = await StorageService.getUser(); // Lấy thông tin người dùng
      if (user == null || user.userId == null) {
        throw Exception('Không thể lấy User ID. Vui lòng đăng nhập lại.');
      }
      final int userId = user.userId!; // Lấy userId

      // Submit store review
      await ApiReviewService.createReview(
        appointmentId: widget.appointment.appointmentId!,
        targetId: widget.appointment.storeService.storeId!,
        targetType: ReviewTargetType.STORE,
        rating: _storeRating,
        comment: comment.isNotEmpty ? comment : null,
        userId: userId, // FIX: Truyền userId vào đây
      );

      // Submit service review
      await ApiReviewService.createReview(
        appointmentId: widget.appointment.appointmentId!,
        targetId: widget.appointment.storeService.storeServiceId!,
        targetType: ReviewTargetType.SERVICE,
        rating: _serviceRating,
        comment: comment.isNotEmpty ? comment : null,
        userId: userId, // FIX: Truyền userId vào đây
      );

      // Submit employee review
      await ApiReviewService.createReview(
        appointmentId: widget.appointment.appointmentId!,
        targetId: widget.appointment.employee.employeeId!,
        targetType: ReviewTargetType.EMPLOYEE,
        rating: _employeeRating,
        comment: comment.isNotEmpty ? comment : null,
        userId: userId, // FIX: Truyền userId vào đây
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá đã được gửi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi đánh giá: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildStarRating(
    String title,
    int currentRating,
    ValueChanged<int> onRatingChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    index < currentRating ? Icons.star : Icons.star_border,
                    color:
                        index < currentRating
                            ? Colors.amber
                            : Colors.grey.shade400,
                    size: 32,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nhận xét của bạn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Mô tả chi tiết trải nghiệm của bạn tại điểm này',
              hintStyle: TextStyle(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kPrimaryColor),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cuộc hẹn',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.storefront,
            'Cửa hàng',
            widget.appointment.storeService.storeName ?? '',
          ),
          _buildInfoRow(
            Icons.cut,
            'Dịch vụ',
            widget.appointment.storeService.serviceName,
          ),
          _buildInfoRow(
            Icons.person,
            'Nhân viên',
            widget.appointment.employee.fullName,
          ),
          _buildInfoRow(
            Icons.access_time,
            'Thời gian',
            '${DateFormat('dd/MM/yyyy').format(widget.appointment.startTime)} - ${DateFormat('HH:mm').format(widget.appointment.startTime)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kPrimaryColor),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Đánh Giá Cuộc Hẹn',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppointmentInfo(),

              const Text(
                'Đánh giá của bạn',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Store rating
              _buildStarRating(
                'Cửa hàng',
                _storeRating,
                (rating) => setState(() => _storeRating = rating),
              ),

              // Service rating
              _buildStarRating(
                'Dịch vụ',
                _serviceRating,
                (rating) => setState(() => _serviceRating = rating),
              ),

              // Employee rating
              _buildStarRating(
                'Nhân viên',
                _employeeRating,
                (rating) => setState(() => _employeeRating = rating),
              ),

              const SizedBox(height: 8),

              // Comment section
              _buildCommentSection(),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReviews,
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
                      _isSubmitting
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Đang gửi...'),
                            ],
                          )
                          : const Text(
                            'GỬI ĐÁNH GIÁ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
