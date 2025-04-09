import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
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

  // Hàm chung để xử lý upload image cho cả web và mobile
  Future<void> _uploadImage(String endpoint, dynamic imageFile) async {
    final isAvatar = endpoint.contains('avatar');
    try {
      if (isAvatar) {
        isAvatarLoading.value = true;
      } else {
        isCoverLoading.value = true;
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var uri = Uri.parse(ApiConstants.getUrl(endpoint));
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      });

      final fieldName = endpoint.contains('avatar') ? 'avatar' : 'coverImage';

      if (kIsWeb) {
        // Web platform
        final XFile file = imageFile as XFile;
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            fieldName,
            bytes,
            filename: file.name,
            contentType: MediaType.parse(file.mimeType ?? 'image/jpeg'),
          ),
        );
      } else {
        // Mobile platform
        final File file = File(imageFile.path);
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await authController.refreshUserData();
        update();
        Get.snackbar(
          'Thành công',
          'Cập nhật ảnh thành công',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw jsonDecode(response.body)['message'] ?? 'Cập nhật ảnh thất bại';
      }
    } catch (e) {
      log('Upload error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (isAvatar) {
        isAvatarLoading.value = false;
      } else {
        isCoverLoading.value = false;
      }
    }
  }

  Future<void> pickAndUploadImage(String type) async {
    try {
      errorMessage.value = '';

      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: Get.context!,
        builder: (BuildContext context) => SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp ảnh'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final endpoint = type == 'avatar' ? '/profile/avatar' : '/profile/cover';
      await _uploadImage(endpoint, pickedFile);

      // Force rebuild widget
      Get.forceAppUpdate();
    } catch (e) {
      log('Error in pickAndUploadImage: $e');
      Get.snackbar('Lỗi', e.toString(), snackPosition: SnackPosition.BOTTOM);
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
        // Xử lý các mã lỗi khác
        final error = jsonDecode(response.body);
        String errorMsg = error['message'] ?? 'Cập nhật thất bại';

        if (response.statusCode == 400 &&
            errorMsg == 'Tên người dùng đã tồn tại!') {
          errorMessage.value = errorMsg;
          Get.snackbar(
            'Lỗi',
            'Tên người dùng đã tồn tại, vui lòng chọn tên khác!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else if (response.statusCode == 404) {
          errorMessage.value = errorMsg;
          Get.snackbar(
            'Lỗi',
            'Không tìm thấy người dùng!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          errorMessage.value = errorMsg;
          Get.snackbar(
            'Lỗi',
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      errorMessage.value = 'Đã xảy ra lỗi không xác định: $e';
      Get.snackbar(
        'Lỗi',
        'Đã xảy ra lỗi không xác định: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
