import 'dart:async';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/review_screen.dart';
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
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  Map<String, dynamic>? testData;
  String? attemptId;
  List<Map<String, dynamic>> testParts = [];
  String? fullAudioUrl;
  int currentPartIndex = 0;
  Map<String, String> answers = {};
  Map<String, bool> markedForReview = {};
  Timer? timer;
  late ValueNotifier<int> elapsedSecondsNotifier; // Đếm số giây đã trôi qua
  DateTime? startTime; // Lưu thời gian bắt đầu
  int? totalDurationInSeconds; // Tổng thời gian (nếu có giới hạn)
  bool isUnlimitedTime =
      false; // Cờ để kiểm tra chế độ không giới hạn thời gian
  bool isLoading = true;
  bool isSubmitted = false;

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
    super.dispose();
  }

  Future<void> initializeTest() async {
    setState(() => isLoading = true);
    try {
      await startTest();
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
      print('Start Test Response: $data');
      setState(() {
        attemptId = data['attemptId'].toString();
        testParts = List<Map<String, dynamic>>.from(data['testParts'] ?? []);
        fullAudioUrl = data['fullAudioUrl'];
        final duration = widget.isFullTest
            ? data['duration']
            : (widget.duration ?? data['duration']);
        startTime = DateTime.now(); // Lưu thời gian bắt đầu
        if (duration == null) {
          isUnlimitedTime = true; // Chế độ không giới hạn thời gian
          elapsedSecondsNotifier.value = 0;
        } else {
          totalDurationInSeconds =
              (duration as int) * 60; // Chuyển phút thành giây
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
          submitTest(); // Tự động nộp bài khi hết thời gian
        }
      });
    });
  }

  Future<void> submitTest() async {
    if (isSubmitted) return;
    setState(() => isSubmitted = true);

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
        'startTime': startTime?.toIso8601String(), // Gửi startTime lên server
      }),
    );

    if (response.statusCode == 200) {
      Get.snackbar('Thành công', 'Đã nộp bài!');
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      setState(() => isSubmitted = false);
      throw Exception('Failed to submit test: ${response.body}');
    }
  }

  Future<void> showExitConfirmationDialog() async {
    final bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận thoát'),
        content: const Text(
            'Bạn có chắc chắn muốn thoát? Bài làm của bạn sẽ không được lưu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  String formatTime(int elapsedSeconds) {
    if (isUnlimitedTime) {
      // Đếm lên từ 00:00
      final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } else {
      // Đếm ngược từ totalDurationInSeconds
      final remainingSeconds = totalDurationInSeconds! - elapsedSeconds;
      if (remainingSeconds <= 0) return '00:00';
      final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.isFullTest ? 'Full Test' : 'Luyện tập'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: showExitConfirmationDialog,
              child: const Text(
                'Thoát',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ValueListenableBuilder<int>(
                valueListenable: elapsedSecondsNotifier,
                builder: (context, elapsedSeconds, child) {
                  return Text(
                    formatTime(elapsedSeconds),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: testParts.asMap().entries.map((entry) {
                final index = entry.key;
                final part = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(part['title']),
                    selected: currentPartIndex == index,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => currentPartIndex = index);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              cacheExtent: 1000.0,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionId = question['id'].toString();
                final options =
                    Map<String, dynamic>.from(question['options'] ?? {});
                final optionKeys = options.keys.toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Câu ${index + 1}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(
                                markedForReview[questionId] == true
                                    ? Icons.star
                                    : Icons.star_border,
                                color: markedForReview[questionId] == true
                                    ? Colors.orange
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  markedForReview[questionId] =
                                      !(markedForReview[questionId] ?? false);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question['content'] ?? 'Không có nội dung câu hỏi',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        if (currentPart['audioUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: AudioPlayerWidget(
                              audioUrl:
                                  ApiConstants.getUrl(currentPart['audioUrl']),
                            ),
                          ),
                        if (question['imageUrl'] != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: CachedNetworkImage(
                              imageUrl:
                                  ApiConstants.getUrl(question['imageUrl']),
                              httpHeaders:
                                  ApiConstants.getHeaders(isImage: true),
                              height: 200,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        const SizedBox(height: 8),
                        ...optionKeys.map((option) => RadioListTile<String>(
                              title: Text(
                                '${option}: ${options[option]}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              value: option,
                              groupValue: answers[questionId],
                              onChanged: (value) {
                                setState(() {
                                  answers[questionId] = value!;
                                });
                              },
                            )),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewScreen(
                          allParts: testParts,
                          answers: answers,
                          markedForReview: markedForReview,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Review'),
                ),
                ElevatedButton(
                  onPressed: submitTest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Nộp bài'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: () async {
            if (isPlaying) {
              await _audioPlayer.pause();
              setState(() => isPlaying = false);
            } else {
              await _audioPlayer.play(UrlSource(widget.audioUrl));
              setState(() => isPlaying = true);
            }
          },
        ),
      ],
    );
  }
}
