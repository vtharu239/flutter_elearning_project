import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_emailotp_for_change_password.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitiateEmailOtpForPasswordChangeScreen extends StatelessWidget {
  final String email;

  const InitiateEmailOtpForPasswordChangeScreen(
      {super.key, required this.email});

  Future<void> _sendOtp(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/initiate-password-change')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Get.to(() => VerifyEmailOtpForPasswordChangeScreen(
              email: email,
              otpToken: data['otpToken'],
            ));
      } else {
        Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _sendOtp(context); // Gửi OTP ngay khi vào màn hình
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
