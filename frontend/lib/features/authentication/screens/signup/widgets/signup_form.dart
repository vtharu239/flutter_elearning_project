import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class TSignupForm extends StatefulWidget {
  const TSignupForm({super.key});

  @override
  State<TSignupForm> createState() => _TSignupFormState();
}

class _TSignupFormState extends State<TSignupForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOtpVerified = false;
  bool _isOtpSent = false;
  bool _isPasswordVisible = false;
  String? _otpToken;
  String? _verificationId;
  String? _verifiedIdentifier;
  bool _isEmail = true;

  // OTP timer variables
  int _secondsRemaining = 60;
  bool _isTimerActive = false;

  @override
  void initState() {
    super.initState();

    // Xóa trạng thái xác thực Firebase để buộc verify reCAPTCHA mỗi lần
    fb.FirebaseAuth.instance.signOut().then((_) {
      log('Firebase Auth signed out');
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Reset form when switching tabs
      if (_tabController.indexIsChanging) {
        setState(() {
          _isOtpSent = false;
          _isOtpVerified = false;
          _otpController.clear();
          if (_tabController.index == 0) {
            _isEmail = true;
          } else {
            _isEmail = false;
          }
        });
      }
    });
  }

  Timer? _timer;

  void _startOtpTimer() {
    // Cancel any existing timer
    _timer?.cancel();

    setState(() {
      _secondsRemaining = 60;
      _isTimerActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _isTimerActive = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendOtp({bool resend = false}) async {
    // Nếu là gửi lại (resend = true), chỉ validate email/phone, không validate OTP
    if (!resend && !_formKey.currentState!.validate()) return;

    // Nếu là resend, cần validate riêng phần email/phone
    if (resend) {
      if (_isEmail) {
        // Validate email
        if (_emailController.text.trim().isEmpty ||
            !_emailController.text.contains('@')) {
          Get.snackbar('Lỗi', 'Email không hợp lệ');
          return;
        }
      } else {
        // Validate số điện thoại
        if (_phoneController.text.trim().isEmpty ||
            !RegExp(r'^\d{9,10}$').hasMatch(_phoneController.text.trim())) {
          Get.snackbar('Lỗi', 'Số điện thoại không hợp lệ');
          return;
        }
      }
    }

    String identifier;
    if (_isEmail) {
      identifier = _emailController.text.trim();
    } else {
      // Chuẩn hóa số điện thoại
      String rawPhone = _phoneController.text.trim();
      // Loại bỏ ký tự không phải số (trừ dấu + ở đầu nếu có)
      rawPhone = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
      if (rawPhone.startsWith('+84')) {
        // Nếu đã có +84, giữ nguyên nhưng đảm bảo không có số 0 đầu thừa
        identifier = rawPhone.startsWith('+840')
            ? '+84${rawPhone.substring(4)}'
            : rawPhone;
      } else {
        // Nếu không có +84, thêm vào và loại bỏ số 0 đầu nếu có
        if (rawPhone.startsWith('0')) {
          rawPhone = rawPhone.substring(1);
        }
        identifier = '+84$rawPhone';
      }
      log('Sending OTP to: $identifier'); // Debug
    }

    try {
      if (_isEmail) {
        final response = await http.post(
          Uri.parse(ApiConstants.getUrl(ApiConstants.signupEmail)),
          headers: ApiConstants.getHeaders(),
          body: jsonEncode({'email': identifier}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _otpToken = data['otpToken'];
            _isOtpSent = true;
          });
          _startOtpTimer();
          Get.snackbar('Thành công', 'Mã OTP đã được gửi đến email của bạn!');
        } else {
          Get.snackbar('Lỗi', jsonDecode(response.body)['message']);
        }
      } else {
        // Phone verification with Firebase
        await fb.FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: identifier,
          verificationCompleted: (fb.PhoneAuthCredential credential) async {
            _verifyPhoneOtp(credential, identifier);
          },
          verificationFailed: (fb.FirebaseAuthException e) {
            Get.snackbar('Lỗi', 'Không thể gửi OTP: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              _isOtpSent = true;
              _verifiedIdentifier = identifier;
            });
            _startOtpTimer();
            Get.snackbar('Thành công', 'Mã OTP đã được gửi qua SMS!');
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );

        // Check with backend
        await http.post(
          Uri.parse(ApiConstants.getUrl(ApiConstants.signupPhone)),
          headers: ApiConstants.getHeaders(),
          body: jsonEncode({'phoneNo': identifier}),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
    }
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (_isEmail) {
        // Email OTP verification
        setState(() {
          _isOtpVerified = true;
          _verifiedIdentifier = _emailController.text.trim();
        });
        Get.snackbar('Thành công', 'Mã OTP hợp lệ. Vui lòng tạo mật khẩu.');
      } else {
        // Phone OTP verification
        final credential = fb.PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: _otpController.text.trim(),
        );
        // Không đăng nhập ngay, chỉ lưu credential
        setState(() {
          _isOtpVerified = true;
          _verifiedIdentifier =
              '+84${_phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '').replaceFirst(RegExp(r'^0'), '')}';
          _otpToken = credential.smsCode; // Lưu smsCode tạm thời
        });
        Get.snackbar('Thành công', 'Mã OTP hợp lệ. Vui lòng tạo mật khẩu.');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xác minh OTP: $e');
    }
  }

  Future<void> _verifyPhoneOtp(
      fb.PhoneAuthCredential credential, String phoneNo) async {
    try {
      // Không đăng nhập ngay, chỉ xác minh credential hợp lệ
      setState(() {
        _isOtpVerified = true;
        _verifiedIdentifier = phoneNo;
        _otpToken = credential.smsCode; // Lưu smsCode tạm thời
      });
      Get.snackbar('Thành công',
          'Xác minh số điện thoại thành công. Vui lòng tạo mật khẩu.');
    } catch (e) {
      Get.snackbar('Lỗi', 'Mã OTP không hợp lệ. Vui lòng thử lại.');
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate() || !_isOtpVerified) return;

    try {
      // Chuẩn hóa lại _verifiedIdentifier trước khi gửi (đề phòng)
      String phoneNo = _verifiedIdentifier!;
      if (!_isEmail && phoneNo.startsWith('+840')) {
        phoneNo = '+84${phoneNo.substring(4)}';
      }

      final Map<String, dynamic> requestBody = {
        'otp': _otpController.text.trim(),
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'type': _isEmail ? 'email' : 'phone',
      };

      if (_isEmail) {
        requestBody['otpToken'] = _otpToken;
        requestBody['email'] = _verifiedIdentifier;
      } else {
        requestBody['phoneNo'] = phoneNo;
      }

      log('Sending request to backend: ${jsonEncode(requestBody)}'); // Debug

      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.verifyOtpSetPassword)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (!_isEmail) {
          // Chỉ đăng nhập vào Firebase sau khi MySQL lưu thành công
          final credential = fb.PhoneAuthProvider.credential(
            verificationId: _verificationId!,
            smsCode: _otpController.text.trim(),
          );
          final userCredential =
              await fb.FirebaseAuth.instance.signInWithCredential(credential);
          final idToken = await userCredential.user!.getIdToken();
          log('Firebase idToken after signup: $idToken'); // Debug
        }

        await Get.find<AuthController>()
            .setUserAndLoginState(data['user'], data['token'], false);
        Get.offAll(() => const NavigationMenu());
        Get.snackbar('Thành công', 'Tạo tài khoản thành công!');
      } else {
        final errorData = jsonDecode(response.body);
        Get.snackbar('Lỗi', errorData['message'] ?? 'Không thể tạo tài khoản!');
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Có lỗi xảy ra khi tạo tài khoản: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isOtpVerified) ...[
            // Tab bar for selecting email or phone
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkMode
                    ? const Color.fromARGB(155, 29, 28, 28)
                    : TColors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab, // chia theo số tab
                indicator: BoxDecoration(
                  color: const Color(0xFF00A2FF),
                  borderRadius: BorderRadius.circular(5),
                ),
                labelColor: darkMode ? Colors.white : Colors.black,
                unselectedLabelColor: darkMode ? Colors.white : Colors.black,
                tabs: const [
                  Tab(text: 'Đăng ký bằng Email'),
                  Tab(text: 'Đăng ký bằng SĐT'),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            // Tab content
            SizedBox(
              height: 220, // Fixed height for the verification section
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Email Tab
                  _buildEmailVerificationForm(),

                  // Phone Tab
                  _buildPhoneVerificationForm(),
                ],
              ),
            ),
          ] else ...[
            // Password creation section
            _buildPasswordCreationForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailVerificationForm() {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Iconsax.direct),
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
        const SizedBox(height: TSizes.spaceBtwInputFields),
        if (_isOtpSent) ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mã OTP',
                    prefixIcon: Icon(Iconsax.code),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã OTP';
                    }
                    if (value.length != 6) {
                      return 'Mã OTP phải có 6 chữ số';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _isTimerActive ? null : () => _sendOtp(resend: true),
                child: Text(
                  _isTimerActive
                      ? 'Gửi lại sau ($_secondsRemaining)'
                      : 'Gửi lại mã',
                  style: const TextStyle(color: Color(0xFF00A2FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                foregroundColor: Colors.white, // Màu chữ trắng
                padding: const EdgeInsets.symmetric(
                    vertical: 12), // Điều chỉnh padding nếu cần
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bo góc
                ),
              ),
              onPressed: _verifyOtp,
              child: const Text('Xác nhận OTP'),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                foregroundColor: Colors.white, // Màu chữ trắng
                padding: const EdgeInsets.symmetric(
                    vertical: 12), // Điều chỉnh padding nếu cần
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bo góc
                ),
              ),
              onPressed: _sendOtp,
              child: const Text('Gửi mã OTP'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneVerificationForm() {
    return Column(
      children: [
        Row(
          children: [
            const Text('+84 ', style: TextStyle(fontSize: 16)),
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
                  if (!RegExp(r'^\d{9,10}$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
                enabled: !_isOtpSent,
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwInputFields),
        if (_isOtpSent) ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Mã OTP',
                    prefixIcon: Icon(Iconsax.code),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã OTP';
                    }
                    if (value.length != 6) {
                      return 'Mã OTP phải có 6 chữ số';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _isTimerActive ? null : () => _sendOtp(resend: true),
                child: Text(
                  _isTimerActive
                      ? 'Gửi lại sau ($_secondsRemaining)'
                      : 'Gửi lại mã',
                  style: const TextStyle(color: Color(0xFF00A2FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          SizedBox(
            width: double.infinity,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                onPressed: _verifyOtp,
                child: const Text('Xác nhận OTP'),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                foregroundColor: Colors.white, // Màu chữ trắng
                padding: const EdgeInsets.symmetric(
                    vertical: 12), // Điều chỉnh padding nếu cần
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Bo góc
                ),
              ),
              onPressed: _sendOtp,
              child: const Text('Gửi mã OTP'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordCreationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show verification success message
        Container(
          padding: const EdgeInsets.all(TSizes.md),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: TSizes.sm),
              Expanded(
                child: Text(
                  'Xác thực ${_isEmail ? 'email' : 'số điện thoại'} thành công. Tạo mật khẩu để hoàn tất đăng ký.',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        // Form title
        Text(
          'Tạo mật khẩu',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        // Password fields
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            prefixIcon: const Icon(Iconsax.password_check),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Iconsax.eye : Iconsax.eye_slash),
              onPressed: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
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
        const SizedBox(height: TSizes.spaceBtwInputFields),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isPasswordVisible,
          decoration: const InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            prefixIcon: Icon(Iconsax.password_check),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (value != _passwordController.text) {
              return 'Mật khẩu không khớp';
            }
            return null;
          },
        ),
        const SizedBox(height: TSizes.spaceBtwSections),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
              foregroundColor: Colors.white, // Màu chữ trắng
              padding: const EdgeInsets.symmetric(
                  vertical: 12), // Điều chỉnh padding nếu cần
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // Bo góc
              ),
            ),
            onPressed: _createAccount,
            child: const Text('Hoàn tất đăng ký'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
