import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/verification_code.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isLoading = false;
  String? otpToken; // Thêm biến để lưu otpToken

  Future<void> sendOtp() async {
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Vui lòng nhập email';
      });
      return;
    }

    setState(() {
      isLoading = true;
      emailError = null;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.sendOTP)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({'email': emailController.text}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        otpToken = responseBody['otpToken']; // Lưu otpToken từ response

        // Use Get.to instead of Navigator.push
        Get.to(() => VerificationScreen(
              email: emailController.text,
              otpToken: otpToken!, // Truyền otpToken sang màn hình xác thực
            ));
      } else {
        if (mounted) {
          setState(() {
            emailError = responseBody['message'] ?? 'Gửi OTP thất bại.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          emailError = 'Không thể kết nối đến server.';
        });
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
            Text(TTexts.forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(TTexts.forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: TSizes.spaceBtwItems * 2),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: TTexts.email,
                suffixIcon: const Icon(Iconsax.direct_right),
                prefixIcon: const Icon(Icons.email),
                errorText: emailError,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendOtp,
                child: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text('Gửi OTP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
