import 'dart:convert';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/models/User.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final Rx<User?> user = Rx<User?>(null);

  void setUser(Map<String, dynamic> userData) {
    user.value = User(
      id: userData['id'],
      email: userData['email'],
      username: userData['username'],
      fullName: userData['fullName'],
      gender: userData['gender'],
    );
  }

  // Lấy user từ shared preferences khi khởi động app
  Future<void> initUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final userData = json.decode(userStr);
      setUser(userData);
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // Xóa dữ liệu user khỏi bộ nhớ
    user.value = null; // Cập nhật trạng thái user
    Get.offAll(const LoginScreen()); // Chuyển hướng về trang đăng nhập
  }
}
