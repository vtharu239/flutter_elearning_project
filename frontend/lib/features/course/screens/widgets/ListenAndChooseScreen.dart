import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math'; // For random word selection (simulating audio)

class ListenAndChooseScreen extends StatefulWidget {
  const ListenAndChooseScreen({super.key});

  @override
  State<ListenAndChooseScreen> createState() => _ListenAndChooseScreenState();
}

class _ListenAndChooseScreenState extends State<ListenAndChooseScreen> {
  int currentQuestionIndex = 0;
  bool autoNextQuestion = false;
  String? selectedWord;
  String? currentAudioWord; // The word "spoken" in the audio
  List<String> matchedWords = []; // To store correctly matched words
  List<String> wrongWords = []; // To store temporarily wrong words
  bool isBlinking = false; // To control the blinking effect
  bool showColor = true; // To toggle the color during blinking

  // Danh sách các từ và định nghĩa (dựa trên hình ảnh mới)
  final List<List<Map<String, String>>> questions = [
    [
      {'word': 'e-book', 'definition': 'sách điện tử'},
      {'word': 'warranty', 'definition': 'sự bảo hành'},
      {'word': 'subscription', 'definition': 'sự đăng ký'},
      {'word': 'website', 'definition': 'trang web'},
      {'word': 'refund', 'definition': 'hoàn tiền'},
      {'word': 'preview', 'definition': 'sự xem trước, sự duyệt trước'},
      {'word': 'workshop', 'definition': 'phân xưởng'},
      {'word': 'fare', 'definition': 'tiền xe, tiền vé'},
      {'word': 'candidate', 'definition': 'ứng cử viên'},
    ],
  ];

  // Sắp xếp cố định theo hình ảnh mới: 3 hàng, mỗi hàng 3 thẻ (3×3 grid)
  final List<List<String>> fixedLayout = [
    ['e-book', 'warranty', 'subscription'],
    ['website', 'refund', 'preview'],
    ['workshop', 'fare', 'candidate'],
  ];

  @override
  void initState() {
    super.initState();
    // Simulate playing the audio when the screen loads
    playAudio();
  }

  void playAudio() {
    // Simulate selecting a random word from the current question's words
    final currentWords =
        questions[currentQuestionIndex].map((pair) => pair['word']!).toList();
    final remainingWords = currentWords
        .where((word) => !matchedWords.contains(word))
        .toList(); // Only select from unmatched words
    if (remainingWords.isNotEmpty) {
      setState(() {
        currentAudioWord =
            remainingWords[Random().nextInt(remainingWords.length)];
      });
      print('Playing audio for word: $currentAudioWord'); // For debugging
    }
  }

  void selectWord(String word) {
    setState(() {
      if (wrongWords.isNotEmpty) {
        wrongWords.clear();
        isBlinking = false;
      }
      selectedWord = word;
      checkMatch();
    });
  }

  void checkMatch() {
    if (currentAudioWord == null) {
      setState(() {
        selectedWord = null;
      });
      return;
    }

    if (selectedWord == currentAudioWord) {
      setState(() {
        matchedWords.add(selectedWord!);
        isBlinking = true;
        showColor = true;
        int blinkCount = 0;
        const int maxBlinks = 3;

        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (blinkCount >= maxBlinks * 2) {
            setState(() {
              isBlinking = false;
              selectedWord = null;
            });
            timer.cancel();

            final currentWords = questions[currentQuestionIndex]
                .map((pair) => pair['word']!)
                .toList();
            final remainingWords = fixedLayout
                .expand((row) => row)
                .where((item) => currentWords.contains(item))
                .toList();
            if (remainingWords.every((word) => matchedWords.contains(word)) &&
                autoNextQuestion) {
              Timer(const Duration(seconds: 1), () {
                if (mounted) {
                  nextQuestion();
                }
              });
            } else {
              // Play the next unmatched word if auto-next is not enabled
              playAudio();
            }
          } else {
            setState(() {
              showColor = !showColor;
            });
            blinkCount++;
          }
        });
      });
    } else {
      setState(() {
        wrongWords.add(selectedWord!);
        isBlinking = true;
        showColor = true;
        int blinkCount = 0;
        const int maxBlinks = 1;

        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (blinkCount >= maxBlinks * 2) {
            setState(() {
              isBlinking = false;
              wrongWords.clear();
              selectedWord = null;
            });
            timer.cancel();
          } else {
            setState(() {
              showColor = !showColor;
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
        currentAudioWord = null;
        matchedWords.clear();
        wrongWords.clear();
        isBlinking = false;
        playAudio();
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
        currentAudioWord = null;
        matchedWords.clear();
        wrongWords.clear();
        isBlinking = false;
        playAudio();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentWords =
        questions[currentQuestionIndex].map((pair) => pair['word']!).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Nghe và chọn từ'),
        backgroundColor: Colors.blue[800],
        actions: [],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check for constraints errors (e.g., screen too narrow)
          String? constraintsError;
          if (constraints.maxWidth < 300) {
            constraintsError =
                'Screen width must be at least 300 pixels to display this layout properly.';
          }

          if (constraintsError != null) {
            throw Exception(constraintsError);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                    height: 40), // Existing padding to lower the audio bar
                // Custom audio bar with adjusted timer position
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Play button
                      IconButton(
                        icon: const Icon(Icons.play_circle_filled,
                            color: Colors.blue, size: 30),
                        onPressed: playAudio,
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0,
                          backgroundColor: Colors.grey[300],
                          color: const Color.fromARGB(255, 5, 25, 41),
                          minHeight: 5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Timer (positioned after the play button)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: const Text(
                          '00:00',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      // Volume and settings icons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: Colors.grey, size: 24),
                            onPressed: () {
                              // Toggle sound
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.settings,
                                color: Colors.grey, size: 24),
                            onPressed: () {
                              // Open settings
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Apply consistent horizontal padding to all content below the audio bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            final row = index ~/ 3;
                            final col = index % 3;
                            final item = fixedLayout[row][col];
                            final isWord = currentWords.contains(item);

                            final pair =
                                questions[currentQuestionIndex].firstWhere(
                              (pair) => pair['word'] == item,
                              orElse: () => {'word': '', 'definition': ''},
                            );
                            final definition = pair['definition'] ?? '';
                            final displayText = '$item\n($definition)';

                            final isMatched = matchedWords.contains(item);
                            if (isMatched && !isBlinking) {
                              return const SizedBox.shrink();
                            }

                            final isSelected = selectedWord == item;
                            final isWrong = wrongWords.contains(item);

                            Color backgroundColor = Colors.white;
                            if (isMatched && isBlinking) {
                              backgroundColor =
                                  showColor ? Colors.green : Colors.white;
                            } else if (isWrong && isBlinking) {
                              backgroundColor =
                                  showColor ? Colors.red : Colors.white;
                            } else if (isSelected) {
                              backgroundColor = Colors.grey;
                            }

                            return GestureDetector(
                              onTap: () {
                                if (isWord) {
                                  selectWord(item);
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      displayText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isWord
                                            ? Colors.orange
                                            : Colors.black,
                                        fontWeight: isWord
                                            ? FontWeight.bold
                                            : FontWeight.normal,
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
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: currentQuestionIndex > 0
                                    ? previousQuestion
                                    : null,
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
