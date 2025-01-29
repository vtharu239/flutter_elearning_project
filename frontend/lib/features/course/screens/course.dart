import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
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
    final controller = Get.put(CourseController());

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
                ],
              ),
            ),

            // Body content
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Popular Course Categories
                  const TSectionHeading(title: 'Thể loại'),
                  PopularCategoriesGrid(controller: controller),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Featured Courses
                  const TSectionHeading(title: 'Khóa học nổi bật'),
                  FeaturedCoursesSection(controller: controller),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Combo Courses
                  const TSectionHeading(title: 'Combo khóa học'),
                  CourseListSection(controller: controller, type: 'combo'),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // TOEIC Courses
                  const TSectionHeading(title: 'Khóa học TOEIC'),
                  CourseListSection(controller: controller, type: 'toeic'),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // IELTS Courses
                  const TSectionHeading(title: 'Khóa học IELTS'),
                  CourseListSection(controller: controller, type: 'ielts'),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Basic English Courses
                  const TSectionHeading(title: 'Khóa học Tiếng Anh cơ bản'),
                  CourseListSection(controller: controller, type: 'basic'),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
