import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/verification_code.dart';
import 'package:flutter_elearning_project/features/authentication/screens/password_configuration/widgets/forget_password_header.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPassword>
    with SingleTickerProviderStateMixin {
  TabController? _tabController; // Loại bỏ 'late', cho phép null
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _verificationId; // Dùng cho Phone Auth
  String? _otpToken; // Dùng cho email OTP
  bool _isEmail = true;

  @override
  void initState() {
    super.initState();

    // Xóa trạng thái xác thực Firebase để buộc verify reCAPTCHA mỗi lần
    fb.FirebaseAuth.instance.signOut().then((_) {
      log('Firebase Auth signed out');
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() {
      if (_tabController!.indexIsChanging) {
        setState(() {
          _isOtpSent = false;
          _emailController.clear();
          _phoneController.clear();
          _isEmail = _tabController!.index == 0;
        });
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEmail) {
        // Gửi OTP qua email
        final response = await http.post(
          Uri.parse(ApiConstants.getUrl(ApiConstants.sendOTP)),
          headers: ApiConstants.getHeaders(),
          body: jsonEncode({'email': _emailController.text.trim()}),
        );

        final responseBody = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            _otpToken = responseBody['otpToken'];
            _isOtpSent = true;
          });
          Get.snackbar('Thành công', 'Mã OTP đã được gửi đến email của bạn!');
          // Tự động chuyển sang VerificationScreen
          Get.to(() => VerificationScreen(
                identifier: _emailController.text.trim(),
                otpToken: _otpToken,
                verificationId: null,
                isEmail: true,
              ));
        } else {
          Get.snackbar('Lỗi', responseBody['message'] ?? 'Gửi OTP thất bại.');
        }
      } else {
        String rawPhone = _phoneController.text.trim();
        if (rawPhone.startsWith('0')) {
          rawPhone = rawPhone.substring(1);
        }
        final phoneNumber = '+84$rawPhone';
        log('Sending OTP to: $phoneNumber');
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) async {
            log('OTP auto-retrieved: ${credential.smsCode}');
          },
          verificationFailed: (FirebaseAuthException e) {
            log('Verification failed: ${e.message}');
            Get.snackbar('Lỗi', 'Không thể gửi OTP: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            log('OTP sent, verificationId: $verificationId');
            setState(() {
              _verificationId = verificationId;
              _isOtpSent = true;
            });
            Get.snackbar('Thành công', 'Mã OTP đã được gửi qua SMS!');
            Get.to(() => VerificationScreen(
                  identifier: phoneNumber,
                  otpToken: null,
                  verificationId: _verificationId,
                  isEmail: false,
                ));
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            log('Auto retrieval timeout, verificationId: $verificationId');
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('Trở về Trang đăng nhập'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Logo, Title & Sub Title
              const TForgetPasswordHeader(),
              const SizedBox(height: TSizes.spaceBtwItems * 2),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Tab bar
                    if (_tabController != null) // Kiểm tra null để an toàn
                      Container(
                        decoration: BoxDecoration(
                          color: darkMode
                              ? const Color.fromARGB(155, 29, 28, 28)
                              : TColors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: const Color(0xFF00A2FF),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          labelColor: darkMode ? Colors.white : Colors.black,
                          unselectedLabelColor:
                              darkMode ? Colors.white : Colors.black,
                          tabs: const [
                            Tab(text: 'Dùng Email'),
                            Tab(text: 'Dùng SĐT'),
                          ],
                        ),
                      ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    if (_tabController != null)
                      SizedBox(
                        height: 50,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Email input
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: TTexts.email,
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập email';
                                }
                                if (!value.contains('@')) {
                                  return 'Email không hợp lệ';
                                }
                                return null;
                              },
                              enabled: !_isOtpSent,
                            ),
                            // Phone input
                            Row(
                              children: [
                                const Text('+84 ',
                                    style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'Số điện thoại',
                                      prefixIcon: Icon(Iconsax.call),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập số điện thoại';
                                      }
                                      if (!RegExp(r'^\d{9,10}$')
                                          .hasMatch(value)) {
                                        return 'Số điện thoại không hợp lệ';
                                      }
                                      return null;
                                    },
                                    enabled: !_isOtpSent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF00A2FF), // Màu xanh #00A2FF
                          foregroundColor: Colors.white, // Màu chữ trắng
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Điều chỉnh padding nếu cần
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Bo góc
                          ),
                        ),
                        onPressed: _isLoading ? null : _sendOtp,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              )
                            : const Text('Gửi mã xác nhận'),
                      ),
                    ),
                  ],
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
    _tabController?.dispose(); // Chỉ dispose nếu không null
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
