import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/bookmarked_test_header.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/exam_appbar.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/filter_sort_test.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_card.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_caterogies.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';

class PracticeTestScreen extends StatelessWidget {
  const PracticeTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PracticeTestController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section với thanh tìm kiếm
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// -- AppBar
                  TExamAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Test Categories Section
                  const TSectionHeading(title: 'Thể loại thi'),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TestCategoriesSection(controller: controller),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Sort and Filter Section
                  FilterSortSection(controller: controller),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Test List Section
                  const BookmarkedTestsHeader(),
                  TestListSection(controller: controller),
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
