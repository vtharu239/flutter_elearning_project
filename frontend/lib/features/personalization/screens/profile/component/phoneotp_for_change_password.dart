import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_phoneotp_for_change_password.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class InitiatePhoneOtpForPasswordChangeScreen extends StatefulWidget {
  final String phoneNo;

  const InitiatePhoneOtpForPasswordChangeScreen({
    super.key,
    required this.phoneNo,
  });

  @override
  State<InitiatePhoneOtpForPasswordChangeScreen> createState() =>
      _InitiatePhoneOtpForPasswordChangeScreenState();
}

class _InitiatePhoneOtpForPasswordChangeScreenState
    extends State<InitiatePhoneOtpForPasswordChangeScreen> {
  bool _isLoading = true;
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _sendOtp(); // Gửi OTP khi màn hình khởi tạo
  }

  Future<void> _sendOtp() async {
    try {
      // Reset Firebase Auth state trước khi gửi yêu cầu mới
      await fb.FirebaseAuth.instance.signOut();
      log('Firebase Auth signed out');

      // Gửi yêu cầu OTP qua Firebase
      await fb.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNo,
        timeout: const Duration(seconds: 3), // Thời gian timeout
        verificationCompleted: (fb.PhoneAuthCredential credential) {},
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!_isNavigated && mounted) {
            setState(() => _isLoading = false);
            Get.snackbar('Lỗi', 'Không thể gửi OTP: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!_isNavigated && mounted) {
            _isNavigated = true;
            Get.off(() => VerifyPhoneOtpForPasswordChangeScreen(
                  phoneNo: widget.phoneNo,
                  verificationId: verificationId,
                ));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!_isNavigated && mounted) {
            _isNavigated = true;
            Get.off(() => VerifyPhoneOtpForPasswordChangeScreen(
                  phoneNo: widget.phoneNo,
                  verificationId: verificationId,
                ));
          }
        },
      );
    } catch (e) {
      if (!_isNavigated && mounted) {
        setState(() => _isLoading = false);
        Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.offUntil(
              GetPageRoute(page: () => const ProfileScreen()),
              (route) => route.isFirst
            );
          },
        ),
        title: const Text('Đang gửi OTP'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Đang gửi mã OTP...'),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Get.offUntil(
                        GetPageRoute(page: () => const ProfileScreen()),
                        (route) =>
                            route.isFirst ||
                            route.settings.name == '/ProfileScreen',
                      );
                    },
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Color(0xFF00A2FF)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã xảy ra lỗi khi gửi OTP'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _isNavigated = false;
                      });
                      _sendOtp();
                    },
                    child: const Text('Thử lại'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Get.offUntil(
                        GetPageRoute(page: () => const ProfileScreen()),
                        (route) =>
                            route.isFirst ||
                            route.settings.name == '/ProfileScreen',
                      );
                    },
                    child: const Text('Quay lại'),
                  ),
                ],
              ),
      ),
    );
  }
}