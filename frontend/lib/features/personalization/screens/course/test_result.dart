import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

// Section hiển thị kết quả thi mới nhất
class LatestTestResultsSection extends StatelessWidget {
  const LatestTestResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kết quả luyện thi mới nhất',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem tất cả',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(height: TSizes.sm),
          itemBuilder: (context, index) {
            return TestResultDetailCard(
              testName: 'Practice Test ${index + 1}',
              parts: ['Part 1', 'Part 2', 'Part 3'], // Ví dụ nhiều part
              date: '31/12/2024',
              duration: '0:30:00',
              score: '${30 + index}/39',
            );
          },
        ),
      ],
    );
  }
}

class TestResultDetailCard extends StatelessWidget {
  final String testName;
  final List<String> parts;
  final String date;
  final String duration;
  final String score;

  const TestResultDetailCard({
    super.key,
    required this.testName,
    required this.parts,
    required this.date,
    required this.duration,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh bên trái
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
            ),
            child: const Center(
              child: Icon(Iconsax.document, size: 30, color: Colors.blue),
            ),
          ),
          const SizedBox(width: TSizes.md),
          // Nội dung bên phải
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: TSizes.sm),
                Wrap(
                  spacing: TSizes.xs,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: TSizes.sm, vertical: TSizes.xs),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(TSizes.xs),
                      ),
                      child: Text(
                        'Luyện tập',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...parts.map((part) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm, vertical: TSizes.xs),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(TSizes.xs),
                          ),
                          child: Text(
                            part,
                            style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                  ],
                ),
                const SizedBox(height: TSizes.sm),
                Text('Ngày làm bài: $date',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: TSizes.xs),
                Text('Thời gian hoàn thành: $duration',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Text('Kết quả: ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      score,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '[Xem chi tiết]',
                        style: TextStyle(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
