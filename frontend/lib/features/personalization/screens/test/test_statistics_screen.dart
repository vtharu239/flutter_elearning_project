import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/stats_section.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/summary_section.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TestStatisticsScreen extends StatefulWidget {
  const TestStatisticsScreen({super.key});

  @override
  State<TestStatisticsScreen> createState() => _TestStatisticsScreenState();
}

class _TestStatisticsScreenState extends State<TestStatisticsScreen> {
  String? selectedExamType; // Ban đầu để null, sẽ cập nhật sau khi lấy dữ liệu
  String selectedTimeRange = '30 ngày';
  List<String> examTypes = [];
  final List<String> timeRanges = [
    'All',
    '3 ngày',
    '7 ngày',
    '30 ngày',
    '60 ngày',
    '90 ngày',
    '6 tháng',
    '1 năm'
  ];
  Map<String, dynamic>? statsData;

  @override
  void initState() {
    super.initState();
    fetchExamTypes(); // Lấy danh sách examTypes trước
  }

  Future<void> fetchExamTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found');

      final uri = Uri.parse('${ApiConstants.baseUrl}/getAllExamTypes');
      final response = await http.get(
        uri,
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          examTypes = data.map((e) => e['examType'] as String).toList();
          selectedExamType = examTypes.isNotEmpty
              ? examTypes[0]
              : null; // Chọn examType đầu tiên (ID nhỏ nhất)
        });
        if (selectedExamType != null) {
          fetchStatsData(); // Chỉ fetch stats nếu có examType
        }
      } else {
        throw Exception('Failed to load exam types: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load exam types: $e');
    }
  }

  Future<void> fetchStatsData() async {
    if (selectedExamType == null) return; // Không fetch nếu chưa có examType
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No token found');

      final uri = Uri.parse(
          '${ApiConstants.baseUrl}/getTestStatistics?examType=$selectedExamType&timeRange=$selectedTimeRange');
      final response = await http.get(
        uri,
        headers: {
          ...ApiConstants.getHeaders(),
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          statsData = data;
        });
      } else {
        throw Exception('Failed to load stats: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê Kết quả Luyện thi'),
      ),
      body: examTypes.isEmpty || statsData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs ExamType
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: examTypes.map((examType) {
                      return ChoiceChip(
                        selectedColor: Color(0xFF00A2FF),
                        label: Text(
                          examType,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        selected: selectedExamType == examType,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedExamType = examType;
                              fetchStatsData();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Note
                  const Text(
                    'Chú ý: Mặc định trang thống kê sẽ hiển thị các bài làm trong khoảng thời gian 30 ngày gần nhất, để xem kết quả trong khoảng thời gian xa hơn bạn chọn ở phần dropdown dưới đây.',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Time range filter
                  Row(
                    children: [
                      const Text('Lọc theo: ', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 5),
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedTimeRange,
                          isExpanded: true,
                          items: timeRanges.map((range) {
                            return DropdownMenuItem(
                              value: range,
                              child: Text(
                                range,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTimeRange = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: fetchStatsData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Tìm kiếm',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            selectedTimeRange = '30 ngày';
                            fetchStatsData();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Xóa',
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Overall stats
                  StatsSection(
                    correctCount: statsData!['totalCorrect'] ?? 0,
                    wrongCount: statsData!['totalWrong'] ?? 0,
                    skippedCount: statsData!['totalSkipped'] ?? 0,
                    scaledScore: statsData!['avgScaledScore'],
                    isFullTest: true,
                  ),
                  const SizedBox(height: 16),
                  SummarySection(
                    correctCount: statsData!['totalCorrect'] ?? 0,
                    totalQuestions: statsData!['totalQuestions'] ?? 0,
                    accuracy:
                        statsData!['avgAccuracy']?.toStringAsFixed(2) ?? '0.00',
                    completionTime:
                        statsData!['avgCompletionTime'] ?? '00:00:00',
                  ),
                  const SizedBox(height: 16),
                  // PartType Tabs
                  DefaultTabController(
                    length: selectedExamType == 'TOEIC' ? 2 : 4,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Color(0xFF00A2FF),
                          dividerColor: Color(0xFF00A2FF),
                          indicatorColor: Color(0xFF00A2FF),
                          labelStyle: TextStyle(fontSize: 18),
                          tabs: selectedExamType == 'TOEIC'
                              ? const [
                                  Tab(text: 'Listening'),
                                  Tab(text: 'Reading'),
                                ]
                              : const [
                                  Tab(text: 'Listening'),
                                  Tab(text: 'Reading'),
                                  Tab(text: 'Writing'),
                                  Tab(text: 'Speaking'),
                                ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 600,
                          child: TabBarView(
                            children: selectedExamType == 'TOEIC'
                                ? [
                                    Builder(
                                      builder: (context) {
                                        return PartTypeStats(
                                          partType: 'Listening',
                                          stats: statsData!['partStats']
                                                  ?['Listening'] ??
                                              {},
                                        );
                                      },
                                    ),
                                    Builder(
                                      builder: (context) {
                                        return PartTypeStats(
                                          partType: 'Reading',
                                          stats: statsData!['partStats']
                                                  ?['Reading'] ??
                                              {},
                                        );
                                      },
                                    ),
                                  ]
                                : [
                                    Builder(
                                      builder: (context) {
                                        return PartTypeStats(
                                          partType: 'Listening',
                                          stats: statsData!['partStats']
                                                  ?['Listening'] ??
                                              {},
                                        );
                                      },
                                    ),
                                    Builder(
                                      builder: (context) {
                                        return PartTypeStats(
                                          partType: 'Reading',
                                          stats: statsData!['partStats']
                                                  ?['Reading'] ??
                                              {},
                                        );
                                      },
                                    ),
                                    Builder(
                                      builder: (context) {
                                        return PartTypeStats(
                                          partType: 'Writing',
                                          stats: statsData!['partStats']
                                                  ?['Writing'] ??
                                              {},
                                        );
                                      },
                                    ),
                                    Builder(
                                      builder: (context) {
                                        return PartTypeStats(
                                          partType: 'Speaking',
                                          stats: statsData!['partStats']
                                                  ?['Speaking'] ??
                                              {},
                                        );
                                      },
                                    ),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class PartTypeStats extends StatelessWidget {
  final String partType;
  final Map<String, dynamic> stats;

  const PartTypeStats({super.key, required this.partType, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatsCard(
                icon: const Icon(Icons.book, color: Colors.blue, size: 30),
                label: 'Số đề đã làm',
                labelStyle: const TextStyle(fontSize: 16),
                value: '${stats['testCount'] ?? 0}',
                unit: 'đề thi',
              ),
              StatsCard(
                icon: const Icon(Icons.percent, color: Colors.green, size: 30),
                label: 'Độ chính xác',
                labelStyle: const TextStyle(fontSize: 16),
                value: stats['accuracy']?.toStringAsFixed(2) ?? '0.00',
                unit: '%',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  icon: const Icon(Icons.timer, color: Colors.orange),
                  label: 'Thời gian trung bình',
                  labelStyle: const TextStyle(fontSize: 16),
                  value: stats['avgTime'] ?? '00:00:00',
                  unit: '',
                ),
              ),
              Expanded(
                child: StatsCard(
                  icon: const Icon(Icons.numbers, color: Colors.purple),
                  label: 'Điểm trung bình',
                  labelStyle: const TextStyle(fontSize: 16),
                  value: stats['avgScore']?.toStringAsFixed(1) ?? 'N/A',
                  unit: '',
                ),
              ),
              Expanded(
                child: StatsCard(
                  icon: const Icon(Icons.star, color: Colors.yellow),
                  label: 'Điểm cao nhất',
                  labelStyle: const TextStyle(fontSize: 16),
                  value: stats['highestScore']?.toString() ?? 'N/A',
                  unit: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsCard extends StatelessWidget {
  final Icon icon;
  final String label;
  final String value;
  final String unit;
  final EdgeInsetsGeometry padding; // Thêm padding tùy chỉnh
  final TextStyle? labelStyle; // Thêm style cho Label Text
  final double? iconSize; // Thêm kích thước icon tùy chỉnh
  final Color? iconColor; // Thêm màu icon tùy chỉnh

  const StatsCard(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      required this.unit,
      this.padding = const EdgeInsets.all(16.0), // Giá trị mặc định
      this.labelStyle, // Không có giá trị mặc định, để tùy chọn
      this.iconSize, // Không có giá trị mặc định, để tùy chọn
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Card(
      color: darkMode ? Colors.grey[800] : Colors.white,
      elevation: 2,
      shadowColor: Color(0xFF00A2FF),
      child: Padding(
        padding: padding, // Sử dụng padding tùy chỉnh
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon.icon,
              size: iconSize ??
                  icon.size, // Dùng iconSize nếu có, ngược lại dùng mặc định từ icon
              color: iconColor ??
                  icon.color, // Dùng iconColor nếu có, ngược lại dùng mặc định từ icon
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: labelStyle ??
                  const TextStyle(
                      fontSize:
                          12), // Dùng labelStyle nếu có, ngược lại dùng mặc định
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (unit.isNotEmpty)
              Text(
                unit,
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
