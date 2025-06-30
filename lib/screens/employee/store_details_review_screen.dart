import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/store_model.dart';
import '../../../models/review_model.dart'; // Import Review model
import '../../../models/review_summary_model.dart'; // Import ReviewSummaryModel
import '../../../services/api_review.dart'; // Import ApiReviewService
import '../../../utils/dialog_utils.dart'; // Import DialogUtils for snackbars/dialogs
import 'package:shine_booking_app/models/user_model.dart'; // Import User model for reply.user

class StoreDetailScreen extends StatefulWidget {
  final Store store;
  const StoreDetailScreen({super.key, required this.store});

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  ReviewSummaryModel? _reviewSummary;
  List<Review> _detailedReviews = [];
  bool _isLoadingSummary = true;
  bool _isLoadingDetailedReviews = true;
  final Map<int, TextEditingController> _replyControllers = {};
  final Map<int, bool> _showReplyInput = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_fetchReviewSummary(), _fetchDetailedReviews()]);
  }

  Future<void> _fetchReviewSummary() async {
    setState(() => _isLoadingSummary = true);
    try {
      _reviewSummary = await ApiReviewService.getStoreReviewSummary(
        widget.store.storeId!,
      );
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingSummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải tóm tắt đánh giá: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _fetchDetailedReviews() async {
    setState(() => _isLoadingDetailedReviews = true);
    _disposeReplyControllers(); // Dispose old controllers before fetching new data

    try {
      _detailedReviews = await ApiReviewService.getReviewsByStoreId(
        widget.store.storeId!,
      );
      if (mounted) {
        setState(() {
          _isLoadingDetailedReviews = false;
        });
        // Initialize new controllers for each fetched review
        for (var review in _detailedReviews) {
          _replyControllers[review.reviewId] = TextEditingController();
          _showReplyInput[review.reviewId] =
              false; // Initially hide all reply inputs
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _detailedReviews = [];
          _isLoadingDetailedReviews = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải đánh giá chi tiết: ${e.toString()}')),
        );
      }
    }
  }

  // Dispose all controllers in the map
  void _disposeReplyControllers() {
    _replyControllers.forEach((key, controller) {
      controller.dispose();
    });
    _replyControllers.clear();
    _showReplyInput.clear();
  }

  void _toggleReplyInput(int reviewId) {
    setState(() {
      _showReplyInput[reviewId] = !(_showReplyInput[reviewId] ?? false);
      if (!(_showReplyInput[reviewId] ?? false)) {
        // If hiding, clear the text
        _replyControllers[reviewId]?.clear();
      }
    });
  }

  Future<void> _submitReply(int reviewId) async {
    final controller = _replyControllers[reviewId];
    if (controller == null || controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung trả lời.')),
      );
      return;
    }

    try {
      await ApiReviewService.replyToReview(reviewId, controller.text.trim());
      if (mounted) {
        controller.clear();
        setState(() {
          _showReplyInput[reviewId] =
              false; // Hide input after successful reply
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trả lời đã được gửi thành công!')),
        );
        _fetchDetailedReviews(); // Refresh detailed reviews to show new reply
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi trả lời: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _disposeReplyControllers(); // Ensure all controllers are disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(store.storeName ?? 'Chi tiết cửa hàng'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        // Add RefreshIndicator for pull-to-refresh
        onRefresh: _fetchData,
        color: const Color(0xFFFF6B35),
        child:
            _isLoadingSummary || _isLoadingDetailedReviews
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Store Info Header
                    _buildStoreHeader(store),
                    const SizedBox(height: 24), // Spacer
                    // Stats Overview
                    if (_reviewSummary != null) _buildStatsOverview(),
                    const SizedBox(height: 24), // Spacer
                    // Rating Distribution
                    if (_reviewSummary != null &&
                        _reviewSummary!.ratingDistribution != null &&
                        _reviewSummary!.ratingDistribution!.isNotEmpty)
                      _buildRatingDistribution(
                        _reviewSummary!.ratingDistribution!,
                      ),
                    const SizedBox(height: 24), // Spacer
                    // Employee Ratings
                    if (_reviewSummary != null &&
                        _reviewSummary!.employeeRatings != null &&
                        _reviewSummary!.employeeRatings!.isNotEmpty)
                      _buildEmployeeRatings(_reviewSummary!.employeeRatings!),
                    const SizedBox(height: 24), // Spacer
                    // Service Ratings
                    if (_reviewSummary != null &&
                        _reviewSummary!.serviceRatings != null &&
                        _reviewSummary!.serviceRatings!.isNotEmpty)
                      _buildServiceRatings(_reviewSummary!.serviceRatings!),
                    const SizedBox(height: 24), // Spacer
                    // Detailed Reviews List
                    const Text(
                      'Chi tiết đánh giá của khách hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_detailedReviews.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có đánh giá chi tiết nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ..._detailedReviews.map(
                        (review) => Column(
                          children: [
                            _buildReviewItem(review),
                            if (review != _detailedReviews.last)
                              const Divider(
                                height: 32,
                              ), // Add divider between reviews
                          ],
                        ),
                      ),
                  ],
                ),
      ),
    );
  }

  Widget _buildStoreHeader(Store store) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF6B35), Color(0xFFFF8A65)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Store Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child:
                    store.storeImages != null && store.storeImages!.isNotEmpty
                        ? Image.network(
                          store.storeImages!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.store,
                                  size: 50,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                        )
                        : Container(
                          color: Colors.white,
                          child: const Icon(
                            Icons.store,
                            size: 50,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),

            // Store Name
            Text(
              store.storeName ?? 'Tên cửa hàng',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Address
            Text(
              store.cityProvince != null
                  ? '${store.cityProvince}, ${store.district ?? ''}'
                  : 'Chưa có địa chỉ',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Rating Badge (from ReviewSummaryModel)
            if (_reviewSummary != null && _reviewSummary!.averageRating != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${_reviewSummary!.averageRating?.toStringAsFixed(1)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${_reviewSummary!.totalReviews} đánh giá)',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin cửa hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.description,
            'Mô tả',
            widget.store.description ?? 'Chưa có mô tả',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.access_time,
            'Giờ hoạt động',
            widget.store.openingTime != null
                ? 'Mở cửa: ${widget.store.openingTime} - ${widget.store.closingTime}'
                : 'Chưa có giờ mở cửa',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF6B35)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(Map<String, int> distribution) {
    final sortedKeys =
        distribution.keys.toList()
          ..sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    final total = distribution.values.fold(0, (sum, count) => sum + count);

    if (total == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phân phối đánh giá',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedKeys.map((star) {
            final count = distribution[star] ?? 0;
            final percentage = total > 0 ? (count / total) : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Row(
                      children: [
                        Text(
                          star,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: percentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmployeeRatings(List<EmployeeRatingSummary> employeeRatings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá nhân viên',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...employeeRatings.map((employee) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        employee.avatarUrl != null &&
                                employee.avatarUrl!.isNotEmpty
                            ? NetworkImage(employee.avatarUrl!)
                            : null,
                    backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
                    child:
                        employee.avatarUrl == null ||
                                employee.avatarUrl!.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 20,
                              color: Color(0xFFFF6B35),
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.employeeName ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${employee.totalReviews ?? 0} đánh giá',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${employee.averageRating?.toStringAsFixed(1) ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceRatings(List<ServiceRatingSummary> serviceRatings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá dịch vụ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...serviceRatings.map((service) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.build,
                      size: 20,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.serviceName ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${service.totalReviews ?? 0} đánh giá',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${service.averageRating?.toStringAsFixed(1) ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá từ khách hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (_detailedReviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có đánh giá chi tiết nào',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_detailedReviews.length, (index) {
              final review = _detailedReviews[index];
              final isLast = index == _detailedReviews.length - 1;

              return Column(
                children: [
                  _buildReviewItem(review),
                  if (!isLast) const Divider(height: 32),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Review Header
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFFF6B35).withOpacity(0.1),
              child: Text(
                // FIX: Check if reviewer and fullName are not null
                review.reviewer?.fullName?.isNotEmpty == true
                    ? review.reviewer!.fullName![0].toUpperCase()
                    : 'K',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewer?.fullName ??
                        'Ẩn danh', // FIX: Handle null reviewer or fullName
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).format(review.createdAt.toLocal()),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${review.storeRating}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Appointment Info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Mã cuộc hẹn: ${review.appointmentSlug}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ),
        const SizedBox(height: 12),

        // Comment
        if (review.comment != null && review.comment!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              review.comment!,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        const SizedBox(height: 12),

        // Rating Details
        if (review.employeeName != null || review.serviceName != null)
          Row(
            children: [
              if (review.employeeName != null && review.employeeRating != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            review.employeeName!,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${review.employeeRating}⭐',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (review.employeeName != null && review.serviceName != null)
                const SizedBox(width: 8),
              if (review.serviceName != null && review.serviceRating != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.build, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            review.serviceName!,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${review.serviceRating}⭐',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

        // Replies
        if (review.replies != null && review.replies!.isNotEmpty)
          ...review.replies!.map(
            (reply) => Container(
              margin: const EdgeInsets.only(top: 12, left: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.store,
                        size: 16,
                        color: Color(0xFFFF6B35),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        reply.user?.fullName ??
                            'Cửa hàng', // FIX: Handle null user
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                      const Spacer(),
                      if (reply.createdAt != null)
                        Text(
                          DateFormat(
                            'dd/MM HH:mm',
                          ).format(reply.createdAt!.toLocal()),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reply.comment,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),
          ),

        // Reply Input Section
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toggleReplyInput(review.reviewId),
                icon: Icon(
                  _showReplyInput[review.reviewId] == true
                      ? Icons.keyboard_arrow_up
                      : Icons.reply,
                  size: 16,
                ),
                label: Text(
                  _showReplyInput[review.reviewId] == true
                      ? 'Ẩn trả lời'
                      : 'Trả lời khách hàng',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF6B35),
                  side: const BorderSide(color: Color(0xFFFF6B35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Reply Input Field
        if (_showReplyInput[review.reviewId] == true)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _replyControllers[review.reviewId],
                  decoration: const InputDecoration(
                    hintText: 'Nhập phản hồi của bạn...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => _toggleReplyInput(review.reviewId),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _submitReply(review.reviewId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Gửi phản hồi',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
