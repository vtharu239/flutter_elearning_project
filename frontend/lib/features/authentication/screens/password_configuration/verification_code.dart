import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/widgets/verification_code_header.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatefulWidget {
  final String identifier;
  final String? otpToken; // Dùng cho email
  final String? verificationId; // Dùng cho phone
  final bool isEmail;

  const VerificationScreen({
    super.key,
    required this.identifier,
    this.otpToken,
    this.verificationId,
    required this.isEmail,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String verificationCode = '';
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (verificationCode.length != 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã OTP 6 chữ số hợp lệ')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.isEmail) {
        // Xác minh OTP email qua backend
        final response = await http.post(
          Uri.parse(ApiConstants.getUrl(ApiConstants.verifyOTP)),
          headers: ApiConstants.getHeaders(),
          body: jsonEncode({
            'otpToken': widget.otpToken,
            'otp': verificationCode,
          }),
        );

        if (!mounted) return;

        final responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          final resetToken = responseBody['resetToken'];
          Get.snackbar('Thành công',
              'Bạn đã xác thực mã OTP thành công. Hãy tiến hành đặt lại mật khẩu!');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(
                identifier: widget.identifier,
                resetToken: resetToken,
                isEmail: true,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseBody['message'] ?? 'Xác thực thất bại')),
          );
        }
      } else {
        // Xác minh OTP phone qua Firebase
        final credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId!,
          smsCode: verificationCode,
        );
        final userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (!mounted) return;

        if (userCredential.user != null) {
          final idToken = await userCredential.user!.getIdToken();
          log('Firebase idToken: $idToken');

          if (!mounted) return;

          Get.snackbar('Thành công',
              'Bạn đã xác thực mã OTP thành công. Hãy tiến hành đặt lại mật khẩu!');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(
                identifier: widget.identifier,
                resetToken: idToken!,
                isEmail: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: darkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Logo, Title & Sub Title
              const TVerificationCodeHeader(),
              const SizedBox(height: TSizes.spaceBtwItems),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.labelLarge, // Kiểu chữ chung
                  children: [
                    TextSpan(
                      text:
                          'Nhập mã OTP đã gửi đến ${widget.isEmail ? 'email' : 'số điện thoại'} ',
                    ),
                    TextSpan(
                      text: widget.identifier,
                      style: const TextStyle(
                          color: Color(0xFF00A2FF)), // Đổi màu của identifier
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
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A2FF),
                    foregroundColor: Colors.white, // Màu chữ trắng
                    padding: const EdgeInsets.symmetric(
                        vertical: 12), // Điều chỉnh padding nếu cần
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                    ),
                  ),
                  onPressed: isLoading ? null : verifyOTP,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(TTexts.confirm),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
