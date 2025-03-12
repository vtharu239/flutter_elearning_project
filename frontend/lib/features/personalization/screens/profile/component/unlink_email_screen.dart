import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';

class UnlinkEmailScreen extends StatelessWidget {
  final String email;

  const UnlinkEmailScreen({super.key, required this.email});

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final localPart = parts[0];
    final domainPart = parts[1];
    if (localPart.length <= 2) return email;
    return '${localPart.substring(0, 2)}****@$domainPart';
  }

  Future<void> _unlinkEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.unlinkEmail)),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Get.find<AuthController>().refreshUserData();
        Get.back(); // This will go back to previous screen
        Get.back(); // This will go back to ProfileScreen
        Get.snackbar('Thành công', 'Hủy liên kết email thành công!');
      } else {
        Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể hủy liên kết: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final maskedEmail = _maskEmail(email);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      appBar: const TAppBar(
          showBackArrow: true, title: Text('Hủy liên kết email?')),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nếu bạn hủy liên kết $maskedEmail khỏi tài khoản của mình, bạn sẽ không thể tiếp tục sử dụng email này:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            const _BulletPoint(text: 'Để đăng nhập'),
            const _BulletPoint(text: 'Để đặt lại mật khẩu'),
            const _BulletPoint(
                text: 'Để cho phép người liên hệ trong danh bạ tìm bạn'),
            const _BulletPoint(text: 'Để quản lý bảo mật của tài khoản'),
            const _BulletPoint(
                text:
                    'Để nhận thông báo quan trọng từ StudyMate, chẳng hạn như các điều khoản của chúng tôi, thông tin cập nhật, v.v.'),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Sau khi hủy liên kết, bạn có thể sử dụng số điện thoại hoặc Google đã liên kết của mình để đăng nhập và quản lý tài khoản của bạn.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _unlinkEmail,
                style: ElevatedButton.styleFrom(
                  overlayColor: Colors.red,
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hủy liên kết'),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.to(const ProfileScreen()),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'X  ',
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
