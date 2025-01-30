import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

// Section hiển thị khóa học của tôi
class MyCourseSection extends StatelessWidget {
  const MyCourseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2, // 2 cột, mỗi cột 2 card
            separatorBuilder: (context, index) =>
                const SizedBox(width: TSizes.defaultSpace),
            itemBuilder: (context, columnIndex) {
              return SizedBox(
                width: 350,
                child: Column(
                  children: [
                    EnrolledCourseCard(
                      courseName: 'Course ${columnIndex * 2 + 1}',
                      progress: 0.07,
                      nextLesson: 'Lesson ${columnIndex * 2 + 1}',
                      status: 'Đã kích hoạt',
                    ),
                    const SizedBox(height: TSizes.sm),
                    EnrolledCourseCard(
                      courseName: 'Course ${columnIndex * 2 + 2}',
                      progress: 0,
                      nextLesson: 'Lesson ${columnIndex * 2 + 2}',
                      status: 'Học thử',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class EnrolledCourseCard extends StatelessWidget {
  final String courseName;
  final double progress;
  final String nextLesson;
  final String status;

  const EnrolledCourseCard({
    super.key,
    required this.courseName,
    required this.progress,
    required this.nextLesson,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra chế độ sáng tối
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusMd),
        border: Border.all(
            color: isDarkMode
                ? Colors.grey[700]!
                : Colors.grey.shade200), // Màu viền thay đổi theo chế độ
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  courseName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TSizes.sm,
                  vertical: TSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: status == 'Đã kích hoạt'
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(TSizes.xs),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Đã kích hoạt'
                        ? Colors.green[700]
                        : Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.sm),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          const SizedBox(height: TSizes.xs),
          Text(
            '${(progress * 100).toInt()}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            'Tiếp tục bài học: $nextLesson',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
          ),
        ],
      ),
    );
  }
}
