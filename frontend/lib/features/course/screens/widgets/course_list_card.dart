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
  final bool isLoadingStudentCount;

  const VerticalCourseCardList({
    super.key,
    required this.itemCount,
    required this.items,
    required this.isLoadingStudentCount,
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
  final bool isLoadingStudentCount;
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
    required this.isLoadingStudentCount,
  });
  factory VerticalCourseCard.fromJson(Map<String, dynamic> json) {
    return VerticalCourseCard(
      courseId: json['courseId'] ?? 0, // Giá trị mặc định nếu không có
      title: json['title'] ?? 'Không có tiêu đề',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      students: json['students'] ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: json['discountPercentage'],
      imageUrl: json['imageUrl'] ?? '', // Fallback nếu null
      isLoadingStudentCount: json['isLoadingStudentCount'] ?? false,
    );
  }
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
// Calculate the discounted price
    final double? discountPrice = discountPercentage != null
        ? originalPrice * (1 - (discountPercentage! / 100))
        : null;
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
              print("VerticalCourseCard - Image URL: '$imageUrl'");
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
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      imageUrl,
                      width: 80,
                      height: 80,
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
                                  isLoadingStudentCount
                                      ? 'Đang tải...'
                                      : '$students Học viên',
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
                                  isLoadingStudentCount
                                      ? 'Đang tải...'
                                      : '$students Học viên',
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
                    discountPrice:
                        discountPrice, // Pass the calculated discountPrice
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
