// lib/screens/payment/vnpay_payment_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../constants/app_constants.dart'; // Để lấy Base URL nếu cần check redirect
import '../../utils/dialog_utils.dart'; // Để hiển thị thông báo kết quả

const Color kPrimaryColor = Color(0xFFFF6B35);

class VnpayPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final int invoiceId;

  const VnpayPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.invoiceId,
  });

  @override
  State<VnpayPaymentScreen> createState() => _VnpayPaymentScreenState();
}

class _VnpayPaymentScreenState extends State<VnpayPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoadingPage = true;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              _isLoadingPage = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              _isLoadingPage = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
            ''');
            if (mounted) {
              DialogUtils.showAlertDialog(
                context,
                'Lỗi tải trang',
                'Không thể tải trang thanh toán. Vui lòng thử lại. Lỗi: ${error.description}',
              ).then(
                (_) => Navigator.pop(context, false),
              ); // Quay lại và báo thất bại
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Đây là logic quan trọng để xử lý các URL redirect của VNPAY
            // Khi VNPAY hoàn tất thanh toán, nó sẽ redirect về VNP_RETURN_URL của bạn.
            // URL này sẽ chứa các tham số như status=success/fail, invoiceId, v.v.
            debugPrint('Navigating to: ${request.url}');
            if (request.url.startsWith(
              '${AppConstants.baseUrl}/api/payment/return',
            )) {
              // Lắng nghe URL trả về từ backend của bạn (VNP_RETURN_URL)
              // URL này sẽ được backend của bạn xử lý và sau đó redirect browser.
              // Chúng ta cần lấy các query params để xác định kết quả thanh toán.
              final uri = Uri.parse(request.url);
              final status = uri.queryParameters['status'];
              final returnedInvoiceId = uri.queryParameters['invoiceId'];

              debugPrint(
                'VNPAY return URL detected. Status: $status, InvoiceId: $returnedInvoiceId',
              );

              // Dựa vào status từ URL để thông báo kết quả
              if (status == 'success' &&
                  returnedInvoiceId == widget.invoiceId.toString()) {
                // Thanh toán thành công
                DialogUtils.showAlertDialog(
                  context,
                  'Thanh toán thành công',
                  'Hóa đơn #${widget.invoiceId} đã được thanh toán.',
                ).then((_) {
                  Navigator.pop(
                    context,
                    true,
                  ); // Pop với true để báo thành công
                });
              } else {
                // Thanh toán thất bại hoặc có lỗi
                final reason =
                    uri.queryParameters['reason'] ?? 'Không rõ nguyên nhân';
                DialogUtils.showAlertDialog(
                  context,
                  'Thanh toán thất bại',
                  'Hóa đơn #${widget.invoiceId} thanh toán không thành công. Lý do: $reason',
                ).then((_) {
                  Navigator.pop(
                    context,
                    false,
                  ); // Pop với false để báo thất bại
                });
              }
              return NavigationDecision
                  .prevent; // Ngăn WebView tải tiếp URL này
            }
            return NavigationDecision
                .navigate; // Cho phép WebView tải các URL khác
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message.message)));
        },
      );

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setTextZoom(
        100,
      ); // Đặt lại zoom cho Android
    }

    controller.loadRequest(Uri.parse(widget.paymentUrl));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thanh toán VNPAY',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoadingPage)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: kPrimaryColor),
                  SizedBox(height: 10),
                  Text(
                    'Đang tải trang thanh toán...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
