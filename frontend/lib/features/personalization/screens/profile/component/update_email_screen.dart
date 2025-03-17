import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_email_otp_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  UpdateEmailScreenState createState() => UpdateEmailScreenState();
}

class UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _otpToken;

  Future<void> _initiateEmailChange() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.initiateEmailChange)),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newEmail': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _otpToken = data['otpToken'];
        });
        Get.to(() => VerifyEmailOtpScreen(
              newEmail: _emailController.text.trim(),
              otpToken: _otpToken!,
            ));
      } else {
        Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi yêu cầu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      appBar: AppBar(
        title: const Text('Nhập email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email của bạn có thể sẽ được sử dụng để kết nối bạn với những người bạn có thể biết, truy cập các khóa học, v.v, tùy vào cài đặt của bạn.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Nhập email mới',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _initiateEmailChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF00A2FF), // Màu xanh #00A2FF
                    foregroundColor: Colors.white, // Màu chữ trắng
                    padding: const EdgeInsets.symmetric(
                        vertical: 10), // Điều chỉnh padding nếu cần
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                    ),
                  ),
                  child: const Text('Tiếp tục'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
