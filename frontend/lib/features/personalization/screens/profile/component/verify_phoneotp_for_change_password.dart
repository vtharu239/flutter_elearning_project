import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/new_password_screen.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyPhoneOtpForPasswordChangeScreen extends StatefulWidget {
  final String phoneNo;
  final String verificationId;

  const VerifyPhoneOtpForPasswordChangeScreen({
    super.key,
    required this.phoneNo,
    required this.verificationId,
  });

  @override
  VerifyPhoneOtpForPasswordChangeScreenState createState() =>
      VerifyPhoneOtpForPasswordChangeScreenState();
}

class VerifyPhoneOtpForPasswordChangeScreenState
    extends State<VerifyPhoneOtpForPasswordChangeScreen> {
  String verificationCode = '';
  bool isLoading = false;
  int _secondsRemaining = 60;
  bool _isTimerActive = false;
  Timer? _timer;
  late String verificationId;

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    _startOtpTimer();
  }

  void _startOtpTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 60;
      _isTimerActive = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
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

  Future<void> _resendOtp() async {
    try {
      await fb.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNo,
        verificationCompleted: (fb.PhoneAuthCredential credential) {},
        verificationFailed: (fb.FirebaseAuthException e) {
          Get.snackbar('Lỗi', 'Không thể gửi lại OTP: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            verificationId = verificationId;
          });
          _startOtpTimer();
          Get.snackbar('Thành công', 'Mã OTP đã được gửi lại!');
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi lại OTP: $e');
    }
  }

  Future<void> _verifyOtp() async {
    if (verificationCode.length != 6) {
      Get.snackbar('Lỗi', 'Vui lòng nhập mã OTP 6 chữ số hợp lệ');
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: verificationCode,
      );
      final userCredential =
          await fb.FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user!.getIdToken();

      Get.to(() => NewPasswordScreen(idToken: idToken!));
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xác minh OTP: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkMode ? TColors.dark : TColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: darkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
            Get.back();
          },
        ),
        title: const Text('Xác minh OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.labelLarge, // Kiểu chữ chung
                children: [
                  const TextSpan(
                    text: 'Nhập mã OTP đã gửi đến ',
                  ),
                  TextSpan(
                    text: widget.phoneNo, // Phần có màu xanh
                    style: const TextStyle(
                        color: Color(0xFF00A2FF)), // Đổi màu của identifier
                  ),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) => setState(() => verificationCode = value),
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isTimerActive
                      ? 'Gửi lại mã sau $_secondsRemaining giây'
                      : 'Chưa nhận được mã?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (!_isTimerActive)
                  TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Gửi lại mã OTP',
                      style: TextStyle(color: Color(0xFF00A2FF)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 10), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                onPressed: isLoading ? null : _verifyOtp,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Xác nhận'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
