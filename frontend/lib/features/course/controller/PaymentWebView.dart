import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter_elearning_project/features/course/controller/PaymentService.dart';
import 'package:app_links/app_links.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final int orderId;
  final int courseId;
  final Function(bool) onPaymentComplete;

  const PaymentWebView({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    required this.courseId,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  late AppLinks _appLinks; // Use AppLinks
  StreamSubscription<Uri>? _linkSubscription;
  Timer? _pollingTimer;
  bool _hasNavigated = false;
  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _launchUrlInBrowser();
    } else {
      _initializeWebView();
      _initDeepLinkListener(); // Listen for deep links on Android/iOS
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Initialize deep link listener for Android/iOS
  void _initDeepLinkListener() async {
    _appLinks = AppLinks();

    // Handle initial deep link (if the app was opened via a deep link)
    try {
      final uri =
          await _appLinks.getInitialLink(); // Fixed: Use getInitialLink()
      if (uri != null) {
        _handleDeepLink(uri);
      }
    } catch (e) {
      log('Error getting initial link: $e');
    }

    // Listen for incoming deep links
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      log('Error listening for deep links: $err');
      _navigateToCourseDetailScreen(false);
    });
  }

  // Handle deep link
  void _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'myapp' &&
        uri.host == 'payment-result' &&
        !_hasNavigated) {
      final orderId = int.tryParse(uri.queryParameters['orderId'] ?? '');
      final responseCode = uri.queryParameters['vnp_ResponseCode'];
      if (orderId != null && orderId == widget.orderId) {
        // Verify the payment status with the backend
        try {
          final paymentService = PaymentService();
          final orderInfo = await paymentService.getOrderInfo(widget.orderId);
          log('Order info from deep link: $orderInfo');
          if (orderInfo['status'] == 'completed' || responseCode == '00') {
            setState(() => _hasNavigated = true);
            _navigateToCourseDetailScreen(true);
          } else {
            setState(() => _hasNavigated = true);
            _navigateToCourseDetailScreen(false);
          }
        } catch (e) {
          log('Error verifying payment status: $e');
          setState(() => _hasNavigated = true);
          _navigateToCourseDetailScreen(false);
        }
      }
    }
  }

  Future<void> _launchUrlInBrowser() async {
    final Uri uri = Uri.parse(widget.paymentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Start polling as a fallback in case deep linking fails
      _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        try {
          final paymentService = PaymentService();
          final orderInfo = await paymentService.getOrderInfo(widget.orderId);
          if (orderInfo['status'] == 'completed') {
            timer.cancel();
            _navigateToCourseDetailScreen(true);
          } else if (orderInfo['status'] == 'failed') {
            timer.cancel();
            _navigateToCourseDetailScreen(false);
          }
        } catch (e) {
          log('Error polling order status: $e');
          timer.cancel();
          _navigateToCourseDetailScreen(false);
        }
      });
    } else {
      log('Could not launch ${widget.paymentUrl}');
      _navigateToCourseDetailScreen(false);
    }
  }

  void _initializeWebView() {
    _initializeWebViewPlatform();

    late final PlatformWebViewControllerCreationParams params;
    if (Platform.isAndroid) {
      params = AndroidWebViewControllerCreationParams();
    } else if (Platform.isIOS) {
      //  params = WKWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = true;
            });
            log('Redirect URL: $url'); // Log URL để kiểm tra

            if (url.contains('vnpay-return') && !_hasNavigated) {
              try {
                final uri = Uri.parse(url);
                final responseCode = uri.queryParameters['vnp_ResponseCode'];
                final orderId =
                    int.tryParse(uri.queryParameters['vnp_TxnRef'] ?? '');
                log('Response Code: $responseCode, Order ID: $orderId');

                if (orderId != null && orderId == widget.orderId) {
                  final paymentService = PaymentService();
                  final orderInfo =
                      await paymentService.getOrderInfo(widget.orderId);
                  log('Order Info: $orderInfo');
                  if (orderInfo['status'] == 'completed' ||
                      responseCode == '00') {
                    if (mounted && !_hasNavigated) {
                      _hasNavigated = true; // Đánh dấu đã chuyển màn hình
                      _navigateToCourseDetailScreen(true);
                    }
                  } else {
                    if (mounted) {
                      _hasNavigated = true; // Đánh dấu đã chuyển màn hình
                      _navigateToCourseDetailScreen(false);
                    }
                  }
                }
              } catch (e) {
                log('Error processing payment return: $e');
                if (mounted) {
                  _navigateToCourseDetailScreen(false);
                }
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView error: ${error.description}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Failed to load payment page: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
            _navigateToCourseDetailScreen(false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

// Hàm retry để chờ backend cập nhật
  Future<void> checkOrderStatusWithRetry(int orderId, {int retries = 5}) async {
    for (int i = 0; i < retries; i++) {
      final orderInfo = await PaymentService().getOrderInfo(orderId);
      log('Retry $i: $orderInfo');
      if (orderInfo['status'] == 'completed') {
        _navigateToCourseDetailScreen(true);
        return;
      } else if (orderInfo['status'] == 'failed') {
        _navigateToCourseDetailScreen(false);
        return;
      }
      await Future.delayed(Duration(seconds: 2)); // Chờ 2 giây
    }
    _navigateToCourseDetailScreen(false); // Hết retries, coi như thất bại
  }

  void _initializeWebViewPlatform() {
    if (kIsWeb) {
      //WebViewPlatform.instance = WebWebViewPlatform();
    } else if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (Platform.isIOS) {
      // WebViewPlatform.instance = WKWebViewPlatform();
    }
  }

  void _navigateToCourseDetailScreen(bool success) {
    widget.onPaymentComplete(success);
    Navigator.of(context).pop(success);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPaymentComplete(false);
            },
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang mở trang thanh toán trong trình duyệt...',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng quay lại ứng dụng sau khi hoàn tất thanh toán.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
            widget.onPaymentComplete(false);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
