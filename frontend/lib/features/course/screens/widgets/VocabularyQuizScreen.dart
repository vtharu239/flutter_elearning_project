import 'package:flutter/material.dart';
import 'dart:async';

class VocabularyQuizScreen extends StatefulWidget {
  const VocabularyQuizScreen({super.key});

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showCorrectAnswer = false;
  bool autoNextQuestion = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question':
          'If you see anything suspicious you should ___ the police immediately.',
      'hint': 'Hint: officially tell someone some information',
      'options': ['downtown', 'notify', 'website', 'chef'],
      'correctAnswer': 'notify',
    },
    {
      'question': 'She works as a ___ in a famous restaurant.',
      'hint': 'Hint: someone who cooks food professionally',
      'options': ['teacher', 'chef', 'driver', 'doctor'],
      'correctAnswer': 'chef',
    },
  ];

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      showCorrectAnswer = true;

      if (answer == questions[currentQuestionIndex]['correctAnswer'] &&
          autoNextQuestion) {
        Timer(const Duration(seconds: 1), () {
          if (mounted) {
            nextQuestion();
          }
        });
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedAnswer = null;
        showCorrectAnswer = false;
      } else {
        Navigator.pop(context);
      }
    });
  }

  void previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedAnswer = null;
        showCorrectAnswer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Trắc nghiệm từ vựng'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              currentQuestion['hint'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...currentQuestion['options'].map<Widget>((option) {
              bool isCorrect = option == currentQuestion['correctAnswer'];
              bool isSelected = option == selectedAnswer;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: GestureDetector(
                  onTap: showCorrectAnswer
                      ? null
                      : () {
                          checkAnswer(option);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: showCorrectAnswer
                          ? (isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : (isSelected
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.white))
                          : Colors.white,
                      border: Border.all(
                        color: showCorrectAnswer
                            ? (isCorrect
                                ? Colors.green
                                : (isSelected ? Colors.red : Colors.grey))
                            : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: showCorrectAnswer
                            ? (isCorrect
                                ? Colors.green
                                : (isSelected ? Colors.red : Colors.black))
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            const Spacer(),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: autoNextQuestion,
                      onChanged: (value) {
                        setState(() {
                          autoNextQuestion = value;
                        });
                      },
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tự động chuyển câu',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed:
                          currentQuestionIndex > 0 ? previousQuestion : null,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[300],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_left, size: 20),
                          SizedBox(width: 4),
                          Text(
                            'Câu trước',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: nextQuestion,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[300],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Câu sau',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_right, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Danh sách bài tập:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(55, (index) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: index == currentQuestionIndex
                        ? Colors.blue
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: index == currentQuestionIndex
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
