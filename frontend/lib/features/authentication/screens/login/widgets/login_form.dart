import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/signup.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TLoginForm extends StatelessWidget {
  const TLoginForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            /// Email
            TextFormField(
              decoration: const InputDecoration(prefixIcon: Icon(Iconsax.direct_right), labelText: TTexts.email),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                labelText: TTexts.password,
                suffixIcon: Icon(Iconsax.eye_slash),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Remember Me
                Row(
                  children: [
                    Checkbox(value: true, onChanged: (value) {}),
                    const Text(TTexts.rememberMe),
                  ],
                ),

                /// Forget Password
                TextButton(onPressed: () => Get.to(() => const ForgetPassword()) , child: const Text(TTexts.forgetPassword)),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Get.to(() => NavigationMenu()), child: const Text(TTexts.signIn))),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Create Account Button
            SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () => Get.to(() => const SignupScreen()), child: const Text(TTexts.createAccount))
            ),
          ],
        ),
      ),
    );
  }
}