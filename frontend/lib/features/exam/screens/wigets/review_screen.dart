import 'package:flutter/material.dart';

class ReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allParts;
  final Map<String, String> answers;
  final Map<String, bool> markedForReview;

  const ReviewScreen({
    super.key,
    required this.allParts,
    required this.answers,
    required this.markedForReview,
  });

  int getQuestionNumber(int partIndex, int questionIndex) {
    int questionNumber = 0;
    // Sum the number of questions in all previous parts
    for (int i = 0; i < partIndex; i++) {
      questionNumber += (allParts[i]['questions'].length as int);
    }
    // Add the current question index (1-based)
    return questionNumber + questionIndex + 1;
  }

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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${part['title']} (${questions.length} câu)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                padding:
                    const EdgeInsets.only(right: 12.0, top: 12.0, bottom: 12.0),
                itemCount: questions.length,
                itemBuilder: (context, questionIndex) {
                  final question = questions[questionIndex];
                  final questionId = question['id'].toString();
                  final isAnswered = answers.containsKey(questionId);
                  final isMarked = markedForReview[questionId] == true;

                  // Calculate the sequential question number
                  final questionNumber =
                      getQuestionNumber(partIndex, questionIndex);

                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'partIndex': partIndex,
                        'questionIndex': questionIndex,
                      });
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
                          '$questionNumber',
                          style: TextStyle(
                              color: isAnswered || isMarked
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
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
