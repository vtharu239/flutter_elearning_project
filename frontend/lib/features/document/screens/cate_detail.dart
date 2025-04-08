import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/category_model.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/rounded_container.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TPrimaryHeaderContainer(
        child: Column(
          children: [
            // AppBar tự custom
            Container(
              height: 100,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 36, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Nội dung chính
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text(
                      "Danh mục: ${category.title}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Chủ đề liên quan:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

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
            ),
          ],
        ),
      ),
    );
  }
}
