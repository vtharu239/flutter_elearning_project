import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/shadows.dart';
import 'package:flutter_elearning_project/common/widgets/texts/price_format.dart';
import 'package:flutter_elearning_project/common/widgets/texts/rating_star.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/CourseDetailScreen.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

/// Widget hiển thị danh sách khóa học
class VerticalCourseCardList extends StatelessWidget {
  final int itemCount;
  final List<VerticalCourseCard> items;

  const VerticalCourseCardList({
    super.key,
    required this.itemCount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.xs),
      itemBuilder: (context, index) {
        return items[
            index]; // Trả về từng VerticalCourseCardList đã được truyền vào
      },
    );
  }
}

class VerticalCourseCard extends StatelessWidget {
  final int courseId; // Thêm courseId
  final String title;
  final double rating;
  final int ratingCount;
  final int students;
  final double originalPrice;
  final int? discountPercentage;
  final String imageUrl;

  const VerticalCourseCard({
    super.key,
    required this.courseId, // Thêm vào constructor
    required this.title,
    required this.rating,
    required this.ratingCount,
    required this.students,
    required this.originalPrice,
    required this.discountPercentage,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CourseDetailScreen(courseId: courseId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(TSizes.xs),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          boxShadow: isDarkMode ? [] : [TShadowStyle.verticalProductShadow],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              child: Image.asset(
                imageUrl,
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.width * 0.25,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 280) {
                        return Row(
                          mainAxisSize: MainAxisSize
                              .min, // Make row take minimum required space
                          children: [
                            RatingStars(
                                rating: rating, ratingCount: ratingCount),
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
                                    overflow: TextOverflow
                                        .ellipsis, // Truncate text if needed
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
                            RatingStars(
                                rating: rating, ratingCount: ratingCount),
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
                  CoursePrice(
                    originalPrice: originalPrice,
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
