import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/audio_player.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/full_audio_player.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/review_screen.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_result_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen extends StatefulWidget {
  final String testId;
  final bool isFullTest;
  final List<int>? selectedPartIds;
  final int? duration;

  const TestScreen({
    super.key,
    required this.testId,
    required this.isFullTest,
    this.selectedPartIds,
    this.duration,
  });

  @override
  TestScreenState createState() => TestScreenState();
}

class TestScreenState extends State<TestScreen> {
  Map<String, dynamic>? testData;
  String? attemptId;
  List<Map<String, dynamic>> testParts = [];
  String? fullAudioUrl;
  int currentPartIndex = 0;
  Map<String, String> answers = {};
  Map<String, bool> markedForReview = {};
  Timer? timer;
  late ValueNotifier<int> elapsedSecondsNotifier;
  DateTime? startTime;
  int? totalDurationInSeconds;
  bool isUnlimitedTime = false;
  bool isLoading = true;
  bool isSubmitted = false;
  final Map<String, GlobalKey<AudioPlayerWidgetState>> _audioPlayerKeys = {};
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _questionKeys = {};

  @override
  void initState() {
    super.initState();
    elapsedSecondsNotifier = ValueNotifier<int>(0);
    initializeTest();
  }

  @override
  void dispose() {
    timer?.cancel();
    elapsedSecondsNotifier.dispose();
    // Dừng audio trước, sau đó dispose
    for (var key in _audioPlayerKeys.values) {
      key.currentState?.stopAudio(); // Dừng trước
      key.currentState?.disposeAudioPlayer(); // Dispose sau
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> initializeTest() async {
    setState(() => isLoading = true);
    try {
      await startTest();
      final uri = Uri.parse(ApiConstants.getUrl('/getTest/${widget.testId}'));
      final response = await http.get(uri, headers: ApiConstants.getHeaders());
      if (response.statusCode == 200) {
        setState(() {
          testData = json.decode(response.body);
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to initialize test: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> startTest() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No token found');

    final uri = Uri.parse(ApiConstants.getUrl(
        widget.isFullTest ? '/startFullTest' : '/startPractice'));
    final response = await http.post(
      uri,
      headers: {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      },
      body: json.encode(widget.isFullTest
          ? {'testId': widget.testId}
          : {
              'testId': widget.testId,
              'partIds': widget.selectedPartIds,
              'duration': widget.duration,
            }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      setState(() {
        attemptId = data['attemptId'].toString();
        testParts = List<Map<String, dynamic>>.from(data['testParts'] ?? []);
        fullAudioUrl = data['fullAudioUrl'];
        final duration = widget.isFullTest
            ? data['duration']
            : (widget.duration ?? data['duration']);
        startTime = DateTime.now();
        if (duration == null) {
          isUnlimitedTime = true;
          elapsedSecondsNotifier.value = 0;
        } else {
          totalDurationInSeconds = (duration as int) * 60;
          elapsedSecondsNotifier.value = 0;
        }
        startTimer();
      });
    } else {
      throw Exception('Failed to start test: ${response.body}');
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isSubmitted) {
        timer.cancel();
        return;
      }

      setState(() {
        elapsedSecondsNotifier.value++;
        if (!isUnlimitedTime &&
            elapsedSecondsNotifier.value >= totalDurationInSeconds!) {
          timer.cancel();
          submitTest(autoSubmit: true); // Tự động submit khi hết thời gian
        }
      });
    });
  }

  int getQuestionNumber(int partIndex, int questionIndex) {
    int questionNumber = 0;
    // Sum the number of questions in all previous parts
    for (int i = 0; i < partIndex; i++) {
      questionNumber += (testParts[i]['questions'].length as int);
    }
    // Add the current question index (1-based)
    return questionNumber + questionIndex + 1;
  }

  Future<void> _showErrorSnackbar(String message) async {
    Get.snackbar('Error', message);
  }

  Future<void> submitTest({bool autoSubmit = false}) async {
    if (isSubmitted) return;

    // Nếu không phải autoSubmit (hết thời gian), hiển thị popup xác nhận
    if (!autoSubmit) {
      final bool? confirmSubmit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Xác nhận nộp bài'),
          content: const Text(
            'Bạn có chắc chắn muốn nộp bài? Hành động này sẽ tổng kết bài làm.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00A2FF),
              ),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A2FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      );

      if (confirmSubmit != true) return;
    }

    setState(() => isSubmitted = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found');

      final uri = Uri.parse(ApiConstants.getUrl(
          widget.isFullTest ? '/submitFullTest' : '/submitPractice'));
      final response = await http.post(
        uri,
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'attemptId': attemptId,
          'answers': answers,
          'testId': widget.testId,
          'partIds': widget.selectedPartIds,
          'startTime': startTime?.toIso8601String(),
          'completionTime': elapsedSecondsNotifier.value,
          'duration': widget.isFullTest
              ? (testData?['duration'] ?? 0)
              : (widget.duration ?? 0),
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        Get.snackbar('Thành công', 'Đã nộp bài!');
        if (mounted) {
          for (var key in _audioPlayerKeys.values) {
            key.currentState?.stopAudio();
          }
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestResultScreen(
                attemptId: responseData['attemptId'].toString(),
                testId: widget.testId,
                isFullTest: widget.isFullTest,
                previousScreen: 'TestScreen',
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to submit test: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitted = false);
      }
      await _showErrorSnackbar('Failed to submit test: $e');
    }
  }

  Future<void> showExitConfirmationDialog() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận thoát'),
        content: const Text(
          'Bạn có chắc chắn muốn thoát? Bài làm của bạn sẽ không được lưu.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF00A2FF),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
              foregroundColor: Colors.white, // Màu chữ trắng
              padding: const EdgeInsets.symmetric(
                  vertical: 10), // Điều chỉnh padding nếu cần
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Bo góc
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      // Stop all audio before exiting
      for (var key in _audioPlayerKeys.values) {
        key.currentState?.stopAudio();
      }
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  String formatTime(int elapsedSeconds) {
    if (isUnlimitedTime) {
      final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } else {
      final remainingSeconds = totalDurationInSeconds! - elapsedSeconds;
      if (remainingSeconds <= 0) return '00:00';
      final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    }
  }

  void _stopCurrentPartAudio() {
    // Dừng tất cả audio của part hiện tại
    final currentPart = testParts[currentPartIndex];
    final questions = List<Map<String, dynamic>>.from(currentPart['questions']);
    for (var question in questions) {
      final questionId = question['id'].toString();
      final audioKey = 'part_${currentPartIndex}_question_$questionId';
      final audioPlayerState = _audioPlayerKeys[audioKey]?.currentState;
      if (audioPlayerState != null) {
        // Kiểm tra null trước khi gọi
        audioPlayerState.stopAudio();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (testParts.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có phần thi nào để hiển thị')),
      );
    }

    final currentPart = testParts[currentPartIndex];
    final questions = List<Map<String, dynamic>>.from(currentPart['questions']);
    final isListeningPart =
        currentPart['partType']?.toLowerCase() == 'listening';

    // Clear old keys and create new ones for the current part's questions
    _questionKeys.clear();
    for (int i = 0; i < questions.length; i++) {
      _questionKeys[i] = GlobalKey();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                testData?['title'] ?? 'Loading...',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: showExitConfirmationDialog,
              child: const Text(
                'Thoát',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: elapsedSecondsNotifier,
                  builder: (context, elapsedSeconds, child) {
                    return Text(
                      formatTime(elapsedSeconds),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
                        if (selected && !widget.isFullTest) {
                          // Chỉ áp dụng cho bài luyện tập
                          _stopCurrentPartAudio(); // Dừng audio của part hiện tại
                          setState(() {
                            currentPartIndex = index;
                            _scrollController.jumpTo(0);
                          });
                        } else if (selected) {
                          setState(() {
                            currentPartIndex = index;
                            _scrollController.jumpTo(0);
                          });
                        }
                      },
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              cacheExtent: 1000.0,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionId = question['id'].toString();
                final options =
                    Map<String, dynamic>.from(question['options'] ?? {});
                final optionKeys = options.keys.toList();

                final audioKey =
                    'part_${currentPartIndex}_question_$questionId';
                _audioPlayerKeys[audioKey] ??=
                    GlobalKey<AudioPlayerWidgetState>();

                // Calculate the sequential question number
                final questionNumber =
                    getQuestionNumber(currentPartIndex, index);
                final isMarked = markedForReview[questionId] == true;

                return Container(
                  color: Colors.white,
                  key: _questionKeys[index],
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (question['content'] !=
                            null) // Chỉ hiển thị nếu content không null
                          Text(
                            question['content'],
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (!widget.isFullTest &&
                            isListeningPart &&
                            question['audioUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AudioPlayerWidget(
                              key: _audioPlayerKeys[audioKey],
                              audioUrl:
                                  ApiConstants.getUrl(question['audioUrl']),
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
                        const SizedBox(height: 12),

                        // Đặt số thứ tự câu hỏi ở đây (sau phần imageUrl)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  markedForReview[questionId] =
                                      !(markedForReview[questionId] ?? false);
                                });
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isMarked
                                      ? Colors.orange
                                      : Colors.blue.withValues(alpha: 0.1),
                                ),
                                child: Center(
                                  child: Text(
                                    '$questionNumber',
                                    style: TextStyle(
                                      color: isMarked
                                          ? Colors.white
                                          : Colors.blueAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),

                        const SizedBox(height: 8),
                        ...optionKeys.map((option) => Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    title: Text(
                                      '$option: ${options[option]}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    value: option,
                                    activeColor: const Color(0xFF00A2FF),
                                    groupValue: answers[questionId],
                                    onChanged: (value) {
                                      setState(() {
                                        answers[questionId] = value!;
                                      });
                                    },
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0, vertical: 0),
                                    dense: true,
                                  ),
                                ],
                              ),
                            )),
                        const Divider(),
                      ],
                    ),
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
                        builder: (context) => ReviewScreen(
                          allParts: testParts,
                          answers: answers,
                          markedForReview: markedForReview,
                        ),
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        currentPartIndex = result['partIndex'];
                        final questionIndex = result['questionIndex'] as int;
                        // Scroll to the specific question using GlobalKey
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
                            final offset = position.dy +
                                _scrollController.offset -
                                240; // Adjust for AppBar
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
                ElevatedButton(
                  onPressed: () =>
                      submitTest(autoSubmit: false), // Người dùng nhấn nút
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A2FF),
                  ),
                  child: const Text(
                    'Nộp bài',
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
