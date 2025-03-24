import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/providers/auth_provider.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;


void main() async {
  // debugPaintSizeEnabled = true; // Bật Debug Paint
  
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); // Giữ Splash Screen Native

  // Khởi tạo Firebase trước
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sau khi Firebase đã khởi tạo, mới gọi các dịch vụ của Firebase
  await fb.FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

  // Khởi tạo các controllers
  final authController = Get.put(AuthController());

  // Kiểm tra trạng thái đăng nhập trước khi render UI
  await authController.checkLoginStatus();

  // Chờ 3 giây trước khi loại bỏ Splash Screen Native
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove(); // Loại bỏ Splash Screen Native

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
