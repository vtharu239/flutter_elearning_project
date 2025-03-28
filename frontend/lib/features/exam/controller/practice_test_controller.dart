import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PracticeTestController extends GetxController {
  final selectedCategory = 'all'.obs;
  final selectedSort = 'newest'.obs;
  final selectedFilters = <String>{}.obs;
  final bookmarkedTests = <String>{}.obs;
  final tests = <dynamic>[].obs;
  final categories = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchTests();
  }

  Future<void> fetchCategories() async {
    try {
      final uri = Uri.parse(ApiConstants.getUrl(ApiConstants.getAllCategory));
      final response = await http.get(uri, headers: ApiConstants.getHeaders());
      if (response.statusCode == 200) {
        categories.value = json.decode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load categories: $e');
    }
  }

  Future<void> fetchTests() async {
    try {
      final queryParams = {
        'categoryName': selectedCategory.value,
        'sort': selectedSort.value,
        if (selectedFilters.isNotEmpty) 'filters': selectedFilters.join(',')
      };

      final uri = Uri.parse(ApiConstants.getUrl(ApiConstants.getAllTests))
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: ApiConstants.getHeaders());
      if (response.statusCode == 200) {
        tests.value = json.decode(response.body);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tests: $e');
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    fetchTests();
  }

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    fetchTests();
  }

  void setSort(String sort) {
    selectedSort.value = sort;
    fetchTests();
  }

  bool isBookmarked(String testId) => bookmarkedTests.contains(testId);

  void toggleBookmark(String testId) {
    if (bookmarkedTests.contains(testId)) {
      bookmarkedTests.remove(testId);
    } else {
      bookmarkedTests.add(testId);
    }
  }
}
