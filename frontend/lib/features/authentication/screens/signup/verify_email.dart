import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/success_screen/success_screen.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyEmailScreen extends StatelessWidget {
  final String? userEmail;
  const VerifyEmailScreen({super.key, this.userEmail});

  Future<void> sendConfirmationEmail(BuildContext context) async {
    if (userEmail == null || userEmail!.isEmpty) {
      Get.snackbar('Lỗi', 'Email không hợp lệ.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/send-confirmation-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Thành công', 'Email xác nhận đã được gửi.');
      } else {
        Get.snackbar('Lỗi', 'Không thể gửi email xác nhận.');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi gửi email.');
    }
  }

  // Thêm hàm để kiểm tra xác nhận email
  Future<void> checkEmailVerification(BuildContext context) async {
    if (userEmail == null || userEmail!.isEmpty) {
      Get.snackbar('Lỗi', 'Email không hợp lệ.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/check-email-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': userEmail}),
      );

      if (response.statusCode == 200) {
        // Nếu email đã được xác nhận, chuyển đến màn hình thành công
        Get.to(() => SuccessScreen(
              image: TImages.staticSuccessIllustration,
              title: TTexts.yourAccountCreatedTitle,
              subTitle: TTexts.yourAccountCreatedSubTitle,
              onPressed: () => Get.to(() => const LoginScreen()),
            ));
      } else {
        Get.snackbar(
          'Thông báo',
          'Email chưa được xác nhận. Vui lòng kiểm tra email của bạn.',
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã xảy ra lỗi khi kiểm tra xác nhận email.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailToShow =
        userEmail?.isNotEmpty == true ? userEmail! : 'Không xác định';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => Get.offAll(() => const LoginScreen()),
            icon: const Icon(CupertinoIcons.clear),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              Text(
                emailToShow,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              Image(
                image: const AssetImage(TImages.deliveredEmailIllustration),
                width: THelperFunctions.screenWidth() * 0.6,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Text(
                TTexts.confirmEmail,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                emailToShow,
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                TTexts.confirmEmailSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => sendConfirmationEmail(context),
                  child: const Text(TTexts.resendEmail),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => checkEmailVerification(context),
                  child: const Text('Tôi đã kiểm tra email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
