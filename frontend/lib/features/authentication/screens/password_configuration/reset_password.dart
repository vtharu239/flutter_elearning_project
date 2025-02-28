import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPassword({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;
  String? _passwordStrengthMessage;
  final Color _passwordStrengthColor = Colors.red;

  // Kiểm tra độ mạnh của mật khẩu
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;

    // Kiểm tra có chữ hoa
    if (!password.contains(RegExp(r'[A-Z]'))) return false;

    // Kiểm tra có chữ thường
    if (!password.contains(RegExp(r'[a-z]'))) return false;

    // Kiểm tra có số
    if (!password.contains(RegExp(r'[0-9]'))) return false;

    // Kiểm tra có ký tự đặc biệt
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;

    return true;
  }

  // // Cập nhật thông báo độ mạnh mật khẩu
  // void _updatePasswordStrength(String password) {
  //   setState(() {
  //     if (password.isEmpty) {
  //       _passwordStrengthMessage = null;
  //       _passwordStrengthColor = Colors.red;
  //       return;
  //     }

  //     List<String> requirements = [];

  //     if (password.length < 8) {
  //       requirements.add("ít nhất 8 ký tự");
  //     }
  //     if (!password.contains(RegExp(r'[A-Z]'))) {
  //       requirements.add("chữ hoa");
  //     }
  //     if (!password.contains(RegExp(r'[a-z]'))) {
  //       requirements.add("chữ thường");
  //     }
  //     if (!password.contains(RegExp(r'[0-9]'))) {
  //       requirements.add("số");
  //     }
  //     if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
  //       requirements.add("ký tự đặc biệt");
  //     }

  //     if (requirements.isEmpty) {
  //       _passwordStrengthMessage = "Mật khẩu mạnh";
  //       _passwordStrengthColor = Colors.green;
  //     } else {
  //       _passwordStrengthMessage =
  //           "Mật khẩu cần có: ${requirements.join(", ")}";
  //       _passwordStrengthColor = Colors.red;
  //     }
  //   });
  // }

  Future<void> resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation cơ bản
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    // Kiểm tra độ mạnh mật khẩu
    if (!_isPasswordStrong(newPassword)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu không khớp"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.resetPassword)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          'email': widget.email,
          'newPassword': newPassword,
          'resetToken': widget.resetToken,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        Get.offAll(() => const LoginScreen());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Có lỗi xảy ra!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
            Text(TTexts.setNewPassword,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(TTexts.setNewPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// New Password
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_newPasswordVisible,
              decoration: InputDecoration(
                labelText: TTexts.newPassword,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  icon: Icon(
                      _newPasswordVisible ? Iconsax.eye : Iconsax.eye_slash),
                  onPressed: () {
                    setState(() {
                      _newPasswordVisible = !_newPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Password Strength Indicator
            if (_passwordStrengthMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _passwordStrengthMessage!,
                  style: TextStyle(
                    color: _passwordStrengthColor,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: TSizes.spaceBtwInputFields),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_confirmPasswordVisible,
              decoration: InputDecoration(
                labelText: TTexts.confirmPassword,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  icon: Icon(_confirmPasswordVisible
                      ? Iconsax.eye
                      : Iconsax.eye_slash),
                  onPressed: () {
                    setState(() {
                      _confirmPasswordVisible = !_confirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : resetPassword,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(TTexts.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
