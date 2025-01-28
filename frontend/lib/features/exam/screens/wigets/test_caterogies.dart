import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

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
