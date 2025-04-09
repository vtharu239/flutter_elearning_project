import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';

class VerifyEmailOtpScreen extends StatefulWidget {
  final String newEmail;
  final String otpToken;

  const VerifyEmailOtpScreen({
    super.key,
    required this.newEmail,
    required this.otpToken,
  });

  @override
  VerifyEmailOtpScreenState createState() => VerifyEmailOtpScreenState();
}

class VerifyEmailOtpScreenState extends State<VerifyEmailOtpScreen> {
  String verificationCode = '';
  bool isLoading = false;
  int _secondsRemaining = 60;
  bool _isTimerActive = false;
  Timer? _timer;
  late String otpToken;

  @override
  void initState() {
    super.initState();
    otpToken = widget.otpToken;
    _startOtpTimer();
  }

  void _startOtpTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _isTimerActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isTimerActive = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendOtp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.initiateEmailChange)),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newEmail': widget.newEmail}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          otpToken = data['otpToken'];
        });
        _startOtpTimer();
        Get.snackbar('Thành công', 'Mã OTP đã được gửi lại!');
      } else {
        Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi lại OTP: $e');
    }
  }

  Future<void> _completeEmailChange() async {
    if (verificationCode.length != 6) {
      Get.snackbar('Lỗi', 'Vui lòng nhập mã OTP 6 chữ số hợp lệ');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.completeEmailChange)),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otpToken': otpToken,
          'otp': verificationCode,
        }),
      );

      if (response.statusCode == 200) {
        Get.find<AuthController>().refreshUserData();
        Get.back(); // This will go back to previous screen
        Get.back(); // This will go back to ProfileScreen
        Get.back(); // This will go back to ProfileScreen
        Get.snackbar('Thành công', 'Cập nhật email thành công!');
      } else {
        Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xác minh OTP: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
      appBar: TAppBar(
        title: const Text('Xác minh OTP'),
        showBackArrow: true,
        padding: EdgeInsets.symmetric(horizontal: 6.0),
        leadingOnPressed: () {
          Get.back();
          Get.back();
          Get.back();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.labelLarge, // Kiểu chữ chung
                children: [
                  const TextSpan(
                    text: 'Nhập mã OTP đã gửi đến ',
                  ),
                  TextSpan(
                    text: widget.newEmail, // Phần có màu xanh
                    style: const TextStyle(color: Color(0xFF00A2FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) => setState(() => verificationCode = value),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isTimerActive
                      ? 'Gửi lại mã sau $_secondsRemaining giây'
                      : 'Chưa nhận được mã?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!_isTimerActive)
                  TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Gửi lại mã OTP',
                      style: TextStyle(color: Color(0xFF00A2FF)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 10), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                onPressed: isLoading ? null : _completeEmailChange,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
