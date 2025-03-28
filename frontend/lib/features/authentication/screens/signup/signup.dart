import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/spacing_styles.dart';
import 'package:flutter_elearning_project/common/widgets/login_signup/form_divider.dart';
import 'package:flutter_elearning_project/common/widgets/login_signup/social_buttons.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/widgets/signup_header.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Logo, Title & Sub Title
              const TSignupHeader(),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Form
              const TSignupForm(),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Divider
              TFormDivider(dividerText: TTexts.orSignUpWith.capitalize!),
              const SizedBox(height: TSizes.defaultSpace),

              /// Social Buttons
              const TSocialButtons(),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Link to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bạn đã có tài khoản? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                      onPressed: () => Get.to(() => const LoginScreen()),
                      child: const Text("Đăng nhập ngay!",
                          style: TextStyle(color: Color(0xFF00A2FF)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
