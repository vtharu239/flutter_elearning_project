import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_result_screen.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Section hiển thị kết quả thi mới nhất
class LatestTestResultsSection extends StatefulWidget {
  final bool isLimited; // Thêm tham số để kiểm soát chế độ hiển thị

  const LatestTestResultsSection({super.key, this.isLimited = false});

  @override
  LatestTestResultsSectionState createState() =>
      LatestTestResultsSectionState();
}

class LatestTestResultsSectionState extends State<LatestTestResultsSection> {
  int currentPage = 1;
  int totalPages = 1;

  Future<Map<String, dynamic>> fetchAllUserTestAttempts(int page) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return {'tests': [], 'totalPages': 1, 'currentPage': 1};

    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.getAllUserTestAttempts}?page=$page');
    final response = await http.get(
      uri,
      headers: {
        ...ApiConstants.getHeaders(),
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'tests': [], 'totalPages': 1, 'currentPage': 1};
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
          margin: const EdgeInsets.only(right: 2, bottom: 4),
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
      for (var partId in selectedParts) {
        tags.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            margin: const EdgeInsets.only(right: 2, bottom: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Part $partId',
              style: TextStyle(color: Colors.orange[800], fontSize: 12),
            ),
          ),
        );
      }
    }
    return Wrap(spacing: 4, runSpacing: 4, children: tags);
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<Map<String, dynamic>>(
          future: fetchAllUserTestAttempts(currentPage),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!['tests'].isEmpty) {
              return const Text('Bạn chưa làm bài test nào.');
            }

            final tests = snapshot.data!['tests'] as List<dynamic>;
            totalPages = snapshot.data!['totalPages'] as int;

            // Nếu isLimited = true, chỉ lấy bài test đầu tiên
            final displayTests =
                widget.isLimited ? tests.take(1).toList() : tests;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...displayTests.map((test) {
                  final attempts = test['attempts'] as List<dynamic>;
                  // Nếu isLimited = true, chỉ lấy attempt đầu tiên (gần nhất)
                  final displayAttempts =
                      widget.isLimited ? attempts.take(3).toList() : attempts;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          test['testTitle'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      IntrinsicHeight(
                        child: Table(
                          border: TableBorder.all(color: Colors.grey, width: 1),
                          columnWidths: const {
                            0: FractionColumnWidth(0.50),
                            1: FractionColumnWidth(0.30),
                            2: FractionColumnWidth(0.20),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                  color: darkMode
                                      ? Colors.grey[800]
                                      : Colors.grey.shade200),
                              children: const [
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Ngày làm',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Kết quả',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            ...displayAttempts.map((attempt) {
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
                                            attempt['date'] ?? 'N/A',
                                            style:
                                                const TextStyle(fontSize: 15),
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
                                            style:
                                                const TextStyle(fontSize: 14),
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Thời gian: ${formatTime(attempt['completionTime'] ?? '00:00:00')}',
                                            style:
                                                const TextStyle(fontSize: 14),
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
                                                  testId: attempt['testId']
                                                      .toString(),
                                                  isFullTest:
                                                      attempt['isFullTest'] ??
                                                          false,
                                                  previousScreen:
                                                      'SettingScreen',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Xem chi tiết',
                                            style:
                                                TextStyle(color: Colors.blue),
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
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                // Chỉ hiển thị phân trang nếu không giới hạn
                if (!widget.isLimited)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 1; i <= totalPages; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage = i;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: currentPage == i
                                    ? Colors.blue
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '$i',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: currentPage == i
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (currentPage < totalPages)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentPage++;
                              });
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  '>',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
