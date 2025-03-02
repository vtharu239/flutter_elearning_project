import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class UnifiedSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearch;

  const UnifiedSearchBar({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.search_normal,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: TextFormField(
              controller: searchController,
              onChanged: onSearch,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm khóa học, đề thi, tài liệu...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 12), // Điều chỉnh padding dọc
                isDense: true, // Giảm chiều cao mặc định của TextFormField
              ),
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Iconsax.filter),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'course',
                child: Text('Khóa học'),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Text('Đề thi'),
              ),
              const PopupMenuItem(
                value: 'document',
                child: Text('Tài liệu'),
              ),
            ],
            onSelected: (value) {
              // Handle filter selection
            },
          ),
        ],
      ),
    );
  }
}