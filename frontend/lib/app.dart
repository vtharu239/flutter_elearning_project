import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:flutter_elearning_project/splash_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// -- Use this Class to setup theme s, initial Bindings, any animations and much

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      title: 'E-Learning App',
      themeMode: themeProvider.themeMode == ThemeModeType.system
          ? ThemeMode.system
          : themeProvider.themeMode == ThemeModeType.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Color(0xFF00A2FF)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00A2FF), width: 2.0),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF00A2FF),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromARGB(155, 39, 36, 36),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
        inputDecorationTheme: const InputDecorationTheme(
          floatingLabelStyle: TextStyle(color: Color(0xFF00A2FF)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00A2FF), width: 2.0),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF00A2FF),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
