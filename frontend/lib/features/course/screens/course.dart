import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/features/course/controller/category_controller.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_appbar.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_list.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/featured_courses.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/popular_categories_grid.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.put(CategoryController());
    final courseController = Get.put(CourseController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section với thanh tìm kiếm
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TCourseAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                  // SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular Course Categories
                  const TSectionHeading(title: 'Thể loại'),
                  // Container(
                  //   decoration:
                  //       BoxDecoration(border: Border.all(color: Colors.red)),
                  //   child:
                  //       PopularCategoriesGrid(controller: categoryController),
                  // ),
                  PopularCategoriesGrid(controller: categoryController),
                  // Featured Courses
                  SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(title: 'Khóa học nổi bật'),
                  const FeaturedCoursesSection(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  // Hiển thị khóa học dựa theo category đã chọn hoặc tất cả khóa học
                  Obx(() {
                    final selectedCategory =
                        courseController.selectedCategory.value;

                    if (selectedCategory == 'all') {
                      // Hiển thị các khóa học theo tất cả danh mục một cách tự động
                      return Obx(() {
                        if (categoryController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              categoryController.categories.map((category) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TSectionHeading(
                                    title: 'Khóa học ${category.name}'),
                                CourseListSection(
                                    categoryId: category.id.toString()),
                                SizedBox(height: TSizes.spaceBtwSections),
                              ],
                            );
                          }).toList(),
                        );
                      });
                    } else {
                      // Hiển thị khóa học theo category đã chọn
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TSectionHeading(
                            title:
                                'Khóa học ${categoryController.getCategoryName(selectedCategory)}',
                          ),
                          const CourseListSection(),
                        ],
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
