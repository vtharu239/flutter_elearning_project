import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class FilterSortSection extends StatelessWidget {
  final PracticeTestController controller;

  const FilterSortSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra chế độ sáng tối
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.grey[700]!
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Obx(
        () => Column(
          children: [
            // Phần sắp xếp
            Row(
              children: [
                const Icon(Iconsax.sort, size: 20),
                const SizedBox(width: TSizes.sm),
                Text(
                  'Sắp xếp theo:',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: DropdownButton<String>(
                    value: controller.selectedSort.value,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                          value: 'newest', child: Text('Mới nhất')),
                      DropdownMenuItem(
                          value: 'popular', child: Text('Phổ biến nhất')),
                      DropdownMenuItem(
                          value: 'difficulty', child: Text('Độ khó')),
                    ],
                    onChanged: (value) => controller.setSort(value!),
                    underline: const SizedBox(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    dropdownColor: isDarkMode ? Colors.grey[850] : Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.sm),

            // Phần filter
            Wrap(
              spacing: TSizes.xs, // Khoảng cách giữa các chip theo chiều ngang
              runSpacing: TSizes.xs, // Khoảng cách giữa các hàng
              children: [
                FilterChip(
                  label: const Text('Đã làm'),
                  selected: controller.selectedFilters.contains('done'),
                  onSelected: (_) => controller.toggleFilter('done'),
                  selectedColor: Colors.green[700], // Màu nền khi được chọn
                  backgroundColor: isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[200], // Màu nền khi chưa chọn
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black, // Màu chữ của filter chip
                  ),
                ),
                FilterChip(
                  label: const Text('Chưa làm'),
                  selected: controller.selectedFilters.contains('notDone'),
                  onSelected: (_) => controller.toggleFilter('notDone'),
                  selectedColor: Colors.orange[700], // Màu nền khi được chọn
                  backgroundColor: isDarkMode
                      ? Colors.grey[700]
                      : Colors.grey[200], // Màu nền khi chưa chọn
                  labelStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : Colors.black, // Màu chữ của filter chip
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
