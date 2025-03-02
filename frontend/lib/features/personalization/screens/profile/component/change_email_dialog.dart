import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum để theo dõi các bước
enum ChangeEmailStep { password, newEmail, verification }

class ChangeEmailDialog extends StatefulWidget {
  final String currentEmail;
  const ChangeEmailDialog({super.key, required this.currentEmail});

  @override
  State<ChangeEmailDialog> createState() => _ChangeEmailDialogState();
}

class _ChangeEmailDialogState extends State<ChangeEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  String? _otpToken;

  ChangeEmailStep _currentStep = ChangeEmailStep.password;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Kiểm tra mật khẩu hiện tại
  Future<void> _verifyCurrentPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/verify-password')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': _currentPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _currentStep = ChangeEmailStep.newEmail;
        });
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Mật khẩu không chính xác';
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Gửi email mới và nhận OTP
  Future<void> _initiateEmailChange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/initiate-email-change')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': _currentPasswordController.text,
          'newEmail': _newEmailController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _otpToken = data['otpToken'];
          _currentStep = ChangeEmailStep.verification;
        });
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Không thể gửi mã OTP';
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Xác thực OTP và hoàn tất thay đổi email
  Future<void> _completeEmailChange() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl('/profile/complete-email-change')),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'otpToken': _otpToken,
          'otp': _otpController.text,
        }),
      );

      if (response.statusCode == 200) {
        final authController = Get.find<AuthController>();
        await authController
            .refreshUserData(); // Refresh user data để cập nhật email mới
        Get.back();
        Get.snackbar(
          'Thành công',
          'Thay đổi email thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Thay đổi email thất bại';
      }
    } catch (e) {
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildPasswordStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Xác nhận mật khẩu',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        const Text(
          'Vui lòng nhập mật khẩu hiện tại để tiếp tục',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        TextFormField(
          controller: _currentPasswordController,
          obscureText: !_showPassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu hiện tại',
            suffixIcon: IconButton(
              icon:
                  Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNewEmailStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Nhập email mới',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text('Email hiện tại: ${widget.currentEmail}'),
        const SizedBox(height: TSizes.spaceBtwItems),
        const Text(
          'Hãy nhập email mới của bạn',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        TextFormField(
          controller: _newEmailController,
          decoration: const InputDecoration(
            labelText: 'Email mới',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email mới';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Email không hợp lệ';
            }
            if (value == widget.currentEmail) {
              return 'Email mới phải khác email hiện tại';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Xác thực email',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(
          'Mã xác thực đã được gửi đến email ${_newEmailController.text}',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        PinCodeTextField(
          appContext: context,
          length: 6,
          onChanged: (value) {
            _otpController.text = value;
          },
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(8),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Colors.white,
          ),
        ),
      ],
    );
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
              if (_currentStep == ChangeEmailStep.password)
                _buildPasswordStep()
              else if (_currentStep == ChangeEmailStep.newEmail)
                _buildNewEmailStep()
              else
                _buildVerificationStep(),
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
                    onPressed: _isLoading
                        ? null
                        : () {
                            switch (_currentStep) {
                              case ChangeEmailStep.password:
                                _verifyCurrentPassword();
                                break;
                              case ChangeEmailStep.newEmail:
                                _initiateEmailChange();
                                break;
                              case ChangeEmailStep.verification:
                                _completeEmailChange();
                                break;
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _currentStep == ChangeEmailStep.password
                                ? 'Tiếp tục'
                                : _currentStep == ChangeEmailStep.newEmail
                                    ? 'Gửi mã OTP'
                                    : 'Xác nhận',
                          ),
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
