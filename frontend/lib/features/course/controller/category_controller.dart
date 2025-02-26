// ignore_for_file: avoid_print

import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Category {
  final int id;
  final String name;
  final String? image;

  Category({
    required this.id,
    required this.name,
    this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class CategoryController extends GetxController {
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategory = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse(ApiConstants.getUrl(ApiConstants.getAllCategory)),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        categories.value = data.map((json) => Category.fromJson(json)).toList();
      } else {
        print('Error fetching categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setCategory(String categoryName) {
    // Find the category ID based on the name
    final category = categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => Category(id: 0, name: 'all'),
    );

    selectedCategory.value = category.id.toString();
    print('Selected category: ${category.name} (ID: ${category.id})');

    // Here you can add additional logic like navigating to a filtered course list
    // For example: Get.to(() => CoursesScreen(categoryId: category.id));
  }

  String getCategoryName(String categoryId) {
    try {
      if (categoryId == 'all') return 'Tất cả';

      final category = categories.firstWhere(
        (c) => c.id.toString() == categoryId,
        orElse: () => Category(id: 0, name: 'Không xác định'),
      );

      return category.name;
    } catch (e) {
      print('Error getting category name: $e');
      return 'Không xác định';
    }
  }
}
