import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/category_card.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class PopularCategoriesGrid extends StatelessWidget {
  final CourseController controller;

  const PopularCategoriesGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: TSizes.gridViewSpacing,
        crossAxisSpacing: TSizes.gridViewSpacing,
        mainAxisExtent: 100,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return CategoryCard(
          title: 'TOEIC',
          icon: Iconsax.book,
          color: Colors.blue,
          courseCount: 42,
          onTap: () {},
        );
      },
    );
  }
}