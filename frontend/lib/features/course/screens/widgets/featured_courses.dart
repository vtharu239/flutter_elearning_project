import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class FeaturedCoursesSection extends StatelessWidget {
  final CourseController controller;

  const FeaturedCoursesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
            child: CourseCard(
              title: 'Complete TOEIC 2024',
              rating: 4.8,
              ratingCount: 2345,
              students: 1234,
              originalPrice: 1289000,
              discountPrice: 989000,
              discountPercentage: 25,
              imageUrl: TImages.productImage1,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
