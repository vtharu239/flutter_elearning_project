import 'package:flutter/material.dart';

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
  CourseScheduleCardState createState() => CourseScheduleCardState();
}

class CourseScheduleCardState extends State<CourseScheduleCard> {
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
    // Kiểm tra chế độ sáng/tối
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade200), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Khóa học: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black, 
                ),
              ),
              Text(
                widget.courseName,
                style: TextStyle(color: isDarkMode ? Colors.blue[300] : Colors.blue[700]), 
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${widget.courseType}: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black, 
                ),
              ),
              Text(
                widget.frequency,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.tasks.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _toggleTask(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _taskCompleted[index]
                        ? (isDarkMode ? Colors.green[700] : Colors.green[100]) // Màu nền khi task hoàn thành
                        : (isDarkMode ? Colors.grey[800] : Colors.white), // Màu nền khi task chưa hoàn thành
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
                              : (isDarkMode ? Colors.grey[700]! : Colors.white),
                          border: Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: _taskCompleted[index]
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.tasks[index],
                          style: TextStyle(
                            color: _taskCompleted[index]
                                ? (isDarkMode ? Colors.green[200] : Colors.green[800]) // Màu chữ khi task hoàn thành
                                : (isDarkMode ? Colors.white : Colors.black), // Màu chữ khi task chưa hoàn thành
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
