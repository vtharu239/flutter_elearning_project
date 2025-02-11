import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/models/User.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  final Rx<User?> user = Rx<User?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    // checkLoginStatus() will be called from main.dart before app starts
  }

  // Lấy thông tin user mới nhất từ server
  Future<void> refreshUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse(ApiConstants.getUrl(ApiConstants.getProfile)),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);

        // Cập nhật thông tin user trong SharedPreferences
        await prefs.setString('user', json.encode(userData));

        // Cập nhật state
        setUser(userData);
      } else if (response.statusCode == 401) {
        // Token hết hạn hoặc không hợp lệ
        await logout();
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  // Kiểm tra trạng thái đăng nhập khi khởi động app
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userStr = prefs.getString('user');
    final rememberMe = prefs.getBool('rememberMe') ?? false;

    if (token != null && userStr != null) {
      if (rememberMe) {
        // Nếu remember me = true, kiểm tra token và load user
        try {
          // Đầu tiên set user từ dữ liệu local để UI hiển thị ngay
          final userData = json.decode(userStr);
          setUser(userData);
          isLoggedIn.value = true;

          // Sau đó refresh dữ liệu từ server
          await refreshUserData();
        } catch (e) {
          await logout();
        }
      } else {
        // Nếu remember me = false, xóa token và user data khi khởi động app
        await logout(shouldNavigate: false);
      }
    }
  }

  // Hàm helper để cập nhật thông tin user cục bộ
  Future<void> updateLocalUserData(Map<String, dynamic> newUserData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(newUserData));
    setUser(newUserData);
  }

  // Set user và lưu trạng thái đăng nhập
  Future<void> setUserAndLoginState(
      Map<String, dynamic> userData, String token, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();

    // Lưu token và user data
    await prefs.setString('token', token);
    await prefs.setString('user', json.encode(userData));
    await prefs.setBool('rememberMe', rememberMe);

    setUser(userData);
    isLoggedIn.value = true;
  }

  void setUser(Map<String, dynamic> userData) {
    user.value = User(
      id: userData['id'],
      email: userData['email'],
      username: userData['username'],
      fullName: userData['fullName'],
      gender: userData['gender'],
      dateOfBirth: userData['dateOfBirth'],
      phoneNo: userData['phoneNo'],
      avatarUrl: userData['avatarUrl'],
      coverImageUrl: userData['coverImageUrl'],
    );
  }

  // Đăng xuất
  Future<void> logout({bool shouldNavigate = true}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('rememberMe');
    user.value = null;
    isLoggedIn.value = false;
    if (shouldNavigate) {
      Get.offAll(() => const LoginScreen());
    }
  }
}
