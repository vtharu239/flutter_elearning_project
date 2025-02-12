import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_card.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class PopularTestsSection extends StatelessWidget {
  final PracticeTestController controller;

  const PopularTestsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return TestCard(
          controller: controller,
          testId: 'test_$index',
        );
      },
    );
  }
}