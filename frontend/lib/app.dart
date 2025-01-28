import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/utils/theme/theme.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

/// -- Use this Class to setup theme s, initial Bindings, any animations and much

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Learning App',
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
