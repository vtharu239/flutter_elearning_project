import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_list_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';

// Section hiển thị danh sách khóa học
class CourseListSection extends StatelessWidget {
  final String? categoryId; // Optional, if null will show all courses

  const CourseListSection({
    super.key,
    this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseController>();
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      // Filter courses theo categoryId nếu có specified
      final filteredCourses = categoryId != null
          ? controller.courses
              .where((course) => course.categoryId.toString() == categoryId)
              .toList()
          : controller.courses;

      if (filteredCourses.isEmpty) {
        return SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
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
                      title: course.title,
                      rating: course.rating,
                      ratingCount: course.ratingCount,
                      students: course.studentCount,
                      originalPrice: course.originalPrice,
                      discountPercentage: course.discountPercentage.toInt(),
                      imageUrl: course.imageUrl ??
                          (darkMode
                              ? TImages.productImage1Dark
                              : TImages.productImage1),
                    ))
                .toList(),
          ),
        ],
      );
    });
  }
}
