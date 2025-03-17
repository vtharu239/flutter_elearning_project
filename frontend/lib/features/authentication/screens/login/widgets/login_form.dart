import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/signup.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TLoginForm extends StatefulWidget {
  const TLoginForm({super.key});

  @override
  State<TLoginForm> createState() => _TLoginFormState();
}

class _TLoginFormState extends State<TLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Đăng nhập thông thường bằng email/phone
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.login)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          'identifier': _identifierController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      log('Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Lưu thông tin đăng nhập thông qua AuthController
        await Get.find<AuthController>().setUserAndLoginState(
          data['user'],
          data['token'],
          _rememberMe,
        );

        Get.offAll(() => const NavigationMenu());
        Get.snackbar('Thành công', 'Đăng nhập thành công!');
      } else {
        final error = json.decode(response.body);
        Get.snackbar('Lỗi', error['message'] ?? 'Đăng nhập thất bại!');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Đã có lỗi xảy ra. Vui lòng thử lại sau.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
        child: Column(
          children: [
            // Email
            TextFormField(
              controller: _identifierController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: 'Email hoặc số điện thoại',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập email hoặc số điện thoại';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                labelText: TTexts.password,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash,
                  ),
                  onPressed: () {
                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 8) {
                  return 'Mật khẩu phải có ít nhất 8 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            // Remember Me & Forgot Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Remember Me
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      activeColor: const Color(0xFF00A2FF),
                    ),
                    const Text(TTexts.rememberMe),
                  ],
                ),

                // Forget Password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(
                    TTexts.forgetPassword,
                    style: TextStyle(color: Color(0xFF00A2FF)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(TTexts.signIn),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Màu xanh #00A2FF
                  foregroundColor: Colors.black, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                onPressed: () => Get.to(() => const SignupScreen()),
                child: const Text(TTexts.createAccount),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
