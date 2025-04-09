import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';

class UnlinkPhoneScreen extends StatelessWidget {
  final String phoneNo;

  const UnlinkPhoneScreen({super.key, required this.phoneNo});

  String _maskPhoneNumber(String phoneNo) {
    if (phoneNo.length < 4) return phoneNo;
    return phoneNo.replaceRange(4, phoneNo.length - 4, '****');
  }

  Future<void> _unlinkPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/unlink-phone')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Get.find<AuthController>().refreshUserData();
        Get.back(); // This will go back to previous screen
        Get.back(); // This will go back to ProfileScreen
        Get.snackbar('Thành công', 'Hủy liên kết số điện thoại thành công!');
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
    final maskedPhone = _maskPhoneNumber(phoneNo);

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Hủy liên kết số điện thoại?'),
        padding: EdgeInsets.symmetric(horizontal: 6.0),
      ),
      backgroundColor: isDarkMode ? TColors.dark : TColors.white,
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyLarge, // Kiểu chữ chung
                children: [
                  const TextSpan(
                    text: 'Nếu bạn hủy liên kết số điện thoại ',
                  ),
                  TextSpan(
                    text: maskedPhone, // Phần có màu xanh
                    style: const TextStyle(
                        color: Color(0xFF00A2FF)), // Đổi màu của identifier
                  ),
                  const TextSpan(
                    text:
                        ' khỏi tài khoản của mình, bạn sẽ không thể tiếp tục sử dụng số điện thoại này: ',
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            const _BulletPoint(text: 'Để đăng nhập'),
            const _BulletPoint(text: 'Để đặt lại mật khẩu'),
            const _BulletPoint(text: 'Để quản lý bảo mật của tài khoản'),
            const _BulletPoint(
                text:
                    'Để nhận thông báo quan trọng từ StudyMate, chẳng hạn như các điều khoản của chúng tôi, thông tin cập nhật, v.v.'),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              'Sau khi hủy liên kết, bạn có thể sử dụng tài khoản email hoặc Google đã liên kết của mình để đăng nhập và quản lý tài khoản của bạn.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _unlinkPhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Màu xanh #00A2FF
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 10), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                child: const Text('Hủy liên kết'),
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
