import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/discussion_section.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/test_screen.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';

class PracticeTab extends StatelessWidget {
  final Map<String, dynamic> test;
  final String testId;
  final Future<void> Function() onRefresh;

  const PracticeTab({
    super.key,
    required this.test,
    required this.testId,
    required this.onRefresh,
  });

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
                  activeColor: Color(0xFF00A2FF),
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
                        color: Colors.grey[300],
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

  @override
  Widget build(BuildContext context) {
    final selectedParts = <int>[].obs;
    final selectedDuration = Rxn<int>();
    final darkMode = THelperFunctions.isDarkMode(context);

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
                          dropdownColor:
                              darkMode ? Colors.grey[800] : Colors.white,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('0 phút')),
                            DropdownMenuItem(value: 2, child: Text('2 phút')),
                            DropdownMenuItem(value: 5, child: Text('5 phút')),
                            DropdownMenuItem(value: 10, child: Text('10 phút')),
                            DropdownMenuItem(value: 15, child: Text('15 phút')),
                            DropdownMenuItem(value: 20, child: Text('20 phút')),
                            // DropdownMenuItem(value: 25, child: Text('25 phút')),
                            DropdownMenuItem(value: 30, child: Text('30 phút')),
                            // DropdownMenuItem(value: 45, child: Text('45 phút')),
                            DropdownMenuItem(value: 60, child: Text('60 phút')),
                            DropdownMenuItem(value: 90, child: Text('90 phút')),
                            DropdownMenuItem(
                                value: 120, child: Text('120 phút')),
                            // DropdownMenuItem(value: 130, child: Text('130 phút')),
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
                            : () async {
                                final duration = selectedDuration.value == 0 ||
                                        selectedDuration.value == null
                                    ? null
                                    : selectedDuration.value; // Xử lý 0 phút
                                final result = await Navigator.push(
                                  Get.context!,
                                  MaterialPageRoute(
                                    builder: (context) => TestScreen(
                                      testId: testId,
                                      isFullTest: false,
                                      selectedPartIds: selectedParts.toList(),
                                      duration:
                                          duration, // Truyền duration đã xử lý
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
                          'LUYỆN TẬP',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                const SizedBox(height: 24),
                const Divider(),
              ],
            ),
          ),
          DiscussionSection(
              comments: test['Comments'], onAddComment: (_) async {}),
        ],
      ),
    );
  }
}
