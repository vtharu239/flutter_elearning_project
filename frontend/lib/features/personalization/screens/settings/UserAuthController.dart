// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthController extends ChangeNotifier {
  String? _username;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _token;

  String? get username => _username;
  String? get email => _email;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  // Full name combining first and last name
  String get fullName {
    if (_firstName != null && _lastName != null) {
      return '$_firstName $_lastName';
    }
    return _username ?? 'User';
  }

  // Login method to save user details
  Future<void> login({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String token,
  }) async {
    _username = username;
    _email = email;
    _firstName = firstName;
    _lastName = lastName;
    _token = token;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('token', token);

    notifyListeners();
  }

  // Logout method to clear user details
  Future<void> logout() async {
    _username = null;
    _email = null;
    _firstName = null;
    _lastName = null;
    _token = null;

    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('token');

    notifyListeners();
  }

  // Check and restore login state on app start
  Future<void> checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    _firstName = prefs.getString('firstName');
    _lastName = prefs.getString('lastName');
    _token = prefs.getString('token');

    notifyListeners();
  }
}
