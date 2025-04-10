import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/document/model/category_model.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/rounded_container.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(category.title),
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
      ),
      backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const TSectionHeading(
              title: 'Chủ đề liên quan',
              showActionButton: false,
            ),
            const SizedBox(height: 16),

            // Danh sách sub-categories
            Expanded(
              child: ListView.separated(
                itemCount: category.subCategories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final sub = category.subCategories[index];

                  return TRoundedContainer(
                    backgroundColor: TColors.primary.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    radius: 16,
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_outline,
                            color: TColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sub,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
