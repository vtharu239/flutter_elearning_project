import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/controller/practice_test_controller.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_detail_screen.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:iconsax/iconsax.dart';

class TestListSection extends StatelessWidget {
  final PracticeTestController controller;

  const TestListSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return TestCard(controller: controller, testId: 'test_$index');
      },
    );
  }
}

class TestCard extends StatelessWidget {
  final PracticeTestController controller;
  final String testId;

  const TestCard({
    super.key,
    required this.controller,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestDetailScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: darkMode ? TColors.darkerGrey : Colors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.25,
              height: MediaQuery.of(context).size.width * 0.25,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: Icon(Iconsax.document, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đề thi TOEIC ETS 2024 - Test 01',
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: TSizes.xs),
                  Wrap(
                    spacing: TSizes.sm,
                    runSpacing: TSizes.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'TOEIC',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ),
                      Text(
                        '2 phần • 120 phút',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.xs),
                  Wrap(
                    spacing: TSizes.sm,
                    runSpacing: TSizes.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.user, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: TSizes.xs),
                          Text(
                            '1.2k lượt thi',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.level,
                              size: 16, color: Colors.amber[600]),
                          const SizedBox(width: TSizes.xs),
                          Text(
                            'Trung bình',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.message,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: TSizes.xs),
                          Text(
                            '24',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Obx(() => IconButton(
                      onPressed: () => controller.toggleBookmark(testId),
                      icon: Icon(
                        controller.isBookmarked(testId)
                            ? Iconsax.bookmark_2
                            : Iconsax.bookmark,
                        color: controller.isBookmarked(testId)
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    )),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestDetailScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Iconsax.arrow_right_3, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
