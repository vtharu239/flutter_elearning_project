import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/verify_email.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/widgets/terms_comditions_checkbox.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TSignupForm extends StatefulWidget {
  const TSignupForm({super.key});

  @override
  State<TSignupForm> createState() => _TSignupFormState();
}

class _TSignupFormState extends State<TSignupForm> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedGender = 'male'; // Giá trị mặc định

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? usernameError;
  String? emailError;
  String? passwordError;
  bool _isCheckingUsername = false;
  bool _isCheckingEmail = false;
  Timer? _debounceTimer;
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> checkUsernameAndEmail(
      {bool usernameOnly = false, bool emailOnly = false}) async {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (usernameOnly && usernameController.text.isEmpty) return;
      if (emailOnly && emailController.text.isEmpty) return;

      setState(() {
        if (usernameOnly) _isCheckingUsername = true;
        if (emailOnly) _isCheckingEmail = true;
      });

      try {
        final response = await http.post(
          Uri.parse(ApiConstants.getUrl(ApiConstants.checkUserEmailEndpoint)),
          headers: ApiConstants.getHeaders(),
          body: jsonEncode({
            if (usernameOnly || !emailOnly) 'username': usernameController.text,
            if (emailOnly || !usernameOnly) 'email': emailController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          setState(() {
            if (usernameOnly || !emailOnly) {
              usernameError = responseBody['username'] == true
                  ? 'Tên người dùng đã tồn tại'
                  : null;
            }
            if (emailOnly || !usernameOnly) {
              emailError = responseBody['email'] == true
                  ? 'Email đã được sử dụng'
                  : null;
            }
          });
        } else {
          throw Exception('Lỗi kiểm tra thông tin từ server');
        }
      } catch (e) {
        log('Error during API call: $e', name: 'checkUsernameAndEmail');
      } finally {
        setState(() {
          if (usernameOnly) _isCheckingUsername = false;
          if (emailOnly) _isCheckingEmail = false;
        });
      }
    });
  }

  Future<void> register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Map<String, String> userData = {
      "fullName": fullNameController.text,
      "gender": selectedGender,
      "username": usernameController.text,
      "email": emailController.text,
      "phoneNo": phoneNoController.text,
      "password": passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.signupEndpoint)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        // Chuyển đến màn hình xác thực email
        Get.to(() => VerifyEmailScreen(
            userEmail: responseBody['email'] ?? emailController.text));
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() {
          if (errorBody['message'].toString().contains('Email')) {
            emailError = errorBody['message'];
          }
          if (errorBody['message'].toString().contains('Tên người dùng')) {
            usernameError = errorBody['message'];
          }
        });

        // Use Get.dialog instead of showDialog
        Get.dialog(
          AlertDialog(
            title: const Text('Lỗi'),
            content:
                Text(errorBody['message'] ?? 'Đã xảy ra lỗi không xác định.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Use Get.dialog instead of showDialog
      Get.dialog(
        AlertDialog(
          title: const Text('Lỗi kết nối'),
          content: Text('Không thể kết nối đến server.\nLỗi chi tiết: $e'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  bool isPasswordVisible = false; // Trạng thái hiển thị mật khẩu

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Row(
            children: [
              // Full Name chiếm 2/3 không gian
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập họ và tên';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              // Gender chiếm 1/3 không gian
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Giới tính',
                    prefixIcon: Icon(Iconsax.user_octagon),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Nam')),
                    DropdownMenuItem(value: 'female', child: Text('Nữ')),
                    DropdownMenuItem(value: 'other', child: Text('Khác')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Vui lòng chọn giới tính';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: TTexts.username,
              prefixIcon: const Icon(Iconsax.user_edit),
              errorText: usernameError,
              suffixIcon: _isCheckingUsername
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              if (value.length >= 3) {
                checkUsernameAndEmail(usernameOnly: true);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập tên người dùng';
              }
              if (usernameError != null) {
                return usernameError;
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: TTexts.email,
              prefixIcon: const Icon(Iconsax.direct),
              errorText: emailError,
              suffixIcon: _isCheckingEmail
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              if (value.contains('@')) {
                checkUsernameAndEmail(emailOnly: true);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Email không hợp lệ';
              }
              if (emailError != null) {
                return emailError;
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: phoneNoController,
            decoration: const InputDecoration(
              labelText: TTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập số điện thoại';
              } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                return 'Số điện thoại phải có đúng 10 chữ số';
              }
              return null;
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: passwordController,
            obscureText: !isPasswordVisible, // Ẩn/hiện mật khẩu
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Iconsax.password_check),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Iconsax.eye // Hiện icon mở mắt
                      : Iconsax.eye_slash, // Hiện icon mắt gạch chéo
                ),
                onPressed: togglePasswordVisibility,
              ),
              errorText: passwordError, // Use passwordError here
            ),
            onChanged: (value) {
              setState(() {
                if (value.isEmpty) {
                  passwordError = 'Mật khẩu không được để trống';
                } else if (!RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                    .hasMatch(value)) {
                  passwordError =
                      'Mật khẩu yếu. Cần ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt';
                } else {
                  passwordError = null;
                }
              });
            },
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          const TTermsAndConditionCheckbox(),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => register(context),
              child: const Text(TTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
