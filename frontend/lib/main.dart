import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/providers/auth_provider.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // debugPaintSizeEnabled = true; // Bật Debug Paint

  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting(
      'vi_VN', null); //intl để định dạng ngày theo ngôn ngữ

  FlutterNativeSplash.preserve(
      widgetsBinding: widgetsBinding); // Giữ Splash Screen Native

  // Khởi tạo Firebase trước
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Sau khi Firebase đã khởi tạo, mới gọi các dịch vụ của Firebase
  await fb.FirebaseAuth.instance
      .setSettings(appVerificationDisabledForTesting: true);

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
