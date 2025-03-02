import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatefulWidget {
  final String email;
  final String otpToken;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.otpToken,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String verificationCode = '';
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (verificationCode.length != 6) {
      // Show an error message if OTP is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã OTP 6 chữ số hợp lệ')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.verifyOTP)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          'otpToken': widget.otpToken,
          'otp': verificationCode,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final resetToken = responseBody['resetToken'];

        // Kiểm tra widget có còn mounted trước khi điều hướng
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPassword(
                email: widget.email,
                resetToken: resetToken,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseBody['message'] ?? 'Xác thực thất bại')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
            color: darkMode
                ? Colors.white
                : Colors.black, // Màu trắng cho dark mode, đen cho light mode
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(TTexts.verification,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(TTexts.verificationSubTitle,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Verification Code Input
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) {
                setState(() {
                  verificationCode = value;
                });
              },
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOTP,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(TTexts.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
