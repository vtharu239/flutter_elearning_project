import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/course_list_card.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class CourseListSection extends StatelessWidget {
  final CourseController controller;
  final String type;

  const CourseListSection({
    super.key,
    required this.controller,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return CourseListCard(
          title: 'Complete IELTS Course 2024',
          rating: 4.7,
          ratingCount: 1234,
          students: 2156,
          originalPrice: 1289000,
          discountPrice: 989000,
          discountPercentage: 25,
          imageUrl: darkMode? TImages.productImage1Dark : TImages.productImage1,
        );
      },
    );
  }
}
