import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_phone_otp_screen.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';

class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  UpdatePhoneScreenState createState() => UpdatePhoneScreenState();
}

class UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String? _verificationId;

  Future<void> _initiatePhoneChange() async {
    if (!_formKey.currentState!.validate()) return;

    String newPhone =
        '+84${_phoneController.text.trim().replaceFirst(RegExp(r'^0'), '')}';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/initiate-phone-change')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newPhoneNo': newPhone}),
      );

      if (response.statusCode == 200) {
        await fb.FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: newPhone,
          verificationCompleted: (fb.PhoneAuthCredential credential) {},
          verificationFailed: (fb.FirebaseAuthException e) {
            Get.snackbar('Lỗi', 'Không thể gửi OTP: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
            });
            Get.to(() => VerifyPhoneOtpScreen(
                  newPhoneNo: newPhone,
                  verificationId: _verificationId!,
                ));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
        );
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
      backgroundColor: isDarkMode ? TColors.dark : TColors.white,
      appBar: TAppBar(
        title: const Text('Nhập số điện thoại'),
        showBackArrow: true,
        padding: EdgeInsets.symmetric(horizontal: 6.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          'Số điện thoại của bạn có thể sẽ được sử dụng để kết nối bạn với những người bạn có thể biết, truy cập các khóa học, v.v ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextSpan(
                      text: '',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          //  Xử lý sự kiện click "Tìm hiểu thêm" (nếu cần)
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'VN +84',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  const Text(
                    ' | ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Nhập số điện thoại',
                        border: UnderlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số điện thoại';
                        }
                        if (!RegExp(r'^\d{9,10}$').hasMatch(value)) {
                          return 'Số điện thoại không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _initiatePhoneChange,
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
    _phoneController.dispose();
    super.dispose();
  }
}
