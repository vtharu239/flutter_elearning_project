import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_result_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestInfoSection extends StatelessWidget {
  final Map<String, dynamic> test;
  final String testId;

  const TestInfoSection({super.key, required this.test, required this.testId});

  Future<List<dynamic>> fetchUserTestAttempts() async {
    if (testId.isEmpty || int.tryParse(testId) == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];
    final uri = Uri.parse(ApiConstants.getUrl('/getUserTestAttempts/$testId'));
    final response = await http.get(
      uri,
      headers: {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['attempts'];
    }
    return [];
  }

  String formatTime(String time) {
    final RegExp timeRegExp = RegExp(r'^\d{2}:\d{2}:\d{2}$');
    if (!timeRegExp.hasMatch(time)) return '00:00:00';
    return time;
  }

  Widget _buildTags(Map<String, dynamic> attempt) {
    final bool isFullTest = attempt['isFullTest'] ?? false;
    List<Widget> tags = [];

    if (isFullTest) {
      tags.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(right: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Full test',
            style: TextStyle(color: Colors.green[800], fontSize: 12),
          ),
        ),
      );
    } else {
      tags.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(right: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Luyện tập',
            style: TextStyle(color: Colors.orange[800], fontSize: 12),
          ),
        ),
      );
      final selectedParts = attempt['selectedParts'] != null
          ? json.decode(attempt['selectedParts']) as List<dynamic>
          : [];
      final parts = test['Parts'] as List<dynamic>;
      for (var partId in selectedParts) {
        final part =
            parts.firstWhere((p) => p['id'] == partId, orElse: () => null);
        if (part != null) {
          tags.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(right: 4, bottom: 4),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                part['title'],
                style: TextStyle(color: Colors.orange[800], fontSize: 12),
              ),
            ),
          );
        }
      }
    }
    return Wrap(spacing: 4, runSpacing: 4, children: tags);
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Icon(Icons.access_time,
                  size: 16, color: darkMode ? Colors.white : Colors.black54),
              Text('Thời gian làm bài: ${test['duration']} phút',
                  style: TextStyle(
                      fontSize: 14,
                      color: darkMode ? Colors.white : Colors.black54)),
              Text('|',
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black54)),
              Text('${test['parts']} phần thi',
                  style: TextStyle(
                      fontSize: 14,
                      color: darkMode ? Colors.white : Colors.black54)),
              Text('|',
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black54)),
              Text(
                  '${test['Parts'].fold(0, (sum, part) => sum + part['questionCount'])} câu hỏi',
                  style: TextStyle(
                      fontSize: 14,
                      color: darkMode ? Colors.white : Colors.black54)),
              Text('|',
                  style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black54)),
              Text('${test['Comments'].length} bình luận',
                  style: TextStyle(
                      fontSize: 14,
                      color: darkMode ? Colors.white : Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Icon(Icons.people,
                  size: 16, color: darkMode ? Colors.white : Colors.black54),
              Text('${test['testCount']} người đã luyện tập đề thi này',
                  style: TextStyle(
                      fontSize: 14,
                      color: darkMode ? Colors.white : Colors.black54)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Chú ý: để được quy đổi sang scaled score (ví dụ trên thang điểm 990 cho TOEIC hoặc 9.0 cho IELTS), vui lòng chọn chế độ làm FULL TEST.',
            style: TextStyle(
                fontSize: 14, color: darkMode ? Colors.red[400] : Colors.red),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<dynamic>>(
            future: fetchUserTestAttempts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Bạn chưa làm bài test này.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kết quả bài làm của bạn:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Table(
                      border: TableBorder.all(
                          color: Colors.grey.shade300, width: 1),
                      columnWidths: const {
                        0: FractionColumnWidth(0.5),
                        1: FractionColumnWidth(0.30),
                        2: FractionColumnWidth(0.20),
                      },
                      children: [
                        TableRow(
                          decoration:
                              BoxDecoration(color: Colors.grey.shade200),
                          children: const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Ngày làm',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Kết quả',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        ...snapshot.data!.map((attempt) {
                          return TableRow(
                            children: [
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${attempt['date'] ?? 'N/A'}',
                                        style: const TextStyle(fontSize: 15),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                      const SizedBox(height: 5),
                                      _buildTags(attempt),
                                    ],
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kết quả: ${attempt['correctCount']}/${attempt['totalQuestions']}${attempt['scaledScore'] != null ? ' (Điểm: ${attempt['scaledScore']})' : ''}',
                                        style: const TextStyle(fontSize: 14),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Thời gian làm bài: ${formatTime(attempt['completionTime'] ?? '00:00:00')}',
                                        style: const TextStyle(fontSize: 14),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(0),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TestResultScreen(
                                              attemptId:
                                                  attempt['id'].toString(),
                                              testId: testId,
                                              isFullTest:
                                                  attempt['isFullTest'] ??
                                                      false,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Xem chi tiết',
                                        style: TextStyle(color: Colors.blue),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}