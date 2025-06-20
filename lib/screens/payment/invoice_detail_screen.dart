// lib/screens/payment/invoice_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';
import '../../services/api_service.dart';
import '../../utils/dialog_utils.dart'; // Sử dụng DialogUtils đã tạo trước đó
// ignore: unused_import
import 'vnpay_payment_screen.dart'; // Import màn hình thanh toán VNPAY

const Color kPrimaryColor = Color(0xFFFF6B35);

class InvoiceDetailScreen extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late Invoice _currentInvoice;
  bool _isGettingPaymentUrl = false;

  @override
  void initState() {
    super.initState();
    _currentInvoice = widget.invoice;
  }

  Future<void> _getPaymentUrlAndNavigate() async {
    setState(() {
      _isGettingPaymentUrl = true;
    });

    try {
      final paymentUrl = await ApiService.getVnpayPaymentUrl(
        _currentInvoice.invoiceId,
      );
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VnpayPaymentScreen(
                  paymentUrl: paymentUrl,
                  invoiceId: _currentInvoice.invoiceId,
                ),
          ),
        );
        // Nếu người dùng quay lại từ màn hình VNPAY, kiểm tra lại trạng thái hóa đơn
        if (result == true) {
          _refreshInvoiceStatus();
        }
      }
    } catch (e) {
      print('Lỗi khi lấy URL thanh toán: $e');
      if (mounted) {
        DialogUtils.showAlertDialog(
          context,
          'Lỗi',
          'Không thể tạo liên kết thanh toán: ${e.toString().replaceAll('Exception: ', '')}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingPaymentUrl = false;
        });
      }
    }
  }

  Future<void> _refreshInvoiceStatus() async {
    // Gọi lại API để lấy hóa đơn theo ID và cập nhật trạng thái
    try {
      // Backend của bạn hiện không có endpoint để lấy 1 hóa đơn theo ID cho người dùng,
      // mà chỉ có get all invoices.
      // Bạn có thể cần bổ sung endpoint này ở backend:
      // @GetMapping("/api/invoices/{id}/user/current")
      // Nếu không, bạn phải lấy toàn bộ danh sách và tìm hóa đơn tương ứng.
      // Tạm thời, tôi sẽ giả định có thể lấy chi tiết hóa đơn.
      // HOẶC đơn giản nhất, sau khi thanh toán thành công, bạn có thể pop true và để màn hình list refresh.

      // Nếu bạn muốn cập nhật riêng lẻ, cần có một API như thế này:
      // final updatedInvoices = await ApiService.getUserInvoices();
      // final updatedInvoice = updatedInvoices.firstWhere(
      //   (inv) => inv.invoiceId == _currentInvoice.invoiceId,
      //   orElse: () => _currentInvoice,
      // );
      // setState(() {
      //   _currentInvoice = updatedInvoice;
      // });
      // Thông báo cho màn hình trước đó để làm mới
      Navigator.pop(context, true);
    } catch (e) {
      print('Lỗi khi làm mới trạng thái hóa đơn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể làm mới trạng thái hóa đơn.'),
          ),
        );
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Chi tiết hóa đơn #${_currentInvoice.invoiceId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            // Invoice Summary Card
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hóa đơn #${_currentInvoice.invoiceId}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _currentInvoice.statusColor.withOpacity(
                              0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _currentInvoice.statusDisplay,
                            style: TextStyle(
                              color: _currentInvoice.statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildDetailRow(
                      Icons.person_outline,
                      'Khách hàng',
                      _currentInvoice.userFullName ?? '',
                    ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Ngày tạo',
                      _currentInvoice.formattedCreatedAt,
                    ),
                    _buildDetailRow(
                      Icons.money,
                      'Tổng tiền',
                      _currentInvoice.formattedTotalAmount,
                      valueColor: kPrimaryColor,
                      valueWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Appointment Details Section
            const Text(
              'Chi tiết dịch vụ đã đặt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_currentInvoice.appointmentDetails.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Không có chi tiết dịch vụ nào cho hóa đơn này.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentInvoice.appointmentDetails.length,
                itemBuilder: (context, index) {
                  final detail = _currentInvoice.appointmentDetails[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.serviceName ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Nhân viên: ${detail.employeeFullName}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Ngày: ${detail.formattedDate}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.watch_later_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Giờ: ${detail.formattedTimeRange}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              detail.formattedPrice,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            // Payment Button (conditionally displayed)
            if (_currentInvoice.status.toUpperCase() == 'PENDING')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _isGettingPaymentUrl ? null : _getPaymentUrlAndNavigate,
                  icon:
                      _isGettingPaymentUrl
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.payment),
                  label: Text(
                    _isGettingPaymentUrl
                        ? 'Đang tạo link thanh toán...'
                        : 'THANH TOÁN NGAY BẰNG VNPAY',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green[600], // Màu xanh cho nút thanh toán
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
