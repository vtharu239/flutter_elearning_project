import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/part_answer_transcript_screen.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_answer_transcript_screen.dart';
import './discussion_section.dart';

class AnswerTranscriptTab extends StatelessWidget {
  final Map<String, dynamic> test;
  final Future<void> Function(String) onAddComment;

  const AnswerTranscriptTab({
    super.key,
    required this.test,
    required this.onAddComment,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestAnswerTranscriptScreen(
                      test: test,
                    ),
                  ),
                );
              },
              child: const Text(
                'Xem đáp án đề thi',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28.0, bottom: 8.0),
            child: const Text(
              'Các phần thi:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: test['Parts'].asMap().entries.map<Widget>((entry) {
              final index = entry.key; // Chỉ số bắt đầu từ 0
              final part = entry.value;
              final partNumber = index + 1; // Số thứ tự bắt đầu từ 1
              return Padding(
                padding: const EdgeInsets.only(left: 48.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      'Part $partNumber: ', // Hiển thị số thứ tự từ 1
                      style: const TextStyle(fontSize: 18),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartAnswerTranscriptScreen(
                              part: part,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Đáp án',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Divider(),
          DiscussionSection(
            comments: test['Comments'],
            onAddComment: onAddComment,
          ),
        ],
      ),
    );
  }
}
