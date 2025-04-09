import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/audio_player.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/full_audio_player.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class DetailedAnswerScreen extends StatefulWidget {
  final String attemptId;
  final String testId;
  final bool isFullTest;
  final Map<String, dynamic> resultData;

  const DetailedAnswerScreen({
    super.key,
    required this.attemptId,
    required this.testId,
    required this.isFullTest,
    required this.resultData,
  });

  @override
  DetailedAnswerScreenState createState() => DetailedAnswerScreenState();
}

class DetailedAnswerScreenState extends State<DetailedAnswerScreen> {
  List<Map<String, dynamic>> testParts = [];
  String? fullAudioUrl;
  int currentPartIndex = 0;
  bool showAllDetails =
      false; // Trạng thái hiển thị tất cả Transcript/Explanation
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};
  final Map<String, bool> _transcriptExpandedStates =
      {}; // Trạng thái Transcript
  final Map<String, bool> _explanationExpandedStates =
      {}; // Trạng thái Explanation

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void initializeData() {
    setState(() {
      testParts =
          List<Map<String, dynamic>>.from(widget.resultData['parts'] ?? []);
      fullAudioUrl =
          widget.isFullTest && widget.resultData.containsKey('fullAudioUrl')
              ? widget.resultData['fullAudioUrl']
              : null;
    });
  }

  int getQuestionNumber(int partIndex, int questionIndex) {
    int questionNumber = 0;
    for (int i = 0; i < partIndex; i++) {
      questionNumber += (testParts[i]['Questions'].length as int);
    }
    return questionNumber + questionIndex + 1;
  }

  @override
  Widget build(BuildContext context) {
    final testTitle = widget.resultData['testTitle'] ?? 'Unknown Test';
    final answers = widget.resultData['answers'] as Map<String, dynamic>;
    final currentPart = testParts[currentPartIndex];
    final questions = List<Map<String, dynamic>>.from(currentPart['Questions']);

    final darkMode = THelperFunctions.isDarkMode(context);

    _questionKeys.clear();
    for (int i = 0; i < questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$testTitle',
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay về trang Kết quả
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAllDetails = !showAllDetails;
                      if (!showAllDetails) {
                        _transcriptExpandedStates.clear();
                        _explanationExpandedStates.clear();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6), // Bo góc
                    ),
                  ),
                  child: const Text(
                    'Hiện giải thích/transcript',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: testParts.asMap().entries.map((entry) {
                  final index = entry.key;
                  final part = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        part['title'],
                        style: TextStyle(
                          color: currentPartIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      selected: currentPartIndex == index,
                      selectedColor: const Color(0xFF00A2FF),
                      backgroundColor: Colors.grey[200],
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            currentPartIndex = index;
                            _scrollController.jumpTo(0);
                          });
                        }
                      },
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(),
          if (widget.isFullTest && fullAudioUrl != null)
            FullAudioPlayerWidget(audioUrl: ApiConstants.getUrl(fullAudioUrl!)),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionId = question['id'].toString();
                final userAnswer = answers[questionId];
                final correctAnswer = question['answer'] ?? 'Không có đáp án';
                final isCorrect = userAnswer == correctAnswer;
                final isUnanswered = userAnswer == null;
                final options =
                    Map<String, dynamic>.from(question['options'] ?? {});
                final questionNumber =
                    getQuestionNumber(currentPartIndex, index);

                // Quản lý trạng thái dropdown riêng lẻ
                _transcriptExpandedStates[questionId] ??= false;
                _explanationExpandedStates[questionId] ??= false;
                final isTranscriptExpanded =
                    showAllDetails || _transcriptExpandedStates[questionId]!;
                final isExplanationExpanded =
                    showAllDetails || _explanationExpandedStates[questionId]!;

                return Container(
                  key: _questionKeys[index],
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (question['content'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            question['content'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      if (!widget.isFullTest && question['audioUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: AudioPlayerWidget(
                            audioUrl: ApiConstants.getUrl(question['audioUrl']),
                          ),
                        ),
                      if (question['imageUrl'] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl:
                                  ApiConstants.getUrl(question['imageUrl']),
                              httpHeaders:
                                  ApiConstants.getHeaders(isImage: true),
                              height: 200,
                              width: 400,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      if (question['transcript'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transcript:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isTranscriptExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _transcriptExpandedStates[questionId] =
                                          !(_transcriptExpandedStates[
                                                  questionId] ??
                                              false);
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (isTranscriptExpanded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question['transcript'],
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: darkMode
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.withValues(alpha: 0.1),
                            ),
                            child: Center(
                              child: Text(
                                '$questionNumber',
                                style: TextStyle(
                                  color: darkMode
                                      ? Colors.blueAccent
                                      : Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...options.entries.map((option) {
                        final isOptionCorrect = option.key == correctAnswer;
                        final isUserChoice = option.key == userAnswer;
                        Color? textColor =
                            darkMode ? Colors.white : Colors.black;
                        Color? backgroundColor;

                        if (isUserChoice && isCorrect) {
                          textColor = Colors.green;
                          backgroundColor =
                              darkMode ? Colors.green[100] : Colors.green[50];
                        } else if (isUserChoice && !isCorrect) {
                          textColor = Colors.red;
                          backgroundColor = Colors.red[100];
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 32.0, bottom: 8, right: 24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: RadioListTile<String>(
                              title: Text(
                                '${option.key}: ${option.value}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isOptionCorrect && !isUnanswered
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: textColor,
                                ),
                              ),
                              value: option.key,
                              groupValue: userAnswer,
                              onChanged: null, // Vô hiệu hóa Radio
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 0),
                              dense: true,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      if (question['explanation'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Giải thích chi tiết đáp án:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isExplanationExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _explanationExpandedStates[questionId] =
                                          !(_explanationExpandedStates[
                                                  questionId] ??
                                              false);
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (isExplanationExpanded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  question['explanation'] ??
                                      'Không có giải thích.',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: darkMode
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      const Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedReviewScreen(
                          allParts: testParts,
                          answers: answers,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        currentPartIndex = result['partIndex'];
                        final questionIndex = result['questionIndex'] as int;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final targetKey = _questionKeys[questionIndex];
                          if (targetKey != null &&
                              targetKey.currentContext != null) {
                            final RenderBox renderBox =
                                targetKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            final position = renderBox.localToGlobal(
                                Offset.zero,
                                ancestor: context.findRenderObject());
                            final offset =
                                position.dy + _scrollController.offset - 100;
                            _scrollController.animateTo(
                              offset,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Review',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailedReviewScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allParts;
  final Map<String, dynamic> answers;

  const DetailedReviewScreen({
    super.key,
    required this.allParts,
    required this.answers,
  });

  int getQuestionNumber(int partIndex, int questionIndex) {
    int questionNumber = 0;
    for (int i = 0; i < partIndex; i++) {
      questionNumber += (allParts[i]['Questions'].length as int);
    }
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
          final questions = List<Map<String, dynamic>>.from(part['Questions']);
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
                  final userAnswer = answers[questionId];
                  final correctAnswer = question['answer'];
                  final isCorrect = userAnswer == correctAnswer;
                  final isUnanswered = userAnswer == null;

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
                        color: isUnanswered
                            ? Colors.white
                            : (isCorrect
                                ? Colors.greenAccent[400]
                                : Colors.red[400]),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '$questionNumber',
                          style: TextStyle(
                            color: isUnanswered ? Colors.black : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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

void showDetailedAnswerScreen({
  required String attemptId,
  required String testId,
  required bool isFullTest,
  required Map<String, dynamic> resultData,
}) {
  Get.to(() => DetailedAnswerScreen(
        attemptId: attemptId,
        testId: testId,
        isFullTest: isFullTest,
        resultData: resultData,
      ));
}
