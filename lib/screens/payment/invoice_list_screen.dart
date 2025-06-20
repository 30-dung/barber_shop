// lib/screens/payment/invoice_list_screen.dart
import 'package:flutter/material.dart';
import '../../models/invoice_model.dart';
import '../../services/api_service.dart';
import 'invoice_detail_screen.dart'; // Import màn hình chi tiết hóa đơn

const Color kPrimaryColor = Color(0xFFFF6B35);

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInvoices(); // Tải hóa đơn khi khởi tạo
  }

  Future<void> _loadInvoices() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final invoices =
          await ApiService.getUserInvoices(); // Lấy tất cả hóa đơn từ API
      // Sắp xếp hóa đơn: PENDING lên đầu, sau đó là các trạng thái khác,
      // trong mỗi trạng thái, sắp xếp theo ngày tạo mới nhất
      invoices.sort((a, b) {
        final statusOrder = {'PENDING': 0, 'PAID': 1, 'CANCELLED': 2};
        final orderA = statusOrder[a.status.toUpperCase()] ?? 99;
        final orderB = statusOrder[b.status.toUpperCase()] ?? 99;

        if (orderA != orderB) {
          return orderA.compareTo(orderB);
        }
        return b.createdAt.compareTo(
          a.createdAt,
        ); // Sắp xếp giảm dần theo thời gian tạo
      });

      if (mounted) {
        setState(() {
          _invoices = invoices; // Gán danh sách hóa đơn đã lấy (tất cả)
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách hóa đơn: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // Phương thức _buildInvoiceCard không thay đổi
  Widget _buildInvoiceCard(Invoice invoice) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceDetailScreen(invoice: invoice),
          ),
        );
        // Làm mới danh sách hóa đơn nếu màn hình chi tiết báo có thay đổi (ví dụ: thanh toán thành công)
        if (result == true) {
          _loadInvoices();
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hóa đơn #${invoice.invoiceId}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: invoice.statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      invoice.statusDisplay,
                      style: TextStyle(
                        color: invoice.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Ngày tạo: ${invoice.formattedCreatedAt}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Text(
                    invoice.formattedTotalAmount,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Nút Thanh toán chỉ hiển thị nếu trạng thái là PENDING
              if (invoice.status.toUpperCase() == 'PENDING')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  InvoiceDetailScreen(invoice: invoice),
                        ),
                      );
                      if (result == true) {
                        _loadInvoices();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Thanh toán ngay',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.receipt_long, size: 50, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có hóa đơn nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa có hóa đơn nào.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) => route.isFirst,
              ); // Về trang chủ
            },
            icon: const Icon(Icons.home),
            label: const Text('Về trang chủ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Không thể tải danh sách hóa đơn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadInvoices,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
        title: const Text(
          'Hóa đơn của tôi', // Tiêu đề hiển thị tất cả hóa đơn
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: kPrimaryColor),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải danh sách hóa đơn...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : _errorMessage != null
              ? _buildErrorState()
              : _invoices.isEmpty
              ? _buildEmptyState() // Trạng thái rỗng cho trường hợp không có hóa đơn nào
              : RefreshIndicator(
                onRefresh: _loadInvoices,
                color: kPrimaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _invoices.length,
                  itemBuilder: (context, index) {
                    return _buildInvoiceCard(_invoices[index]);
                  },
                ),
              ),
    );
  }
}
