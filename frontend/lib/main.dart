import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/providers/auth_provider.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() {

  // Khởi tạo AuthController ngay khi app starts
  Get.put(AuthController());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],    
      child: const App(),
    ),
  );
}

// stl: shortcut to create a new class