import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class TImageOptionsSheet extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;

  const TImageOptionsSheet({
    super.key,
    required this.onView,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      decoration: BoxDecoration(
        color: isDarkMode ? TColors.darkerGrey : Colors.white,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(TSizes.cardRadiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title bar with drag indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Options list
          ListTile(
            leading: const Icon(Iconsax.image),
            title: const Text('Xem ảnh'),
            onTap: () {
              Navigator.pop(context);
              onView();
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.edit),
            title: const Text('Chỉnh sửa ảnh'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
        ],
      ),
    );
  }
}
