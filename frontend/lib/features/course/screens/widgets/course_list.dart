import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_list_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';

class VerticalCourseCardList extends StatelessWidget {
  final int itemCount;
  final List<VerticalCourseCard> items;
  final bool isLoadingStudentCount;

  const VerticalCourseCardList({
    super.key,
    required this.itemCount,
    required this.items,
    required this.isLoadingStudentCount,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.xs),
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}

// Section hiển thị danh sách khóa học
class CourseListSection extends StatefulWidget {
  final String? categoryId;

  const CourseListSection({
    super.key,
    this.categoryId,
  });

  @override
  State<CourseListSection> createState() => _CourseListSectionState();
}

class _CourseListSectionState extends State<CourseListSection> {
  final CourseController controller = Get.find<CourseController>();
  Map<int, int> studentCounts = {};
  bool isLoadingStudentCount = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchStudentCounts();
    });
  }

  Future<void> fetchStudentCounts() async {
    try {
      setState(() {
        isLoadingStudentCount = true;
      });

      final filteredCourses = widget.categoryId != null
          ? controller.courses
              .where(
                  (course) => course.categoryId.toString() == widget.categoryId)
              .toList()
          : controller.courses;

      if (filteredCourses.isEmpty) {
        setState(() {
          isLoadingStudentCount = false;
        });
        return;
      }

      final courseIds = filteredCourses.map((course) => course.id).toList();
      final response = await http.post(
        Uri.parse(ApiConstants.getUrl(ApiConstants.getOrderCountBatch)),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({'courseIds': courseIds}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> counts = jsonDecode(response.body);
        setState(() {
          for (var count in counts) {
            studentCounts[count['courseId']] = count['studentCount'] ?? 0;
          }
          isLoadingStudentCount = false;
        });
      } else {
        print('Failed to load batch student counts: ${response.statusCode}');
        setState(() {
          isLoadingStudentCount = false;
        });
      }
    } catch (e) {
      print('Error fetching batch student counts: $e');
      setState(() {
        isLoadingStudentCount = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final filteredCourses = widget.categoryId != null
          ? controller.courses
              .where(
                  (course) => course.categoryId.toString() == widget.categoryId)
              .toList()
          : controller.courses;

      if (filteredCourses.isEmpty) {
        return SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: TSizes.sm),
                Text(
                  'Không có khóa học nào cho danh mục này',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerticalCourseCardList(
            itemCount: filteredCourses.length,
            items: filteredCourses
                .map((course) => VerticalCourseCard(
                      courseId: course.id,
                      title: course.title,
                      rating: course.rating,
                      ratingCount: course.ratingCount,
                      students: studentCounts[course.id] ?? 0,
                      originalPrice: course.originalPrice,
                      discountPercentage: course.discountPercentage.toInt(),
                      imageUrl: course.imageUrl ??
                          (darkMode
                              ? TImages.productImage1Dark
                              : TImages.productImage1),
                      isLoadingStudentCount: isLoadingStudentCount,
                    ))
                .toList(),
            isLoadingStudentCount: isLoadingStudentCount,
          ),
        ],
      );
    });
  }
}
