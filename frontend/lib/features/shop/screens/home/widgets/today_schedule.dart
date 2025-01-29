import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/course_schedule_card.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

// Section hiển thị lịch học hôm nay
class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch học hôm nay',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: darkMode ? Colors.white : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem Lịch học của tôi',
                style: TextStyle(color: darkMode? TColors.darkGrey : Colors.blue[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) =>
                const SizedBox(width: TSizes.defaultSpace),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 300,
                child: CourseScheduleCard(
                  courseName: 'Complete TOEIC 650+',
                  courseType: index == 0
                      ? 'Reading'
                      : index == 1
                          ? 'Listening'
                          : 'Từ vựng/ngữ pháp',
                  frequency: 'Hàng ngày',
                  tasks: [
                    'Task ${index + 1}.1',
                    'Task ${index + 1}.2',
                    'Task ${index + 1}.3',
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
