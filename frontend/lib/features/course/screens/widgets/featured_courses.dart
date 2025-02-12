import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';

// Section hiển thị kết quả thi mới nhất
class FeaturedCoursesSection extends StatelessWidget {
  const FeaturedCoursesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 320,
      child: HorizontalCourseCardList(
        itemCount: 3,
        items: [
          HorizontalCourseCard(
            title: 'Complete TOEIC 2024',
            rating: 4.8,
            ratingCount: 2345,
            students: 1234,
            originalPrice: 1289000,
            discountPrice: 989000,
            discountPercentage: 25,
            imageUrl:
                darkMode ? TImages.productImage1Dark : TImages.productImage1,
            onTap: () {},
          ),
          HorizontalCourseCard(
            title: 'Complete TOEIC 2024',
            rating: 4.8,
            ratingCount: 2345,
            students: 1234,
            originalPrice: 1289000,
            discountPrice: 989000,
            discountPercentage: 25,
            imageUrl:
                darkMode ? TImages.productImage1Dark : TImages.productImage1,
            onTap: () {},
          ),
          HorizontalCourseCard(
            title: 'Complete TOEIC 2024',
            rating: 4.8,
            ratingCount: 2345,
            students: 1234,
            originalPrice: 1289000,
            discountPrice: 989000,
            discountPercentage: 25,
            imageUrl:
                darkMode ? TImages.productImage1Dark : TImages.productImage1,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
