import 'package:flutter_elearning_project/features/personalization/screens/settings/UserAuthController.dart';
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