import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_screen.dart';
import 'package:get/get.dart';
import './discussion_section.dart';

class FullTestTab extends StatelessWidget {
  final Map<String, dynamic> test;
  final String testId;
  final Future<void> Function() onRefresh;

  const FullTestTab({
    super.key,
    required this.test,
    required this.testId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
                onPressed: () async {
                  final result = await Navigator.push(
                    Get.context!,
                    MaterialPageRoute(
                      builder: (context) => TestScreen(
                        testId: testId,
                        isFullTest: true,
                      ),
                    ),
                  );
                  if (result == true) {
                    await onRefresh();
                  }
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
              child: DiscussionSection(
                  comments: test['Comments'], onAddComment: (_) async {}),
            ),
          ],
        ),
      ),
    );
  }
}