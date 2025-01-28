import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

// Section hiển thị lịch học hôm nay
class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lịch học hôm nay',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem Lịch học của tôi >>',
                style: TextStyle(color: Colors.blue[700]),
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

class CourseScheduleCard extends StatefulWidget {
  final String courseName;
  final String courseType;
  final String frequency;
  final List<String> tasks;

  const CourseScheduleCard({
    super.key,
    required this.courseName,
    required this.courseType,
    required this.frequency,
    required this.tasks,
  });

  @override
  _CourseScheduleCardState createState() => _CourseScheduleCardState();
}

class _CourseScheduleCardState extends State<CourseScheduleCard> {
  late List<bool> _taskCompleted;

  @override
  void initState() {
    super.initState();
    _taskCompleted = List.generate(widget.tasks.length, (index) => false);
  }

  void _toggleTask(int index) {
    setState(() {
      _taskCompleted[index] = !_taskCompleted[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Khóa học: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                widget.courseName,
                style: TextStyle(color: Colors.blue[700]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.courseType}: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(widget.frequency),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.tasks.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _toggleTask(index),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _taskCompleted[index]
                        ? Colors.green[100]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _taskCompleted[index]
                              ? Colors.green
                              : Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _taskCompleted[index]
                            ? Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.tasks[index],
                          style: TextStyle(
                            color: _taskCompleted[index]
                                ? Colors.green[800]
                                : Colors.black,
                            fontWeight: _taskCompleted[index]
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}