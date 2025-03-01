import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';

import 'package:flutter_elearning_project/features/course/screens/widgets/featured_courses.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/popular_tests.dart';
import 'package:flutter_elearning_project/features/personalization/screens/course/my_courses.dart';
import 'package:flutter_elearning_project/features/personalization/screens/course/test_result.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/promo_slider.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/quick_stats.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/today_schedule.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/unified_search_bar.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testController = Get.put(PracticeTestController());
    final searchController = TextEditingController();

    return Scaffold(
      body: SingleChildScrollView(
        // Cho phép giao diện cuộn theo chiều dọc
        child: Column(
          children: [
            /// -- Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// -- AppBar
                  const THomeAppBar(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: TSizes.defaultSpace),
                    child: UnifiedSearchBar(
                      searchController: searchController,
                      onSearch: (query) {
                        // Implement unified search logic here
                        // Update results in CourseController and TestController
                      },
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            /// Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Promo Slider
                  const TPromoSlider(banners: [
                    TImages.banner6,
                    TImages.banner3,
                    TImages.banner4
                  ]),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Section Lịch học hôm nay
                  TSectionHeading(
                      title: 'Lịch học hôm nay',
                      buttonTitle: 'Xem Lịch học của tôi',
                      onPressed: () => Get.find<NavigationController>()
                          .selectedIndex
                          .value = 4),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const TodayScheduleSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Section Khoá học của tôi
                  TSectionHeading(
                      title: 'Khoá học của tôi',
                      onPressed: () => Get.find<NavigationController>()
                          .selectedIndex
                          .value = 4),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const MyCourseSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Section Kết quả luyện thi mới nhất
                  TSectionHeading(
                      title: 'Kết quả luyện thi mới nhất',
                      onPressed: () => Get.find<NavigationController>()
                          .selectedIndex
                          .value = 4),
                  const LatestTestResultsSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Featured Courses Section
                  TSectionHeading(
                      title: 'Khóa học nổi bật',
                      onPressed: () => Get.find<NavigationController>()
                          .selectedIndex
                          .value = 1),
                  const FeaturedCoursesSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Popular Practice Tests Section
                  TSectionHeading(
                      title: 'Đề thi phổ biến',
                      onPressed: () => Get.find<NavigationController>()
                          .selectedIndex
                          .value = 2),
                  // PopularTestsSection(controller: testController),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Quick Stats Section
                  const QuickStatsSection(),

                  // // Latest Updates Section
                  // const LatestUpdatesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
