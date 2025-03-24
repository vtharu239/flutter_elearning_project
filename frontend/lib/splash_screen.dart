import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      final authController = Get.find<AuthController>();
      Get.off(() => authController.isLoggedIn.value
          ? const NavigationMenu()
          : const LoginScreen());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A2FF), // Màu nền xanh
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/logos/studymate_logo.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}