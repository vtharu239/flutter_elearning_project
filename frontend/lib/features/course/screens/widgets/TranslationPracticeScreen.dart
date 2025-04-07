import 'package:flutter/material.dart';

class TranslationPracticeScreen extends StatefulWidget {
  const TranslationPracticeScreen({super.key});

  @override
  State<TranslationPracticeScreen> createState() =>
      _TranslationPracticeScreenState();
}

class _TranslationPracticeScreenState extends State<TranslationPracticeScreen> {
  final TextEditingController _answerController = TextEditingController();
  int currentQuestionIndex = 0;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  String? selectedAnswer;
  bool showCorrectAnswer = false;
  bool autoNextQuestion = false;
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'It takes several days for a _____ to clear airport customs.',
      'hint': 'delivery of goods, e.g. carried by a large vehicle',
      'answer': 'shipment',
      'translation': 'sự giao hàng'
    },
    // Add more questions here
  ];

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    setState(() {
      _isAnswerChecked = true;
      _isCorrect = _answerController.text.trim().toLowerCase() ==
          _questions[currentQuestionIndex]['answer'].toLowerCase();
    });
  }

  void _resetCheck() {
    setState(() {
      _isAnswerChecked = false;
      _isCorrect = false;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < _questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _answerController.clear();
        _isAnswerChecked = false;
      });
    }
  }

  void previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        _answerController.clear();
        _isAnswerChecked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch nghĩa / Diễn từ'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                _questions[currentQuestionIndex]['question'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[700]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.yellow[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hint: ${_questions[currentQuestionIndex]['hint']}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Answer field with conditional border color and no underline
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isAnswerChecked
                      ? (_isCorrect ? Colors.green : Colors.red)
                      : Colors.black,
                  width: _isAnswerChecked ? 2.0 : 1.0,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              height: 60,
              child: TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Nhập câu trả lời của bạn',
                ),
                cursorColor: Colors.grey[700],
                style: TextStyle(
                  fontSize: 16,
                  color: _isAnswerChecked && _isCorrect
                      ? Colors.green
                      : Colors.black,
                ),
                onChanged: (_) {
                  // Reset the check state when user types something new
                  if (_isAnswerChecked) {
                    _resetCheck();
                  }
                },
              ),
            ),

            // Show correct answer if answer is checked and wrong
            if (_isAnswerChecked && !_isCorrect)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    _questions[currentQuestionIndex]['answer'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Translation field - shows when answer is checked and incorrect
            if (_isAnswerChecked && !_isCorrect)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _questions[currentQuestionIndex]['translation'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),

            const SizedBox(height: 16),

            // Check Answer button - always enabled
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 53, 133, 223),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Kiểm tra đáp án',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: currentQuestionIndex > 0 ? previousQuestion : null,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue[300],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            // Question navigation
            const SizedBox(height: 32),
            const Text(
              'Danh sách bài tập:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(55, (index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      currentQuestionIndex = index;
                      _answerController.clear();
                      _isAnswerChecked = false;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: currentQuestionIndex == index
                          ? Colors.blue[800]
                          : Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: currentQuestionIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
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
