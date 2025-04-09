import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_detail_screen.dart';
import 'package:flutter_elearning_project/navigation_menu.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './summary_section.dart';
import './stats_section.dart';
import './toeic_scores_section.dart';
import './detailed_analysis_section.dart';
import './answers_section.dart';
import './discussion_section.dart';
import './question_detail_dialog.dart';
import '../practice_test.dart';

class TestResultScreen extends StatefulWidget {
  final String attemptId;
  final String testId;
  final bool isFullTest;
  final String? fullAudioUrl;
  final String? previousScreen;

  const TestResultScreen({
    super.key,
    required this.attemptId,
    required this.testId,
    required this.isFullTest,
    this.fullAudioUrl,
    this.previousScreen, // Có thể là 'SettingScreen', 'TestScreen', hoặc 'TestDetailScreen'
  });

  @override
  TestResultScreenState createState() => TestResultScreenState();
}

class TestResultScreenState extends State<TestResultScreen> {
  Map<String, dynamic>? resultData;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  int currentPartIndex = 0;
  List<dynamic>? comments = [];

  @override
  void initState() {
    super.initState();
    fetchResultData();
    fetchComments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchResultData() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found');

      final resultUri = Uri.parse(ApiConstants.getUrl(widget.isFullTest
          ? '/getFullTestResult/${widget.attemptId}'
          : '/getPracticeResult/${widget.attemptId}'));
      final resultResponse = await http.get(
        resultUri,
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      final testDetailUri =
          Uri.parse(ApiConstants.getUrl('/getTestDetail/${widget.testId}'));
      final testDetailResponse = await http.get(
        testDetailUri,
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (resultResponse.statusCode == 200 &&
          testDetailResponse.statusCode == 200) {
        setState(() {
          resultData = json.decode(resultResponse.body);
          comments = json.decode(testDetailResponse.body)['Comments'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data: ${resultResponse.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load result: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found');

      final testDetailUri =
          Uri.parse(ApiConstants.getUrl('/getTestDetail/${widget.testId}'));
      final testDetailResponse = await http.get(
        testDetailUri,
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (testDetailResponse.statusCode == 200) {
        setState(() {
          comments = json.decode(testDetailResponse.body)['Comments'];
        });
      } else {
        throw Exception('Failed to load comments: ${testDetailResponse.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load comments: $e');
    }
  }

  Future<void> addComment(String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      Get.snackbar('Error', 'Không tìm thấy token! Vui lòng đăng nhập lại.');
      return;
    }
    final uri = Uri.parse(ApiConstants.getUrl('/addComment'));
    final response = await http.post(
      uri,
      headers: {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'testId': widget.testId, 'content': content}),
    );
    if (response.statusCode == 201) {
      Get.snackbar('Thành công', 'Bình luận đã được đăng!');
      await fetchComments(); // Chỉ load lại comments
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  Map<String, Map<String, dynamic>> calculateTagStats(
      List<dynamic> parts, Map<String, dynamic> attempt) {
    final tagStats = <String, Map<String, dynamic>>{};
    final isFullTest = attempt['isFullTest'] as bool? ?? true;
    final selectedPartIdsRaw = attempt['selectedParts'];
    final selectedPartIds = isFullTest || selectedPartIdsRaw == null
        ? null
        : (json.decode(selectedPartIdsRaw) as List<dynamic>);

    for (var part in parts) {
      if (!isFullTest &&
          selectedPartIds != null &&
          selectedPartIds.isNotEmpty &&
          !selectedPartIds.contains(part['id'])) {
        continue;
      }

      final questions = part['Questions'] as List<dynamic>;
      for (var q in questions) {
        final tag = q['tag'] != null
            ? '[${part['title']}] ${q['tag']}'
            : '[${part['title']}] Không phân loại';
        if (!tagStats.containsKey(tag)) {
          tagStats[tag] = {
            'total': 0,
            'correct': 0,
            'wrong': 0,
            'skipped': 0,
            'questionIds': <int>[],
          };
        }
        tagStats[tag]!['total']++;
        tagStats[tag]!['questionIds'].add(q['id']);
        final userAnswer = attempt['answers'][q['id'].toString()];
        final correctAnswer = q['answer'];

        if (userAnswer == null) {
          tagStats[tag]!['skipped']++;
        } else if (userAnswer == correctAnswer) {
          tagStats[tag]!['correct']++;
        } else {
          tagStats[tag]!['wrong']++;
        }
      }
    }

    return tagStats;
  }

  Map<String, dynamic> calculateToeicScores(
      List<dynamic> parts, Map<String, dynamic> answers) {
    int listeningMaxQuestions = 0;
    int readingMaxQuestions = 0;
    int listeningCorrect = 0;
    int readingCorrect = 0;

    for (var part in parts) {
      final partTitle = part['title'].toString().toLowerCase();
      final questions = part['Questions'] as List<dynamic>;
      final questionCount = questions.length;

      if (partTitle.contains('part 1') ||
          partTitle.contains('part 2') ||
          partTitle.contains('part 3') ||
          partTitle.contains('part 4')) {
        listeningMaxQuestions += questionCount;
        for (var q in questions) {
          final userAnswer = answers[q['id'].toString()];
          final correctAnswer = q['answer'];
          if (userAnswer != null && userAnswer == correctAnswer) {
            listeningCorrect++;
          }
        }
      } else if (partTitle.contains('part 5') ||
          partTitle.contains('part 6') ||
          partTitle.contains('part 7')) {
        readingMaxQuestions += questionCount;
        for (var q in questions) {
          final userAnswer = answers[q['id'].toString()];
          final correctAnswer = q['answer'];
          if (userAnswer != null && userAnswer == correctAnswer) {
            readingCorrect++;
          }
        }
      }
    }

    final listeningMaxScore = listeningMaxQuestions * 5;
    final readingMaxScore = readingMaxQuestions * 5;

    final listeningScore = listeningMaxQuestions > 0
        ? (listeningCorrect / listeningMaxQuestions) * listeningMaxScore
        : 0;
    final readingScore = readingMaxQuestions > 0
        ? (readingCorrect / readingMaxQuestions) * readingMaxScore
        : 0;

    return {
      'listening': {
        'score': listeningScore.round(),
        'correct': listeningCorrect,
        'total': listeningMaxQuestions,
        'maxScore': listeningMaxScore,
      },
      'reading': {
        'score': readingScore.round(),
        'correct': readingCorrect,
        'total': readingMaxQuestions,
        'maxScore': readingMaxScore,
      },
    };
  }

  Map<int, int> getQuestionNumberMapping(List<dynamic> parts) {
    Map<int, int> questionNumberMap = {};
    int questionNumber = 0;
    for (int partIndex = 0; partIndex < parts.length; partIndex++) {
      final questions = parts[partIndex]['Questions'] as List<dynamic>;
      for (int questionIndex = 0;
          questionIndex < questions.length;
          questionIndex++) {
        questionNumber++;
        questionNumberMap[questions[questionIndex]['id']] = questionNumber;
      }
    }
    return questionNumberMap;
  }

  final GlobalKey _answerSectionKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (resultData == null) {
      return const Scaffold(
        body: Center(child: Text('Không có dữ liệu kết quả')),
      );
    }

    final testTitle = resultData!['testTitle'] ?? 'Unknown Test';
    final correctCount = resultData!['correctCount'] ?? 0;
    final wrongCount = resultData!['wrongCount'] ?? 0;
    final skippedCount = resultData!['skippedCount'] ?? 0;
    final totalQuestions = resultData!['totalQuestions'] ??
        (correctCount + wrongCount + skippedCount);
    final accuracy = resultData!['accuracy'] ?? '0.00';
    final completionTime = resultData!['completionTime'] ?? '00:00:00';
    final scaledScore = resultData!['scaledScore'];
    final questions = resultData!['questions'] as List<dynamic>;
    final parts = resultData!['parts'] as List<dynamic>;
    final tagStats = calculateTagStats(parts, resultData!);
    Map<String, dynamic>? toeicScores;
    if (resultData!['examType'] == 'TOEIC') {
      toeicScores = calculateToeicScores(parts, resultData!['answers']);
    }

    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài làm'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            switch (widget.previousScreen) {
              case 'SettingScreen':
                Navigator.pop(context); // Quay lại SettingScreen
                break;
              case 'TestScreen':
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TestDetailScreen(testId: widget.testId),
                  ),
                );
                break;
              case 'TestDetailScreen':
                Navigator.pop(context); // Quay lại TestDetailScreen
                break;
              default:
                // Trường hợp mặc định: Quay về màn hình đầu tiên (Home)
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeTestScreen(),
                  ),
                );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isFullTest
                    ? 'Kết quả thi: $testTitle'
                    : 'Kết quả luyện tập: $testTitle',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (!widget.isFullTest) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4.0,
                  children: parts.map<Widget>((part) {
                    return Chip(
                      label: Text(
                        part['title'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final RenderBox? renderBox =
                          _answerSectionKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (renderBox != null) {
                        final position = renderBox.localToGlobal(Offset.zero);
                        _scrollController.animateTo(
                          _scrollController.offset + position.dy - 100,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Xem đáp án',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      // Lấy NavigationController từ GetX
                      final navigationController =
                          Get.find<NavigationController>();
                      // Đặt selectedIndex về tab "Luyện thi" (index = 2)
                      navigationController.selectedIndex.value = 2;
                      // Quay về màn hình gốc (NavigationMenu)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Quay về trang đề thi',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SummarySection(
                correctCount: correctCount,
                totalQuestions: totalQuestions,
                accuracy: accuracy,
                completionTime: completionTime,
              ),
              const SizedBox(height: 16),
              StatsSection(
                correctCount: correctCount,
                wrongCount: wrongCount,
                skippedCount: skippedCount,
                scaledScore: scaledScore,
                isFullTest: widget.isFullTest,
              ),
              const SizedBox(height: 16),
              if (toeicScores != null)
                ToeicScoresSection(toeicScores: toeicScores),
              if (toeicScores != null) const SizedBox(height: 16),
              DetailedAnalysisSection(
                parts: parts,
                tagStats: tagStats,
                currentPartIndex: currentPartIndex,
                onPartSelected: (index) =>
                    setState(() => currentPartIndex = index),
              ),
              const SizedBox(height: 16),
              AnswersSection(
                key: _answerSectionKey,
                parts: parts,
                questions: questions,
                answers: resultData!['answers'],
                testTitle: testTitle,
                questionNumberMap: getQuestionNumberMapping(parts),
                onShowQuestionDetail: (question, questionNumber) =>
                    showQuestionDetailDialog(
                        question, testTitle, questionNumber),
                attemptId: widget.attemptId,
                testId: widget.testId,
                isFullTest: widget.isFullTest,
                resultData: resultData!,
              ),
              const SizedBox(height: 24),
              DiscussionSection(
                  comments: comments ?? [], onAddComment: addComment),
            ],
          ),
        ),
      ),
    );
  }
}
