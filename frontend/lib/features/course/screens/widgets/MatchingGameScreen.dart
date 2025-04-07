import 'package:flutter/material.dart';
import 'dart:async';

class MatchingGameScreen extends StatefulWidget {
  const MatchingGameScreen({super.key});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen> {
  int currentQuestionIndex = 0;
  bool autoNextQuestion = false;
  String? selectedWord;
  String? selectedDefinition;
  List<Map<String, String>> matchedPairs =
      []; // To store correctly matched pairs
  List<Map<String, String>> wrongPairs = []; // To store temporarily wrong pairs
  bool isBlinking = false; // To control the blinking effect
  bool showColor = true; // To toggle the color during blinking

  // Danh sách các cặp từ và định nghĩa
  final List<List<Map<String, String>>> questions = [
    [
      {'word': 'bicycle', 'definition': 'xe đạp'},
      {
        'word': 'mister',
        'definition': 'một cách xưng hô lịch sự với 1 người đàn ông'
      },
      {'word': 'downtown', 'definition': 'khu vực trung tâm của thành phố'},
      {'word': 'subscription', 'definition': 'sự đăng ký'},
      {'word': 'sometime', 'definition': 'một lúc nào đó'},
      {'word': 'vacation', 'definition': 'kỳ nghỉ'},
      {'word': 'goods', 'definition': 'hàng hóa, mặt hàng'},
      {'word': 'o\'clock', 'definition': 'giờ trong ngày'},
    ],
    // Thêm các câu hỏi khác nếu cần
  ];

  // Sắp xếp cố định: 4 hàng, mỗi hàng 3 thẻ
  final List<List<String>> fixedLayout = [
    [
      'xe đạp',
      'subscription',
      'sự đăng ký',
    ],
    [
      'vacation',
      'một cách xưng hô lịch sự với 1 người đàn ông',
      'o\'clock',
    ],
    [
      'khu vực trung tâm của thành phố',
      'mister',
      'một lúc nào đó',
    ],
    [
      'bicycle',
      'giờ trong ngày',
      'goods',
    ],
  ];

  void selectWord(String word) {
    setState(() {
      // If a wrong pair is highlighted, clear it when a new card is clicked
      if (wrongPairs.isNotEmpty) {
        wrongPairs.clear();
        isBlinking = false;
      }

      if (selectedWord == word) {
        selectedWord = null; // Bỏ chọn nếu nhấn lại
      } else {
        selectedWord = word;
        if (selectedDefinition != null) {
          checkMatch();
        }
      }
    });
  }

  void selectDefinition(String definition) {
    setState(() {
      // If a wrong pair is highlighted, clear it when a new card is clicked
      if (wrongPairs.isNotEmpty) {
        wrongPairs.clear();
        isBlinking = false;
      }

      if (selectedDefinition == definition) {
        selectedDefinition = null; // Bỏ chọn nếu nhấn lại
      } else {
        selectedDefinition = definition;
        if (selectedWord != null) {
          checkMatch();
        }
      }
    });
  }

  void checkMatch() {
    final currentPairs = questions[currentQuestionIndex];
    final selectedPair = currentPairs.firstWhere(
      (pair) => pair['word'] == selectedWord,
      orElse: () => {'word': '', 'definition': ''},
    );

    if (selectedPair['definition'] == selectedDefinition) {
      // Ghép đúng
      setState(() {
        matchedPairs.add({
          'word': selectedWord!,
          'definition': selectedDefinition!,
        });
        currentPairs.removeWhere((pair) => pair['word'] == selectedWord);

        // Start blinking for correct match (green)
        isBlinking = true;
        showColor = true;
        int blinkCount = 0;
        const int maxBlinks = 3; // Blink 3 times

        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (blinkCount >= maxBlinks * 2) {
            // After blinking, stop and clear selection
            setState(() {
              isBlinking = false;
              selectedWord = null;
              selectedDefinition = null;
            });
            timer.cancel();

            // Check if all pairs are matched and auto-next is enabled
            if (currentPairs.isEmpty && autoNextQuestion) {
              Timer(const Duration(seconds: 1), () {
                if (mounted) {
                  nextQuestion();
                }
              });
            }
          } else {
            setState(() {
              showColor = !showColor; // Toggle color for blinking
            });
            blinkCount++;
          }
        });
      });
    } else {
      // Ghép sai
      setState(() {
        wrongPairs.add({
          'word': selectedWord!,
          'definition': selectedDefinition!,
        });

        // Start blinking for incorrect match (red)
        isBlinking = true;
        showColor = true;
        int blinkCount = 0;
        const int maxBlinks = 1; // Blink 1 time

        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (blinkCount >= maxBlinks * 2) {
            // After blinking, stop, clear wrong pairs, and reset selection
            setState(() {
              isBlinking = false;
              wrongPairs.clear();
              selectedWord = null;
              selectedDefinition = null;
            });
            timer.cancel();
          } else {
            setState(() {
              showColor = !showColor; // Toggle color for blinking
            });
            blinkCount++;
          }
        });
      });
    }
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        selectedWord = null;
        selectedDefinition = null;
        matchedPairs.clear();
        wrongPairs.clear();
        isBlinking = false;
      } else {
        Navigator.pop(context);
      }
    });
  }

  void previousQuestion() {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        selectedWord = null;
        selectedDefinition = null;
        matchedPairs.clear();
        wrongPairs.clear();
        isBlinking = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentPairs = questions[currentQuestionIndex];
    final List<String> words =
        currentPairs.map((pair) => pair['word']!).toList();
    final List<String> definitions =
        currentPairs.map((pair) => pair['definition']!).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Tìm cặp'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns per row
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5, // Larger cards
                ),
                itemCount: 12, // 4 rows × 3 columns = 12 cards
                itemBuilder: (context, index) {
                  final row = index ~/ 3;
                  final col = index % 3;
                  final item = fixedLayout[row][col];
                  final isWord = words.contains(item);

                  // Check if the item is part of a matched pair (should disappear)
                  final isMatched = matchedPairs.any((pair) =>
                      pair['word'] == item || pair['definition'] == item);

                  // If the item is matched, don't display it (make it invisible)
                  if (isMatched && !isBlinking) {
                    return const SizedBox.shrink(); // Return an empty widget
                  }

                  // Check if the item is currently selected
                  final isSelected = (isWord && selectedWord == item) ||
                      (!isWord && selectedDefinition == item);

                  // Check if the item is part of a wrong pair
                  final isWrong = wrongPairs.any((pair) =>
                      pair['word'] == item || pair['definition'] == item);

                  // Determine the background color
                  Color backgroundColor = Colors.white;
                  if (isMatched && isBlinking) {
                    backgroundColor = showColor
                        ? Colors.green
                        : Colors.white; // Blinking green
                  } else if (isWrong && isBlinking) {
                    backgroundColor =
                        showColor ? Colors.red : Colors.white; // Blinking red
                  } else if (isSelected) {
                    backgroundColor = Colors.grey; // Selected
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isWord) {
                        selectWord(item);
                      } else {
                        selectDefinition(item);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius:
                            BorderRadius.circular(0), // Square corners
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: isWord ? Colors.orange : Colors.black,
                              fontWeight:
                                  isWord ? FontWeight.bold : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
              children: List.generate(20, (index) {
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
