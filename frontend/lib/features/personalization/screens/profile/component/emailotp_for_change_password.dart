import 'dart:convert';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_emailotp_for_change_password.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitiateEmailOtpForPasswordChangeScreen extends StatefulWidget {
  final String email;

  const InitiateEmailOtpForPasswordChangeScreen({
    super.key,
    required this.email,
  });

  @override
  State<InitiateEmailOtpForPasswordChangeScreen> createState() =>
      _InitiateEmailOtpForPasswordChangeScreenState();
}

class _InitiateEmailOtpForPasswordChangeScreenState
    extends State<InitiateEmailOtpForPasswordChangeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Gửi OTP khi màn hình khởi tạo
  }

  Future<void> _sendOtp() async {
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
        Get.off(() => VerifyEmailOtpForPasswordChangeScreen(
              email: widget.email,
              otpToken: data['otpToken'],
            ));
      } else {
        Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã xảy ra lỗi khi gửi OTP'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _sendOtp();
                    },
                    child: const Text('Thử lại'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.offUntil(
                        GetPageRoute(page: () => const ProfileScreen()),
                        (route) =>
                            route.isFirst ||
                            route.settings.name == '/ProfileScreen',
                      );
                    },
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
      ),
    );
  }
}