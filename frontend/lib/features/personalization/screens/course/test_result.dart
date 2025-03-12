import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

// Section hiển thị kết quả thi mới nhất
class LatestTestResultsSection extends StatelessWidget {
  const LatestTestResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TestResultsList(
          itemCount: 3,
          items: [
            TestResultDetailCard(
              testName: 'Practice Test 1',
              parts: ['Part 1', 'Part 2'],
              date: '31/12/2024',
              duration: '0:30:00',
              score: '30/39',
              imageUrl: TImages.toeicTest, // Có ảnh
            ),
            // TestResultDetailCard(
            //   testName: 'Practice Test 2',
            //   parts: ['Part 1', 'Part 3'],
            //   date: '01/01/2025',
            //   duration: '0:45:00',
            //   score: '35/39',
            // ),
            TestResultDetailCard(
              testName: 'Practice Test 3',
              parts: ['Part 1', 'Part 2', 'Part 3'],
              date: '02/01/2025',
              duration: '1:00:00',
              score: '28/39',
            ),
            TestResultDetailCard(
              testName: 'Practice Test 3',
              parts: ['Part 2', 'Part 3'],
              date: '02/01/2025',
              duration: '1:00:00',
              score: '28/39',
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget hiển thị danh sách kết quả luyện thi
class TestResultsList extends StatelessWidget {
  final int itemCount;
  final List<TestResultDetailCard> items;

  const TestResultsList({
    super.key,
    required this.itemCount,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.md),
      itemBuilder: (context, index) {
        return items[
            index]; // Trả về từng TestResultDetailCard đã được truyền vào
      },
    );
  }
}

class TestResultDetailCard extends StatelessWidget {
  final String testName;
  final List<String> parts;
  final String date;
  final String duration;
  final String score;
  final String? imageUrl;

  const TestResultDetailCard({
    super.key,
    required this.testName,
    required this.parts,
    required this.date,
    required this.duration,
    required this.score,
    this.imageUrl, // Tham số ảnh không bắt buộc
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kiểm tra nếu có ảnh thì hiển thị, nếu không thì bỏ qua
          if (imageUrl != null) ...[
            Container(
              width: MediaQuery.of(context).size.width * 0.2, // 20% màn hình
              height: MediaQuery.of(context).size.width * 0.2, // 20% màn hình
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/content/toeic_test.png'), // Hiển thị ảnh từ URL
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
              ),
            ),
            const SizedBox(width: TSizes.md),
          ],
          // Nội dung bên phải
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  testName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
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
                Text(
                  'Ngày làm bài: $date',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  'Thời gian hoàn thành: $duration',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                ),
                const SizedBox(height: TSizes.xs),
                Wrap(
                  spacing: TSizes.sm,
                  runSpacing: TSizes.xs, // Tự động xuống dòng nếu không đủ chỗ
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Kết quả: ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                    ),
                    Text(
                      score,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '[Xem chi tiết]',
                        style: TextStyle(
                          color:
                              isDarkMode ? Colors.blue[300] : Colors.blue[700],
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
