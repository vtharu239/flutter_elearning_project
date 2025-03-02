import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
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
    return Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.tests.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: TSizes.spaceBtwItems),
          itemBuilder: (context, index) {
            final test = controller.tests[index];
            return TestCard(
              controller: controller,
              testId: test['id']?.toString() ?? 'unknown',
              testData: test,
            );
          },
        ));
  }
}

class TestCard extends StatelessWidget {
  final PracticeTestController controller;
  final String testId;
  final dynamic testData;

  const TestCard({
    super.key,
    required this.controller,
    required this.testId,
    required this.testData,
  });

  // Hàm helper để lấy màu icon dựa trên độ khó
  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey; // Màu mặc định nếu không khớp
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestDetailScreen(testId: testId),
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
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
              child: testData['imageUrl'] != null
                  ? Image.network(
                      ApiConstants.getUrl(testData['imageUrl']),
                      fit: BoxFit.cover,
                      headers:
                          ApiConstants.getHeaders(isImage: true), // Thêm header
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Iconsax.document,
                        size: 30,
                        color: Colors.blue,
                      ),
                    )
                  : const Icon(Iconsax.document, size: 30, color: Colors.blue),
            ),
            const SizedBox(width: TSizes.spaceBtwItems),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testData['title'],
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
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          testData['Category']['name'],
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                      Text(
                        '${testData['parts']} phần • ${testData['duration']} phút',
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
                            '${testData['testCount'] ?? 0} lượt thi',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.level,
                            size: 16,
                            color: getDifficultyColor(testData[
                                'difficulty']), // Áp dụng màu dựa trên độ khó
                          ),
                          const SizedBox(width: TSizes.xs),
                          Text(
                            testData['difficulty'],
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
                            '${testData['commentCount'] ?? 0}',
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
                        builder: (context) => TestDetailScreen(testId: testId),
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
