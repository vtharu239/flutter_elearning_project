import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/component/verify_phoneotp_for_change_password.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class InitiatePhoneOtpForPasswordChangeScreen extends StatelessWidget {
  final String phoneNo;

  const InitiatePhoneOtpForPasswordChangeScreen(
      {super.key, required this.phoneNo});

  Future<void> _sendOtp(BuildContext context) async {
    // Thêm biến để kiểm soát việc chuyển trang
    bool isNavigated = false;

    try {
      // Reset Firebase Auth state trước khi gửi yêu cầu mới
      fb.FirebaseAuth.instance.signOut().then((_) {
        log('Firebase Auth signed out');
      });
      // Thêm thời gian timeout ngắn hơn
      await fb.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 3), // Thêm timeout rõ ràng
        verificationCompleted: (fb.PhoneAuthCredential credential) {},
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!isNavigated) {
            Get.snackbar('Lỗi', 'Không thể gửi OTP: ${e.message}');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          isNavigated = true;
          Get.to(() => VerifyPhoneOtpForPasswordChangeScreen(
                phoneNo: phoneNo,
                verificationId: verificationId,
              ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Nếu quá thời gian và chưa chuyển trang, chuyển trang với verificationId nhận được
          if (!isNavigated) {
            isNavigated = true;
            Get.to(() => VerifyPhoneOtpForPasswordChangeScreen(
                  phoneNo: phoneNo,
                  verificationId: verificationId,
                ));
          }
        },
      );

      // // Thêm một timer để tránh màn hình loading vô hạn
      // Future.delayed(const Duration(seconds: 5), () {
      //   if (!isNavigated) {
      //     Get.snackbar('Thông báo', 'Đang chờ phản hồi từ hệ thống...');
      //   }
      // });
    } catch (e) {
      if (!isNavigated) {
        Get.snackbar('Lỗi', 'Không thể gửi OTP: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thêm các nút để người dùng có thể hủy hoặc thử lại
    _sendOtp(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: const Text('Đang gửi OTP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Đang gửi mã OTP...'),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Get.back(),
              child:
                  const Text('Hủy', style: TextStyle(color: Color(0xFF00A2FF))),
            ),
          ],
        ),
      ),
    );
  }
}
