import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String password) {
    const minLength = 8;
    final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
    final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
    final hasNumbers = RegExp(r'\d').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return password.length >= minLength &&
        hasUpperCase &&
        hasLowerCase &&
        hasNumbers &&
        hasSpecialChar;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/change-password')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': _currentPasswordController.text,
          'newPassword': _newPasswordController.text,
          'confirmPassword': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        Get.back();
        Get.snackbar(
          'Thành công',
          'Thay đổi mật khẩu thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Thay đổi mật khẩu thất bại';
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thay đổi mật khẩu',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _showCurrentPassword = !_showCurrentPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNewPassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu mới',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showNewPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (!_isStrongPassword(value)) {
                    return 'Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu mới';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Xác nhận'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}