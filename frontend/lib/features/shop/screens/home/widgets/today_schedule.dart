import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/course_schedule_card_tabbed.dart';

class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420, // đủ chỗ cho tab
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final courseType = index == 0
              ? 'Reading'
              : index == 1
                  ? 'Listening'
                  : 'Từ vựng/ngữ pháp';

          final tasksMap = {
            'Hôm nay': index == 0
                ? [
                    'Làm riêng từng part bạn muốn luyện tập (bấm thời gian 1 phút/câu)',
                    'Tự chữa các câu làm sai mà không đọc giải thích',
                    'Đọc giải thích chi tiết các câu không tự chữa được'
                  ]
                : index == 1
                    ? [
                        'Làm riêng từng part bạn muốn luyện tập (bấm thời gian 1 phút/câu)',
                        'Tự chữa các câu làm sai mà không đọc script',
                        'Nghe chép chính tả bài vừa làm, tốc độ 1.1x hoặc 1.25x',
                        'Đọc transcript, giải thích hoặc xem video bài giảng nếu cần'
                      ]
                    : [
                        'Học từ vựng (flashcards mỗi ngày 20-30 từ)',
                        'Học và làm bài tập ngữ pháp (1-2 ngày học 1 chủ đề)'
                      ],
            'Theo tuần': [],
            'Chỉnh sửa': [],
          };

          return SizedBox(
            width: 320,
            child: CourseScheduleCardTabbed(
              courseName: 'Complete TOEIC 650+',
              courseType: courseType,
              frequency: 'Hàng ngày',
              tasksPerTab: tasksMap
                  .map((key, value) => MapEntry(key, value.cast<String>())),
            ),
          );
        },
      ),
    );
  }
}
