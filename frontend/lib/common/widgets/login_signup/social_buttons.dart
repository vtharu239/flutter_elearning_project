import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class TSocialButtons extends StatelessWidget {
  const TSocialButtons({
    super.key,
  });

  Future<void> _googleSignIn() async {
    try {
      if (GetPlatform.isWeb) {
        // Web flow
        await fb.FirebaseAuth.instance.signOut(); // Đăng xuất Firebase Auth
        fb.GoogleAuthProvider googleProvider = fb.GoogleAuthProvider();
        googleProvider.setCustomParameters(
            {'prompt': 'select_account'}); // Buộc chọn tài khoản
        final userCredential =
            await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);
        final idToken = await userCredential.user!.getIdToken();
        await Get.find<AuthController>().socialLogin(idToken!, 'google');
      } else {
        // Mobile/emulator flow
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential =
            await fb.FirebaseAuth.instance.signInWithCredential(credential);
        final idToken = await userCredential.user!.getIdToken();
        await Get.find<AuthController>().socialLogin(idToken!, 'google');
      }
    } catch (e) {
      log('Google Sign In error: $e'); // Debug
      Get.snackbar('Lỗi', 'Không thể đăng nhập bằng Google!');
    }
  }

  Future<void> _facebookSignIn() async {
    try {
      if (GetPlatform.isWeb) {
        // Web flow
        await fb.FirebaseAuth.instance
            .signOut(); // Đăng xuất để yêu cầu chọn tài khoản
        fb.FacebookAuthProvider facebookProvider = fb.FacebookAuthProvider();
        facebookProvider
            .addScope('public_profile'); // Chỉ yêu cầu public_profile
        final userCredential =
            await fb.FirebaseAuth.instance.signInWithPopup(facebookProvider);
        final idToken = await userCredential.user!.getIdToken();
        await Get.find<AuthController>().socialLogin(idToken!, 'facebook');
      } else {
        // Mobile/emulator flow
        log('Starting Facebook Sign In');
        log('Attempting to log out from previous session');
        // await FacebookAuth.instance.logOut();
        final LoginResult result = await FacebookAuth.instance.login(
          permissions: ['public_profile'], // Chỉ yêu cầu public_profile
        );
        log('Login result: ${result.status} - ${result.message}');
        if (result.status != LoginStatus.success) {
          log('Facebook login failed: ${result.status} - ${result.message}');
          Get.snackbar('Lỗi', 'Không thể đăng nhập: ${result.message}');
          return;
        }
        final fb.OAuthCredential credential =
            fb.FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final userCredential =
            await fb.FirebaseAuth.instance.signInWithCredential(credential);
        final idToken = await userCredential.user!.getIdToken();
        log('Facebook login successful, idToken: $idToken');
        await Get.find<AuthController>().socialLogin(idToken!, 'facebook');
      }
    } catch (e) {
      log('Facebook Sign In error: $e');
      Get.snackbar('Lỗi', 'Không thể đăng nhập bằng Facebook!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: TColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: _googleSignIn,
            icon: const Image(
              width: TSizes.iconLg,
              height: TSizes.iconLg,
              image: AssetImage(TImages.google),
            ),
          ),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: TColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: _facebookSignIn,
            icon: const Image(
              width: TSizes.iconLg,
              height: TSizes.iconLg,
              image: AssetImage(TImages.facebook),
            ),
          ),
        ),
      ],
    );
  }
}
