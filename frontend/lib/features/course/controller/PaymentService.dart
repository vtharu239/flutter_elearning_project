import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  Future<Map<String, dynamic>> createPayment({
    required int courseId,
    required double amount,
    String? orderDescription,
  }) async {
    try {
      // Get authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Create headers with authentication token
      final headers = {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createPaymentUrl}'),
        headers: headers,
        body: jsonEncode({
          'courseId': courseId,
          'amount': amount,
          'orderDescription': orderDescription ?? 'Thanh toán khóa học',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Không thể tạo thanh toán: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API thanh toán: $e');
    }
  }

  Future<Map<String, dynamic>> getOrderInfo(int orderId) async {
    try {
      // Get authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Create headers with authentication token
      final headers = {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.getOrderInfo}$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception(
            'Không thể lấy thông tin đơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API lấy thông tin đơn hàng: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      // Get authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Create headers with authentication token
      final headers = {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/user/orders'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((order) => order as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception(
            'Không thể lấy danh sách đơn hàng: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API lấy danh sách đơn hàng: $e');
    }
  }

  Future<bool> hasUserPurchasedCourse(int courseId) async {
    try {
      final orders = await getUserOrders();

      // Check if there's any completed order for this course
      return orders.any((order) =>
          order['courseId'] == courseId && order['status'] == 'completed');
    } catch (e) {
      throw Exception('Error checking course purchase status: $e');
    }
  }
}
