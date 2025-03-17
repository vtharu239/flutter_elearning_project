import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// -- Use this Class to setup theme s, initial Bindings, any animations and much

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authController = Get.find<AuthController>();

    return GetMaterialApp(
      title: 'E-Learning App',
      themeMode: themeProvider.themeMode == ThemeModeType.system
          ? ThemeMode.system
          : themeProvider.themeMode == ThemeModeType.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white, // Màu nền cho toàn bộ ứng dụng
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Colors.transparent, // Màu nền AppBar cho toàn bộ ứng dụng
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle:
              TextStyle(color: Color(0xFF00A2FF)), // Màu label khi focus
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00A2FF), width: 2.0),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF00A2FF), // Đặt màu dấu nháy (cursor)
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(
            155, 39, 36, 36), // Màu nền cho toàn bộ ứng dụng khi ở chế độ dark
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // Màu nền AppBar cho chế độ dark
        ),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle:
              TextStyle(color: Color(0xFF00A2FF)), // Màu label khi focus
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00A2FF), width: 2.0),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF00A2FF), // Đặt màu dấu nháy (cursor)
        ),
      ),
      home: Obx(() => authController.isLoggedIn.value
          ? const NavigationMenu()
          : const LoginScreen()),
    );
  }
}
