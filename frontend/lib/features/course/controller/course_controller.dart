import 'dart:developer';

import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/course/controller/course_model.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CourseController extends GetxController {
  final RxString selectedCategory = 'all'.obs;
  final RxList<Course> allCourses = <Course>[].obs; // Tất cả khóa học
  final RxList<Course> courses = <Course>[].obs; // Khóa học đã lọc
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllCourses();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    filterCourses(); // Lọc khóa học từ danh sách đã có
  }

  // Lọc khóa học dựa trên danh mục đã chọn
  void filterCourses() {
    if (selectedCategory.value == 'all') {
      courses.value = allCourses;
    } else {
      courses.value = allCourses
          .where((course) =>
              course.categoryId.toString() == selectedCategory.value)
          .toList();
    }
  }

  // Lấy tất cả khóa học từ API
  Future<void> fetchAllCourses() async {
    try {
      isLoading.value = true;

      String url = ApiConstants.getUrl(ApiConstants.getAllCourse);
      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        allCourses.value = data.map((json) => Course.fromJson(json)).toList();
        filterCourses(); // Lọc khóa học sau khi tải xong
      }
    } catch (e) {
      log('Error fetching courses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Phương thức để đếm số khóa học trong một danh mục
  int countCoursesInCategory(String categoryId) {
    return allCourses
        .where((course) => course.categoryId.toString() == categoryId)
        .length;
  }
}
