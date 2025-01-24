// import 'package:flutter/material.dart';
// import 'package:flutter_elearning_project/providers/auth_provider.dart';
// import 'package:flutter_elearning_project/screens/onboarding/onboarding_screen.dart';
// import 'package:flutter_elearning_project/theme/theme_provider.dart';
// import 'package:provider/provider.dart';
import 'package:flutter_elearning_project/features/personalization/screens/settings/UserAuthController.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ThemeProvider>(
//       builder: (context, themeProvider, child) {
//         return MaterialApp(
//           title: 'Study App',
//           theme: themeProvider.lightTheme,
//           darkTheme: themeProvider.darkTheme,
//           themeMode: themeProvider.themeMode,
//           home: OnboardingScreen(),
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/providers/auth_provider.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => UserAuthController()),
      ],
      child: const App(),
    ),
  );
}

// stl: shortcut to create a new class

