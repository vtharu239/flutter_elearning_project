import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/styles/shadows.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/search_container.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/exam_appbar.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
                  SizedBox(height: TSizes.spaceBtwSections),
                  TExamAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// -- SearchBar
                  TSerachContainer(text: 'Tìm kiếm đề thi...'),
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
                  const SizedBox(height: TSizes.spaceBtwItems),
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

class TestCategoriesSection extends StatelessWidget {
  final PracticeTestController controller;

  const TestCategoriesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Obx(() => CategoryChip(
                label: 'Tất cả',
                isSelected: controller.selectedCategory.value == 'all',
                onSelected: () => controller.setCategory('all'),
              )),
          Obx(() => CategoryChip(
                label: 'TOEIC',
                isSelected: controller.selectedCategory.value == 'toeic',
                onSelected: () => controller.setCategory('toeic'),
              )),
          Obx(() => CategoryChip(
                label: 'IELTS',
                isSelected: controller.selectedCategory.value == 'ielts',
                onSelected: () => controller.setCategory('ielts'),
              )),
          Obx(() => CategoryChip(
                label: 'HSK 1',
                isSelected: controller.selectedCategory.value == 'hsk1',
                onSelected: () => controller.setCategory('hsk1'),
              )),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: TSizes.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue.withOpacity(0.2),
        checkmarkColor: Colors.blue,
      ),
    );
  }
}

class FilterSortSection extends StatelessWidget {
  final PracticeTestController controller;

  const FilterSortSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          // Thay đổi Row thành Column
          children: [
            // Phần sắp xếp
            Row(
              children: [
                const Icon(Iconsax.sort, size: 20),
                const SizedBox(width: TSizes.sm),
                const Text('Sắp xếp theo:'),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  // Wrap DropdownButton trong Expanded
                  child: DropdownButton<String>(
                    value: controller.selectedSort.value,
                    isExpanded: true, // Thêm thuộc tính này
                    items: const [
                      DropdownMenuItem(
                          value: 'newest', child: Text('Mới nhất')),
                      DropdownMenuItem(
                          value: 'popular', child: Text('Phổ biến nhất')),
                      DropdownMenuItem(
                          value: 'difficulty', child: Text('Độ khó')),
                    ],
                    onChanged: (value) =>
                        controller.selectedSort.value = value!,
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.sm), // Khoảng cách giữa 2 hàng

            // Phần filter
            Wrap(
              // Sử dụng Wrap cho các FilterChip
              spacing: TSizes.xs, // Khoảng cách giữa các chip theo chiều ngang
              runSpacing: TSizes.xs, // Khoảng cách giữa các hàng
              children: [
                FilterChip(
                  label: const Text('Đã làm'),
                  selected: controller.selectedFilters.contains('done'),
                  onSelected: (_) => controller.toggleFilter('done'),
                ),
                FilterChip(
                  label: const Text('Chưa làm'),
                  selected: controller.selectedFilters.contains('notDone'),
                  onSelected: (_) => controller.toggleFilter('notDone'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TestCard extends StatelessWidget {
  final PracticeTestController controller;
  final String testId;

  const TestCard({
    super.key,
    required this.controller,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [TShadowStyle.verticalProductShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: const Center(
              child: Icon(Iconsax.document, size: 30, color: Colors.blue),
            ),
          ),
          const SizedBox(width: TSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đề thi TOEIC ETS 2024 - Test 01',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'TOEIC',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: TSizes.xs),
                    Text(
                      '2 phần • 120 phút',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Icon(Iconsax.user, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: TSizes.xs),
                    Text(
                      '1.2k lượt thi',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: TSizes.md),
                    Icon(Iconsax.level, size: 16, color: Colors.amber[600]),
                    const SizedBox(width: TSizes.xs),
                    Text(
                      'Trung bình',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: TSizes.md),
                    Icon(Iconsax.message, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: TSizes.xs),
                    Text(
                      '24',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Obx(() => IconButton(
                    onPressed: () => controller.toggleBookmark(testId),
                    icon: Icon(
                      controller.isBookmarked(testId)
                          ? Iconsax.bookmark_2
                          : Iconsax.bookmark,
                      color: controller.isBookmarked(testId)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  )),
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.arrow_right_3, color: Colors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BookmarkedTestsHeader extends StatelessWidget {
  const BookmarkedTestsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Đề thi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.bookmark),
          label: const Text('Đã lưu'),
        ),
      ],
    );
  }
}

class TestListSection extends StatelessWidget {
  final PracticeTestController controller;

  const TestListSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return TestCard(controller: controller, testId: 'test_$index');
      },
    );
  }
}