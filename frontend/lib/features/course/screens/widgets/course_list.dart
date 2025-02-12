import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_list_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';

// Section hiển thị danh sách khóa học
class CourseListSection extends StatelessWidget {
  const CourseListSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalCourseCardList(
          itemCount: 3,
          items: [
            VerticalCourseCard(
              title: 'Complete IELTS Course 2024',
              rating: 4.7,
              ratingCount: 1234,
              students: 2156,
              originalPrice: 1289000,
              discountPrice: 989000,
              discountPercentage: 25,
              imageUrl:
                  darkMode ? TImages.productImage1Dark : TImages.productImage1,
            ),
            VerticalCourseCard(
              title: 'Complete IELTS Course 2024',
              rating: 4.7,
              ratingCount: 1234,
              students: 2156,
              originalPrice: 1289000,
              discountPrice: 989000,
              discountPercentage: 25,
              imageUrl:
                  darkMode ? TImages.productImage1Dark : TImages.productImage1,
            ),
            VerticalCourseCard(
              title: 'Complete IELTS Course 2024',
              rating: 4.7,
              ratingCount: 1234,
              students: 2156,
              originalPrice: 1289000,
              discountPrice: 989000,
              discountPercentage: 25,
              imageUrl:
                  darkMode ? TImages.productImage1Dark : TImages.productImage1,
            ),
          ],
        ),
      ],
    );
  }
}
