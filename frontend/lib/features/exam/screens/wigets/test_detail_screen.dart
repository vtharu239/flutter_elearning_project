import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/answer_transcript_tab.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import './test_info_section.dart';
import './discussion_section.dart';
import './practice_tab.dart';
import './full_test_tab.dart';

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
  Map<String, dynamic>? _testData;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
    _fetchTestData();
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
        _testData = null;
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
      await _fetchTestData();
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
          ? const Center(child: CircularProgressIndicator())
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
                    height: MediaQuery.of(context).size.height - 250,
                    child: TabBarView(
                      controller: _mainTabController,
                      children: [
                        _buildInfoTab(context, _testData!),
                        AnswerTranscriptTab(
                            test: _testData!, onAddComment: addComment),
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
          height: MediaQuery.of(context).size.height - 300,
          child: TabBarView(
            controller: _subTabController,
            children: [
              PracticeTab(
                  test: test, testId: widget.testId, onRefresh: _fetchTestData),
              FullTestTab(
                  test: test, testId: widget.testId, onRefresh: _fetchTestData),
              DiscussionSection(
                  comments: test['Comments'], onAddComment: addComment),
            ],
          ),
        ),
      ],
    );
  }
}
