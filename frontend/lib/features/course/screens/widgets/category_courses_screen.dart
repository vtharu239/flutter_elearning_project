import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_list_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CategoryCoursesScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const CategoryCoursesScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final courseController = Get.find<CourseController>();
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    Map<int, int> studentCounts = {};
    bool isLoadingStudentCount = true;

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (courseController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter courses by categoryId
        final filteredCourses = courseController.courses
            .where((course) => course.categoryId.toString() == categoryId)
            .toList();

        if (filteredCourses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 72,
                  color: Colors.grey,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'Không có khóa học nào cho danh mục này',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Quay lại'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course list heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách khóa học',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Sắp xếp'),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Course list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  final course = filteredCourses[index];
                  return VerticalCourseCard(
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
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
