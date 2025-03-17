import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/widgets/reset_password_header.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;

class ResetPassword extends StatefulWidget {
  final String identifier;
  final String resetToken;
  final bool isEmail;

  const ResetPassword({
    super.key,
    required this.identifier,
    required this.resetToken,
    required this.isEmail,
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

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  Future<void> resetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
        );
      }
      return;
    }

    if (!_isPasswordStrong(newPassword)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (newPassword != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu không khớp")),
        );
      }
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.resetPassword)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          'identifier': widget.identifier,
          'newPassword': newPassword,
          'resetToken': widget.resetToken,
          'type': widget.isEmail ? 'email' : 'phone',
        }),
      );

      if (!mounted) return;

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt lại mật khẩu thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Use a local variable to track if widget is still mounted after delay
        bool isStillMounted = true;
        await Future.delayed(const Duration(seconds: 2)).then((_) {
          isStillMounted = mounted;
        });

        if (isStillMounted) {
          Get.offAll(() => const LoginScreen());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Có lỗi xảy ra!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: darkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Logo, Title & Sub Title
              const TResetPasswordHeader(),
              const SizedBox(height: TSizes.spaceBtwSections),

              TextFormField(
                controller: _newPasswordController,
                obscureText: !_newPasswordVisible,
                decoration: InputDecoration(
                  labelText: TTexts.newPassword,
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _newPasswordVisible ? Iconsax.eye : Iconsax.eye_slash),
                    onPressed: () => setState(
                        () => _newPasswordVisible = !_newPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
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
                    onPressed: () => setState(() =>
                        _confirmPasswordVisible = !_confirmPasswordVisible),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A2FF),
                    foregroundColor: Colors.white, // Màu chữ trắng
                    padding: const EdgeInsets.symmetric(
                        vertical: 12), // Điều chỉnh padding nếu cần
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bo góc
                    ),
                  ),
                  onPressed: _isLoading ? null : resetPassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(TTexts.confirm),
                ),
              ),
            ],
          ),
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
