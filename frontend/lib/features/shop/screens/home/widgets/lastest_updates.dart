import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/shadows.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class LatestUpdatesSection extends StatelessWidget {
  const LatestUpdatesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: [TShadowStyle.verticalProductShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cập nhật mới nhất',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildUpdateItem(
            context,
            title: 'Khóa học IELTS mới',
            description: 'Đã thêm 5 khóa học IELTS mới',
            icon: Iconsax.message_add,
            date: '2 giờ trước',
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          _buildUpdateItem(
            context,
            title: 'Đề thi TOEIC 2024',
            description: 'Cập nhật bộ đề thi TOEIC ETS 2024',
            icon: Iconsax.document_upload,
            date: '1 ngày trước',
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String date,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(TSizes.sm),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TSizes.sm),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          date,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}