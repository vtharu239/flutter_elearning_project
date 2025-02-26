import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/shadows.dart';
import 'package:flutter_elearning_project/common/widgets/texts/price_format.dart';
import 'package:flutter_elearning_project/common/widgets/texts/rating_star.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

/// Widget hiển thị danh sách khóa học theo chiều ngang
class HorizontalCourseCardList extends StatelessWidget {
  final int itemCount;
  final List<HorizontalCourseCard> items;

  const HorizontalCourseCardList({
    super.key,
    required this.itemCount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(width: TSizes.sm),
      itemBuilder: (context, index) {
        return items[
            index]; // Trả về từng HorizontalCourseCard đã được truyền vào
      },
    );
  }
}

class HorizontalCourseCard extends StatelessWidget {
  final String title;
  final double rating;
  final int ratingCount;
  final int students;
  final double originalPrice;
  final double? discountPrice;
  final int? discountPercentage;
  final String imageUrl;
  final VoidCallback onTap;

  const HorizontalCourseCard({
    super.key,
    required this.title,
    required this.rating,
    required this.ratingCount,
    required this.students,
    required this.originalPrice,
    this.discountPrice,
    this.discountPercentage,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra dark mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 310,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          boxShadow: isDarkMode
              ? []
              : [TShadowStyle.verticalProductShadow], // Bỏ shadow nếu dark mode
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(TSizes.cardRadiusLg),
              ),
              child: Image.asset(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(TSizes.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
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
                  Row(
                    children: [
                      RatingStars(rating: rating, ratingCount: ratingCount),
                    ],
                  ),
                  const SizedBox(height: TSizes.sm),

                  // Students Count
                  Row(
                    children: [
                      Icon(
                        Iconsax.user,
                        size: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: TSizes.xs),
                      Text(
                        '$students học viên',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.black,
                        ),
                      ),
                    ],
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
      ),
    );
  }
}
