import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_phoneotp_for_change_password.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class InitiatePhoneOtpForPasswordChangeScreen extends StatelessWidget {
  final String phoneNo;

  const InitiatePhoneOtpForPasswordChangeScreen({super.key, required this.phoneNo});

  Future<void> _sendOtp(BuildContext context) async {
    try {
      await fb.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (fb.PhoneAuthCredential credential) {},
        verificationFailed: (fb.FirebaseAuthException e) {
          Get.snackbar('Lỗi', 'Không thể gửi OTP: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          Get.to(() => VerifyPhoneOtpForPasswordChangeScreen(
                phoneNo: phoneNo,
                verificationId: verificationId,
              ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _sendOtp(context); // Gửi OTP ngay khi vào màn hình
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}