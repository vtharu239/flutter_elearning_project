import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allParts; // Đổi tên thành testParts
  final Map<String, String> answers;
  final Map<String, bool> markedForReview;

  const ReviewScreen({
    super.key,
    required this.allParts,
    required this.answers,
    required this.markedForReview,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review câu hỏi'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: allParts.length,
        itemBuilder: (context, partIndex) {
          final part = allParts[partIndex];
          final questions = List<Map<String, dynamic>>.from(part['questions']);
          return ExpansionTile(
            title: Text('${part['title']} (${questions.length} câu)'),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding: const EdgeInsets.all(16.0),
                itemCount: questions.length,
                itemBuilder: (context, questionIndex) {
                  final question = questions[questionIndex];
                  final questionId = question['id'].toString();
                  final isAnswered = answers.containsKey(questionId);
                  final isMarked = markedForReview[questionId] == true;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMarked
                            ? Colors.orange
                            : (isAnswered ? Colors.blue : Colors.white),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${questionIndex + 1}',
                          style: TextStyle(
                            color: isAnswered || isMarked ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}