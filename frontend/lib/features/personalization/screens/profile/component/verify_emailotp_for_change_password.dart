import 'dart:async';
import 'dart:convert';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/new_password_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyEmailOtpForPasswordChangeScreen extends StatefulWidget {
  final String email;
  final String otpToken;

  const VerifyEmailOtpForPasswordChangeScreen({
    super.key,
    required this.email,
    required this.otpToken,
  });

  @override
  VerifyEmailOtpForPasswordChangeScreenState createState() =>
      VerifyEmailOtpForPasswordChangeScreenState();
}

class VerifyEmailOtpForPasswordChangeScreenState
    extends State<VerifyEmailOtpForPasswordChangeScreen> {
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
        Uri.parse(ApiConstants.getUrl('/profile/initiate-password-change')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': widget.email}),
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

  Future<void> _verifyOtp() async {
    if (verificationCode.length != 6) {
      Get.snackbar('Lỗi', 'Vui lòng nhập mã OTP 6 chữ số hợp lệ');
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/verify-password-otp')),
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
        final data = jsonDecode(response.body);
        Get.to(() => NewPasswordScreen(idToken: data['idToken']));
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
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: darkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
            Get.back();
          },
        ),
        title: const Text('Xác minh OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),
            Text(
              'Nhập mã OTP đã gửi đến ${widget.email}',
              style: Theme.of(context).textTheme.labelLarge,
              textAlign: TextAlign.center,
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
                activeFillColor: darkMode ? Colors.grey[800] : Colors.white,
                inactiveFillColor: darkMode ? Colors.grey[800] : Colors.white,
                selectedFillColor:
                    darkMode ? Colors.grey[700] : Colors.grey[200],
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
                selectedColor: Colors.blue,
              ),
              enableActiveFill: true,
              keyboardType: TextInputType.number,
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
                    child: const Text('Gửi lại mã OTP'),
                  ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verifyOtp,
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