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
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryChip(
            label: 'Tất cả',
            isSelected: controller.selectedCategory.value == 'all',
            onSelected: () => controller.setCategory('all'),
          ),
          ...controller.categories.map((category) => CategoryChip(
                label: category['name'],
                isSelected: controller.selectedCategory.value == category['name'],
                onSelected: () => controller.setCategory(category['name']),
              )).toList(),
        ],
      )),
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
    // Kiểm tra chế độ sáng/tối
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: TSizes.sm),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDarkMode ? Colors.blue[300] : Colors.blue[800]) // Màu chữ khi được chọn
                : (isDarkMode ? Colors.white : Colors.black), // Màu chữ khi chưa chọn
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200], // Nền khi chưa chọn
        selectedColor: isDarkMode ? Colors.blue[900] : Colors.blue.withOpacity(0.2), // Nền khi chọn
        checkmarkColor: isDarkMode ? Colors.blue[300] : Colors.blue[800], // Màu dấu check
      ),
    );
  }
}
