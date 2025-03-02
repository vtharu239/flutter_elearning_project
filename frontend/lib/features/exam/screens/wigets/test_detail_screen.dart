import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestDetailScreen extends StatelessWidget {
  final String testId;

  const TestDetailScreen({super.key, required this.testId});

  Future<Map<String, dynamic>> fetchTestDetail() async {
    final uri =
        Uri.parse(ApiConstants.getUrl('${ApiConstants.getTestDetail}/$testId'));
    final response = await http.get(uri, headers: ApiConstants.getHeaders());
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load test detail');
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
      body: json.encode({'testId': testId, 'content': content}),
    );
    if (response.statusCode == 201) {
      Get.snackbar('Thành công', 'Bình luận đã được đăng!');
      // Refresh dữ liệu
      Get.forceAppUpdate();
    } else {
      throw Exception('Failed to add comment: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar:
            const TAppBar(showBackArrow: true, title: Text('Chi tiết đề thi')),
        backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchTestDetail(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final test = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (test['Category']['name'] as String)
                            .split(',')
                            .map((tag) => Chip(
                                  label: Text('#$tag'),
                                  backgroundColor: Colors.transparent,
                                  side: const BorderSide(color: Colors.blue),
                                  labelStyle:
                                      const TextStyle(color: Colors.blue),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        test['title'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Thông tin đề thi'),
                    Tab(text: 'Đáp án/transcript'),
                  ],
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  isScrollable: true,
                ),
                const SizedBox(height: 12),
                TestInfoSection(test: test),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildInfoTab(context, test),
                      _buildAnswerTranscriptTab(test),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context, Map<String, dynamic> test) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Luyện tập'),
              Tab(text: 'Làm full test'),
              Tab(text: 'Thảo luận'),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildPracticeTab(test),
                _buildFullTestTab(test),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDiscussionSection(test),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerTranscriptTab(Map<String, dynamic> test) {
    return SingleChildScrollView(
      child: Column(
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
    return SingleChildScrollView(
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
              .map<Widget>((part) => _buildRecordingSection(
                    '${part['title']} (${part['questionCount']} câu hỏi)',
                    (part['tags'] as List<dynamic>).cast<String>(),
                  ))
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('-- Chọn thời gian --'),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: '30', child: Text('30 phút')),
                  DropdownMenuItem(value: '45', child: Text('45 phút')),
                  DropdownMenuItem(value: '60', child: Text('60 phút')),
                ],
                onChanged: (String? value) {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'LUYỆN TẬP',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildFullTestTab(Map<String, dynamic> test) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
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
                    onPressed: () {},
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
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDiscussionSection(test),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection(String title, List<String> tags) {
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
                child: Checkbox(value: false, onChanged: (bool? value) {}),
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
                        borderRadius: BorderRadius.circular(4),
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
                Get.snackbar('Thành công', 'Bình luận đã được đăng!');
                // Refresh dữ liệu nếu cần
                Get.forceAppUpdate();
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

  Widget _buildComment(String username, String date, String content, String? avatarUrl) {
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
                        headers: ApiConstants.getHeaders(isImage: true), // Thêm header
                      )
                    : const AssetImage('assets/images/user.png') as ImageProvider,
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

  Widget _buildCommentList(List<dynamic> comments) {
    return Column(
      children: [
        ...comments
            .map((comment) => _buildComment(
                  comment['User']['username'],
                  comment['createdAt'].substring(0, 10),
                  comment['content'],
                  comment['User']
                      ['avatarUrl'], // Truyền avatarUrl từ dữ liệu API
                ))
            ,
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
}

class TestInfoSection extends StatelessWidget {
  final Map<String, dynamic> test;

  const TestInfoSection({super.key, required this.test});

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
        ],
      ),
    );
  }
}
