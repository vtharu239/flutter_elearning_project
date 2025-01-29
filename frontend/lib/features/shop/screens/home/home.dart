import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
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
    final courseController = Get.put(CourseController());
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
                  const TodayScheduleSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Section Khoá học của tôi
                  const MyCourseSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Section Kết quả luyện thi mới nhất
                  const LatestTestResultsSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Featured Courses Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Khóa học nổi bật',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.find<NavigationController>()
                            .selectedIndex
                            .value = 1,
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  FeaturedCoursesSection(controller: courseController),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Popular Practice Tests Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Đề thi phổ biến',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.find<NavigationController>()
                            .selectedIndex
                            .value = 2,
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  PopularTestsSection(controller: testController),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Quick Stats Section
                  const QuickStatsSection(),
                  const SizedBox(height: TSizes.spaceBtwSections),

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
