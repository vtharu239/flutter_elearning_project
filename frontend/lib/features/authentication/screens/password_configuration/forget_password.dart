import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/verification_code.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  State<ForgetPassword> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  String? emailError;
  bool isLoading = false;

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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': emailController.text}),
      );

      if (response.statusCode == 200) {
        // Navigate to Verify OTP Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VerificationScreen(email: emailController.text),
          ),
        );
      } else {
        final responseBody = jsonDecode(response.body);
        setState(() {
          emailError = responseBody['message'] ?? 'Gửi OTP thất bại.';
        });
      }
    } catch (e) {
      setState(() {
        emailError = 'Không thể kết nối đến server.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                suffixIcon: Icon(Iconsax.direct_right),
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
