import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/providers/auth_provider.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';

void main() async {
  // debugPaintSizeEnabled = true; // Bật Debug Paint
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo các controllers
  final authController = Get.put(AuthController());

  // Kiểm tra trạng thái đăng nhập trước khi render UI
  await authController.checkLoginStatus();

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
