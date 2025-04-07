import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/detailed_answer_screen.dart';
import 'package:get/get.dart';

class AnswersSection extends StatelessWidget {
  final List<dynamic> parts;
  final List<dynamic> questions;
  final Map<String, dynamic> answers;
  final String testTitle;
  final Map<int, int> questionNumberMap;
  final void Function(Map<String, dynamic>, int) onShowQuestionDetail;
  final String attemptId;
  final String testId;
  final bool isFullTest;
  final Map<String, dynamic> resultData;

  const AnswersSection({
    super.key,
    required this.parts,
    required this.questions,
    required this.answers,
    required this.testTitle,
    required this.questionNumberMap,
    required this.onShowQuestionDetail,
    required this.attemptId,
    required this.testId,
    required this.isFullTest,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Đáp án:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                showDetailedAnswerScreen(
                  attemptId: attemptId,
                  testId: testId,
                  isFullTest: isFullTest,
                  resultData: resultData,
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xem chi tiết đáp án',
                  style: TextStyle(color: Colors.blue)),
            ),
            const SizedBox(width: 2),
            OutlinedButton(
              onPressed: () {
                Get.snackbar('Thông báo',
                    'Chuyển đến trang làm lại các câu sai (chưa triển khai)');
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Làm lại các câu sai',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        const Text(
          'Chú ý: Khi làm lại các câu sai, điểm trung bình của bạn sẽ không bị ảnh hưởng.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...parts.map((part) {
          final partQuestions = questions
              .where((q) => (part['Questions'] as List<dynamic>)
                  .any((pq) => pq['id'] == q['id']))
              .toList();

          return Card(
            color: Colors.white,
            elevation: 2,
            shadowColor: Colors.blue,
            child: ExpansionTile(
              title: Text(
                '${part['title']} (${partQuestions.length} câu)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: partQuestions.asMap().entries.map((entry) {
                final question = entry.value;
                final questionId = question['id'];
                final questionNumber =
                    questionNumberMap[questionId] ?? (entry.key + 1);
                final userAnswer = answers[question['id'].toString()];
                final correctAnswer =
                    question['correctAnswer']?.toString() ?? 'Không có đáp án';
                final isCorrect = userAnswer == correctAnswer;
                final isUnanswered = userAnswer == null;
                final displayUserAnswer = userAnswer ?? 'Chưa trả lời';

                Color overallColor;
                String suffix = '';

                if (isUnanswered) {
                  overallColor = Colors.orange;
                } else if (isCorrect) {
                  overallColor = Colors.green;
                  suffix = ' ✓';
                } else {
                  overallColor = Colors.red;
                  suffix = ' ✗';
                }

                return ListTile(
                  leading: Text(
                    '$questionNumber',
                    style: TextStyle(fontSize: 16, color: Colors.blue[700]),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: overallColor),
                      children: [
                        TextSpan(
                          text: '$correctAnswer : ',
                        ),
                        TextSpan(
                          text: displayUserAnswer,
                          style: TextStyle(
                            decoration: (!isCorrect && !isUnanswered)
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationThickness:
                                (!isCorrect && !isUnanswered) ? 2 : null,
                          ),
                        ),
                        if (!isUnanswered)
                          TextSpan(
                            text: suffix,
                          ),
                      ],
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () =>
                        onShowQuestionDetail(question, questionNumber),
                    child: const Text('[Chi tiết]',
                        style: TextStyle(color: Colors.blue)),
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }
}
