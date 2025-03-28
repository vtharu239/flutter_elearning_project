import 'package:flutter/material.dart';

class LearningScreen extends StatelessWidget {
  final int courseId;

  const LearningScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Học khóa học'),
      ),
      body: Center(
        child: Text(
          'Đang tải nội dung khóa học $courseId...',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
