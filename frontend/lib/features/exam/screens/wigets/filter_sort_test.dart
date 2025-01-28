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