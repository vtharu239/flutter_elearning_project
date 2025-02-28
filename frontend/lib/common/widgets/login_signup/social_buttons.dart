import 'dart:convert';
//import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:flutter_elearning_project/features/shop/screens/home/home.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';

class TSocialButtons extends StatelessWidget {
  TSocialButtons({Key? key}) : super(key: key);
  final GoogleSignIn signIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Hàm hỗ trợ hiển thị JSON dạng thụt lề
  String prettyPrint(Map json) {
    JsonEncoder encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  // Hàm đăng nhập bằng Google
  /* void googleSignin(BuildContext context) async {
    try {
      var user = await signIn.signIn();
      print("Google User: $user");
      if (user != null) {
        // Sau khi đăng nhập thành công, điều hướng đến trang Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print(e);
    }
  }*/
  void googleSignin(BuildContext context) async {
    try {
      final account = await signIn.signIn();
      if (account == null) {
        // Người dùng hủy đăng nhập
        throw Exception('Người dùng đã hủy đăng nhập Google');
      }

      // Lấy AuthController qua GetX
      final authController = Get.find<AuthController>();

      // Gọi hàm cập nhật user trong AuthController
      authController.setUserFromGoogle(
        account.displayName ?? 'No Name',
        account.email,
      );

      // Điều hướng đến HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const NavigationMenu()), //HomeScreen())
      );
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
    }
  }

  void facebookSignin(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // Lấy dữ liệu người dùng
        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture",
        );

        // Lấy name và email
        final name = userData["name"] ?? 'No Name';
        final email = userData["email"] ?? '';

        // Tìm AuthController
        final authController = Get.find<AuthController>();

        // Gọi hàm setUserFromFacebook để cập nhật user
        authController.setUserFromFacebook(name, email);

        // Điều hướng sang HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationMenu()),
        );
      } else {
        print("Facebook login failed: ${result.status} - ${result.message}");
      }
    } catch (e) {
      print("Error during Facebook login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nút đăng nhập Google
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () {
              googleSignin(context);
            },
            icon: const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(TImages.google),
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        // Nút đăng nhập Facebook
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: TColors.grey),
              borderRadius: BorderRadius.circular(100)),
          child: IconButton(
            onPressed: () {
              facebookSignin(context);
            },
            icon: const Image(
              width: TSizes.iconMd,
              height: TSizes.iconMd,
              image: AssetImage(TImages.facebook),
            ),
          ),
        ),
      ],
    );
  }
}
