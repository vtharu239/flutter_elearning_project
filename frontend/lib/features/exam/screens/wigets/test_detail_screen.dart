import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_screen.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestDetailScreen extends StatefulWidget {
  final String testId;

  const TestDetailScreen({super.key, required this.testId});

  @override
  TestDetailScreenState createState() => TestDetailScreenState();
}

class TestDetailScreenState extends State<TestDetailScreen>
    with TickerProviderStateMixin {
  TabController? _mainTabController;
  TabController? _subTabController;
  Map<String, dynamic>? _testData; // Lưu trữ dữ liệu test để tránh gọi lại API

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
    _fetchTestData(); // Gọi API một lần duy nhất khi khởi tạo
  }

  @override
  void dispose() {
    _mainTabController?.dispose();
    _subTabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchTestData() async {
    try {
      final uri = Uri.parse(ApiConstants.getUrl(
          '${ApiConstants.getTestDetail}/${widget.testId}'));
      final response = await http.get(uri, headers: ApiConstants.getHeaders());
      if (response.statusCode == 200) {
        setState(() {
          _testData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load test detail');
      }
    } catch (e) {
      setState(() {
        _testData = null; // Đặt null nếu lỗi để hiển thị thông báo lỗi
      });
    }
  }

  Future<List<dynamic>> fetchUserTestAttempts() async {
    if (widget.testId.isEmpty || int.tryParse(widget.testId) == null) {
      return [];
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return [];
    final uri =
        Uri.parse(ApiConstants.getUrl('/getUserTestAttempts/${widget.testId}'));
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

  Future<void> addComment(String content) async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn.value) {
      Get.snackbar('Error', 'Vui lòng đăng nhập để đăng bình luận!');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      Get.snackbar('Error', 'Không tìm thấy token! Vui lòng đăng nhập lại.');
      return;
    }
    final uri = Uri.parse(ApiConstants.getUrl(ApiConstants.addComment));
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
      await _fetchTestData(); // Cập nhật lại dữ liệu sau khi thêm bình luận
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    if (_mainTabController == null || _subTabController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar:
          const TAppBar(showBackArrow: true, title: Text('Chi tiết đề thi')),
      backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
      body: _testData == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Hiển thị loading nếu chưa có dữ liệu
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _testData!['title'],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TabBar(
                    controller: _mainTabController,
                    tabs: const [
                      Tab(text: 'Thông tin đề thi'),
                      Tab(text: 'Đáp án/transcript'),
                    ],
                    labelColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.blue,
                    isScrollable: true,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height -
                        250, // Đặt chiều cao cố định để TabBarView hiển thị tốt
                    child: TabBarView(
                      controller: _mainTabController,
                      children: [
                        _buildInfoTab(context, _testData!),
                        _buildAnswerTranscriptTab(_testData!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTab(BuildContext context, Map<String, dynamic> test) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TestInfoSection(test: test, testId: widget.testId),
          _buildSubTabs(test),
        ],
      ),
    );
  }

  Widget _buildSubTabs(Map<String, dynamic> test) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _subTabController,
          tabs: const [
            Tab(text: 'Luyện tập'),
            Tab(text: 'Làm full test'),
            Tab(text: 'Thảo luận'),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: MediaQuery.of(context).size.height -
              300, // Giữ nguyên chiều cao cố định
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildPracticeTab(test),
              _buildFullTestTab(test),
              _buildDiscussionTab(test), // Tách riêng tab Thảo luận để tối ưu
            ],
          ),
        ),
      ],
    );
  }

// Tách tab Thảo luận thành một phương thức riêng
  Widget _buildDiscussionTab(Map<String, dynamic> test) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildDiscussionSection(test),
      ),
    );
  }

  Widget _buildAnswerTranscriptTab(Map<String, dynamic> test) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnswerSection(test),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDiscussionSection(test),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeTab(Map<String, dynamic> test) {
    final selectedParts = <int>[].obs;
    final selectedDuration = Rxn<int>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pro tips: Hình thức luyện tập từng phần và chọn mức thời gian phù hợp sẽ giúp bạn tập trung vào giải đúng các câu hỏi thay vì phải chịu áp lực hoàn thành bài thi.',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Chọn phần thi bạn muốn làm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...test['Parts']
                .map<Widget>((part) => Obx(() => _buildRecordingSection(
                      '${part['title']} (${part['questionCount']} câu hỏi)',
                      (part['tags'] as List<dynamic>).cast<String>(),
                      part['id'],
                      selectedParts,
                    )))
                .toList(),
            const SizedBox(height: 24),
            const Text(
              'Giới hạn thời gian (Để trống để làm bài không giới hạn)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      hint: const Text('-- Chọn thời gian --'),
                      value: selectedDuration.value,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 30, child: Text('30 phút')),
                        DropdownMenuItem(value: 45, child: Text('45 phút')),
                        DropdownMenuItem(value: 60, child: Text('60 phút')),
                      ],
                      onChanged: (int? value) {
                        selectedDuration.value = value;
                      },
                    ),
                  )),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: selectedParts.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              Get.context!,
                              MaterialPageRoute(
                                builder: (context) => TestScreen(
                                  testId: widget.testId,
                                  isFullTest: false,
                                  selectedPartIds: selectedParts.toList(),
                                  duration: selectedDuration.value,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'LUYỆN TẬP',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  )),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildDiscussionSection(test),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingSection(
      String title, List<String> tags, int partId, RxList<int> selectedParts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: selectedParts.contains(partId),
                  onChanged: (bool? value) {
                    if (value == true) {
                      selectedParts.add(partId);
                    } else {
                      selectedParts.remove(partId);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(tag,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTestTab(Map<String, dynamic> test) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.yellow[900]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sẵn sàng để bắt đầu làm full test? Để đạt được kết quả tốt nhất, bạn cần dành ra ${test['duration']} phút cho bài test này.',
                      style: TextStyle(color: Colors.yellow[900]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    Get.context!,
                    MaterialPageRoute(
                      builder: (context) => TestScreen(
                        testId: widget.testId,
                        isFullTest: true,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'BẮT ĐẦU THI',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildDiscussionSection(test),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerSection(Map<String, dynamic> test) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: test['Parts']
            .map<Widget>((part) => ExpansionTile(
                  title: Text(
                      '${part['title']} (${part['questionCount']} câu hỏi)'),
                  children: part['Questions']
                      .map<Widget>((question) => ListTile(
                            title: Text(
                                'Q${question['id']}: ${question['content']}'),
                            trailing: OutlinedButton(
                              onPressed: () {},
                              child:
                                  Text(question['answer'] ?? 'Chưa có đáp án'),
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDiscussionSection(Map<String, dynamic> test) {
    final TextEditingController controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Giới hạn Column không mở rộng quá mức
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Chia sẻ cảm nghĩ của bạn ...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await addComment(controller.text);
                controller.clear();
              } catch (e) {
                Get.snackbar('Error', 'Failed to add comment: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Gửi', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 24),
        _buildCommentList(test['Comments']),
      ],
    );
  }

  Widget _buildCommentList(List<dynamic> comments) {
    return Column(
      children: [
        ...comments.map((comment) => _buildComment(
              comment['User']['username'],
              comment['createdAt'].substring(0, 10),
              comment['content'],
              comment['User']['avatarUrl'],
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Xem thêm', style: TextStyle(color: Colors.blue)),
          ),
        ),
      ],
    );
  }

  Widget _buildComment(
      String username, String date, String content, String? avatarUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(
                        ApiConstants.getUrl(avatarUrl),
                        headers: ApiConstants.getHeaders(isImage: true),
                      )
                    : const AssetImage(TImages.user),
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: (error, stackTrace) {
                  log('Error loading avatar: $error');
                },
              ),
              Text(username),
              Text(date, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
          TextButton(onPressed: () {}, child: const Text('Trả lời')),
          const Divider(),
        ],
      ),
    );
  }
}

class TestInfoSection extends StatelessWidget {
  final Map<String, dynamic> test;
  final String testId;

  const TestInfoSection({super.key, required this.test, required this.testId});

  Future<List<dynamic>> fetchUserTestAttempts() async {
    if (testId.isEmpty || int.tryParse(testId) == null) {
      return [];
    }
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

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$secs';
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
                                        'Thời gian làm bài: ${formatTime(attempt['completionTime'] ?? 0)}',
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
                                        Get.snackbar('Thông báo',
                                            'Chuyển đến trang xem chi tiết kết quả (chưa triển khai)');
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
