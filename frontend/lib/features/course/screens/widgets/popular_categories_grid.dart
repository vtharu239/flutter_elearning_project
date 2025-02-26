import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/category_controller.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/category_card.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/category_courses_screen.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class PopularCategoriesGrid extends StatelessWidget {
  final CategoryController controller;

  const PopularCategoriesGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Đảm bảo CourseController đã được khởi tạo
    if (!Get.isRegistered<CourseController>()) {
      Get.put(CourseController());
    }
    final courseController = Get.find<CourseController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: TSizes.gridViewSpacing,
          crossAxisSpacing: TSizes.gridViewSpacing,
          mainAxisExtent: 70,
        ),
        itemCount: controller.categories.length,
        itemBuilder: (context, index) {
          final category = controller.categories[index];
          // Tính số lượng khóa học cho từng danh mục
          int courseCount = 0;
          if (!courseController.isLoading.value) {
            courseCount = courseController.courses
                .where((course) =>
                    course.categoryId.toString() == category.id.toString())
                .length;
          }

          return Padding(
            padding: const EdgeInsets.all(0), // Đảm bảo không có padding dư
            child: CategoryCard(
              title: category.name,
              icon: Iconsax.book,
              color: Colors.blue,
              courseCount: courseCount,
              onTap: () {
                // Set the selected category in the controller
                controller.setCategory(category.name);

                // Navigate to the category courses screen
                Get.to(() => CategoryCoursesScreen(
                      categoryId: category.id.toString(),
                      categoryName: category.name,
                    ));
              },
            ),
          );
        },
      );
    });
  }
}
