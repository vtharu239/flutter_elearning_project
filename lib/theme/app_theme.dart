import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    // textTheme: TextTheme(
    //   headline1: TextStyle(color: Colors.black87),
    //   bodyText1: TextStyle(color: Colors.black87),
    //   bodyText2: TextStyle(color: Colors.black87),
    // ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    // textTheme: TextTheme(
    //   headline1: TextStyle(color: Colors.white),
    //   bodyText1: TextStyle(color: Colors.white),
    //   bodyText2: TextStyle(color: Colors.white),
    // ),
  );
}
