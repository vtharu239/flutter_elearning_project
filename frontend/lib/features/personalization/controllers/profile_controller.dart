import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http_parser/http_parser.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find();
  final ImagePicker imagePicker = ImagePicker();

  final isLoading = false.obs;
  final isAvatarLoading = false.obs;
  final isCoverLoading = false.obs;
  final errorMessage = ''.obs;

  // Upload image for web platform
  Future<void> _uploadImageWeb(String endpoint, XFile pickedFile) async {
    final isAvatar = endpoint.contains('avatar');

    try {
      // Set appropriate loading state
      if (isAvatar) {
        isAvatarLoading.value = true;
      } else {
        isCoverLoading.value = true;
      }

      // Validate file type before upload
      final String mimeType = pickedFile.mimeType ?? '';
      final validImageTypes = [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/gif'
      ];

      if (!validImageTypes.contains(mimeType.toLowerCase())) {
        throw 'Chỉ chấp nhận file ảnh (jpeg/jpg/png/gif)!';
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Read file as bytes
      final bytes = await pickedFile.readAsBytes();

      // Create request
      final uri = Uri.parse(ApiConstants.getUrl(endpoint));
      var request = http.MultipartRequest('POST', uri);

      // Add file with explicit mime type
      final fieldName = endpoint.contains('avatar') ? 'avatar' : 'coverImage';
      final file = http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: pickedFile.name,
        contentType: MediaType.parse(mimeType),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
        'ngrok-skip-browser-warning': 'true',
      });

      request.files.add(file);

      // Send request and handle response
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        jsonDecode(response.body);

        // Cập nhật user data trong AuthController
        await authController.refreshUserData();

        // Force update UI
        update();

        // Thông báo thành công
        Get.snackbar(
          'Thành công',
          'Cập nhật ảnh thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        String errorMessage;
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? 'Cập nhật ảnh thất bại';
        } catch (e) {
          errorMessage = 'Lỗi máy chủ: ${response.statusCode}';
        }
        throw errorMessage;
      }
    } catch (e) {
      print('Upload error: $e');
      errorMessage.value = e.toString();
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      // Clear appropriate loading state
      if (isAvatar) {
        isAvatarLoading.value = false;
      } else {
        isCoverLoading.value = false;
      }
    }
  }

  // Pick and upload image
  Future<void> pickAndUploadImage(String type) async {
    try {
      errorMessage.value = '';

      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        print('No file picked');
        return;
      }

      print('File picked: ${pickedFile.name}');
      final endpoint = type == 'avatar' ? '/profile/avatar' : '/profile/cover';

      if (kIsWeb) {
        await _uploadImageWeb(endpoint, pickedFile);
        // Force rebuild của widget
        Get.forceAppUpdate();
      } else {
        throw 'Chỉ hỗ trợ tải ảnh trên web';
      }
    } catch (e) {
      print('Error in pickAndUploadImage: $e');
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? gender,
    String? dateOfBirth,
    String? phoneNo,
    String? username,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse(ApiConstants.getUrl(ApiConstants.getProfile)),
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (fullName != null) 'fullName': fullName,
          if (gender != null) 'gender': gender,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
          if (phoneNo != null) 'phoneNo': phoneNo,
          if (username != null) 'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await authController.updateLocalUserData(userData);
        Get.snackbar(
          'Thành công',
          'Cập nhật thông tin thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final error = jsonDecode(response.body);
        throw error['message'] ?? 'Cập nhật thất bại';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Lỗi',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
