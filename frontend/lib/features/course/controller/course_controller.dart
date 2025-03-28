import 'dart:developer';

import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/course/controller/course_curriculum.dart';
import 'package:flutter_elearning_project/features/course/controller/course_model.dart';
import 'package:flutter_elearning_project/features/course/controller/course_objective.dart';
import 'package:flutter_elearning_project/features/course/controller/course_rating_stat.dart';
import 'package:flutter_elearning_project/features/course/controller/course_review.dart';
import 'package:flutter_elearning_project/features/course/controller/course_teacher.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CourseController extends GetxController {
  final RxString selectedCategory = 'all'.obs;
  final RxList<Course> allCourses = <Course>[].obs; // Tất cả khóa học
  final RxList<Course> courses = <Course>[].obs; // Khóa học đã lọc
  final RxBool isLoading = false.obs;
  Rx<Course?> course = Rx<Course?>(null);
  RxList<CourseObjective> objectives = <CourseObjective>[].obs;
  RxList<CourseTeacher> teachers = <CourseTeacher>[].obs;
  RxList<CourseCurriculum> curriculum = <CourseCurriculum>[].obs;
  RxList<RatingStats> ratingStats = <RatingStats>[].obs;
  RxList<CourseReview> reviews = <CourseReview>[].obs;
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

  Future<void> fetchCourseDetails(int courseId) async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchCourse(courseId),
        _fetchObjectives(courseId),
        _fetchTeachers(courseId),
        _fetchCurriculum(courseId),
        _fetchRatingStats(courseId),
        _fetchReviews(courseId),
      ]);
    } catch (e) {
      print('Error fetching course details: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCourse(int courseId) async {
    final response = await http.get(
      Uri.parse(
          ApiConstants.getUrl(ApiConstants.getCourseById, courseId: courseId)),
      headers: ApiConstants.getHeaders(),
    );
    if (response.statusCode == 200) {
      course.value = Course.fromJson(jsonDecode(response.body));
    }
  }

  Future<void> _fetchObjectives(int courseId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.getUrl(ApiConstants.courseObjectives)}?courseId=$courseId'),
      headers: ApiConstants.getHeaders(),
    );
    if (response.statusCode == 200) {
      objectives.value = (jsonDecode(response.body) as List)
          .map((e) => CourseObjective.fromJson(e))
          .toList();
    }
  }

  Future<void> _fetchTeachers(int courseId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.getUrl(ApiConstants.courseTeachers)}?courseId=$courseId'),
      headers: ApiConstants.getHeaders(),
    );
    if (response.statusCode == 200) {
      teachers.value = (jsonDecode(response.body) as List)
          .map((e) => CourseTeacher.fromJson(e))
          .toList();
    }
  }

  Future<void> _fetchCurriculum(int courseId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.getUrl(ApiConstants.courseCurriculum)}?courseId=$courseId'),
      headers: ApiConstants.getHeaders(),
    );
    if (response.statusCode == 200) {
      curriculum.value = (jsonDecode(response.body) as List)
          .map((e) => CourseCurriculum.fromJson(e))
          .toList();
    }
  }

  Future<void> _fetchRatingStats(int courseId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.getUrl(ApiConstants.courseRatingStats)}?courseId=$courseId'),
      headers: ApiConstants.getHeaders(),
    );
    if (response.statusCode == 200) {
      ratingStats.value = (jsonDecode(response.body) as List)
          .map((e) => RatingStats.fromJson(e))
          .toList();
    }
  }

  Future<void> _fetchReviews(int courseId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiConstants.getUrl(ApiConstants.courseReviews)}?courseId=$courseId'),
      headers: ApiConstants.getHeaders(),
    );
    if (response.statusCode == 200) {
      reviews.value = (jsonDecode(response.body) as List)
          .map((e) => CourseReview.fromJson(e))
          .toList();
    }
  }
}
