import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Thêm biến để lưu trữ tên người dùng (nếu cần hiển thị)
  String _userName = '';
  String get userName => _userName;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Đăng nhập thông thường
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Giả lập API call
      await Future.delayed(const Duration(seconds: 2));

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email và mật khẩu không được để trống');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
