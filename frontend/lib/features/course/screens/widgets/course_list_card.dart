import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/shadows.dart';
import 'package:flutter_elearning_project/common/widgets/texts/price_format.dart';
import 'package:flutter_elearning_project/common/widgets/texts/rating_star.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class CourseListCard extends StatelessWidget {
  final String title;
  final double rating;
  final int ratingCount;
  final int students;
  final double originalPrice;
  final double? discountPrice;
  final int? discountPercentage;
  final String imageUrl;

  const CourseListCard({
    super.key,
    required this.title,
    required this.rating,
    required this.ratingCount,
    required this.students,
    required this.originalPrice,
    this.discountPrice,
    this.discountPercentage,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra dark mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TSizes.sm),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        boxShadow: isDarkMode
            ? []
            : [
                TShadowStyle.verticalProductShadow
              ], // Tắt shadow trong dark mode
      ),
      child: Row(
        children: [
          // Course Image
          ClipRRect(
            borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            child: Image.asset(
              imageUrl,
              width: MediaQuery.of(context).size.width * 0.25, // 25% màn hình
              height: MediaQuery.of(context).size.width * 0.25,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: TSizes.spaceBtwItems),

          // Course Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: TSizes.sm),

                // Rating and Students
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 260) {
                      return Row(
                        children: [
                          RatingStars(rating: rating, ratingCount: ratingCount),
                          const SizedBox(width: TSizes.xs),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.user,
                                  size: 16,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                              const SizedBox(width: TSizes.xs),
                              Text(
                                '$students học viên',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Wrap(
                        spacing: TSizes.sm,
                        runSpacing: TSizes.xs,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          RatingStars(rating: rating, ratingCount: ratingCount),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.user,
                                  size: 16,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                              const SizedBox(width: TSizes.xs),
                              Text(
                                '$students học viên',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: TSizes.sm),

                // Price
                CoursePrice(
                  originalPrice: originalPrice,
                  discountPrice: discountPrice,
                  discountPercentage: discountPercentage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
