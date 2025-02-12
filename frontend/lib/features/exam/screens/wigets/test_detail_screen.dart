import 'package:flutter/material.dart';

class TestDetailScreen extends StatelessWidget {
  const TestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags and Title Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(
                        label: Text('#Toeic Academic'),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.blue),
                        labelStyle: TextStyle(color: Colors.blue),
                      ),
                      Chip(
                        label: Text('#Listening'),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: Colors.blue),
                        labelStyle: TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toeic Simulation Listening test 2',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TabBar(
              tabs: [
                Tab(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 60),
                    child: const Text(
                      'Thông tin đề thi',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                Tab(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 60),
                    child: const Text(
                      'Đáp án/transcript',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              isScrollable: true,
            ),
            const SizedBox(height: 12),
            const TestInfoSection(),
            // Main Tab Bar View
            Expanded(
              child: TabBarView(
                children: [
                  // Thông tin đề thi Tab
                  _buildInfoTab(context),
                  // Đáp án/transcript Tab
                  _buildAnswerTranscriptTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context) {
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
                _buildPracticeTab(),
                _buildFullTestTab(),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDiscussionSection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerTranscriptTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAnswerSection(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDiscussionSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeTab() {
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecordingSection(
            'Recording 1 (10 câu hỏi)',
            ['[Listening] Note/Form Completion'],
          ),
          _buildRecordingSection(
            'Recording 2 (10 câu hỏi)',
            [
              '[Listening] Summary/Flow chart Completion',
              '[Listening] Sentence Completion'
            ],
          ),
          _buildRecordingSection(
            'Recording 3 (10 câu hỏi)',
            ['[Listening] Note/Form Completion', '[Listening] Multiple Choice'],
          ),
          _buildRecordingSection(
            'Recording 4 (10 câu hỏi)',
            [
              '[Listening] Summary/Flow chart Completion',
              '[Listening] Short Answer'
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Giới hạn thời gian (Để trống để làm bài không giới hạn)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _buildDiscussionSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTestTab() {
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
                          'Sẵn sàng để bắt đầu làm full test? Để đạt được kết quả tốt nhất, bạn cần dành ra 120 phút cho bài test này.',
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildDiscussionSection(),
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
                child: Checkbox(
                  value: false,
                  onChanged: (bool? value) {},
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
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(tag, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: const Text('Part 1 (6 câu hỏi)'),
            children: [
              ListTile(
                title: const Text('Q01: [Text thuộc tính]'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Đáp án'),
                ),
              ),
              ListTile(
                title: const Text('Q02: [Thanh toán hoặc ký quỹ]'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Đáp án'),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Part 2 (25 câu hỏi)'),
            children: [
              ListTile(
                title: const Text('Q07: [TOEIC Listening]'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Đáp án'),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Part 3 (39 câu hỏi)'),
            children: [
              ListTile(
                title: const Text('Q32: [Company - General Info]'),
                trailing: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Đáp án'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bình luận',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Chia sẻ cảm nghĩ của bạn ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Gửi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildCommentList(),
      ],
    );
  }

  Widget _buildCommentList() {
    return Column(
      children: [
        _buildComment(
          'xinchaoooooooo',
          'Feb. 08, 2025',
          'mình có write 8., ai muốn cải thiện knang này lhe mình nhá zl : 0918160903',
        ),
        _buildComment(
          'quyendeptrai31012007',
          'Feb. 08, 2025',
          'app rõ 27 tháng 8 mà đáp án là 22',
        ),
        _buildComment(
          'nhipham198208',
          'Feb. 06, 2025',
          'htai speaking mh 6.5, tìm b aim speaking 7-7.5 a. Cta có thể hỏi nhau về các topics liên quan tới quý 1/2025. Zalo mh : 0335230884',
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Xem thêm',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComment(String username, String date, String content) {
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
                backgroundColor: Colors.grey[300],
                child: Text(username[0].toUpperCase()),
              ),
              Text(username),
              Text(date, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
          TextButton(
            onPressed: () {},
            child: const Text('Trả lời'),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class TestInfoSection extends StatelessWidget {
  const TestInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.black54),
              const Text(
                'Thời gian làm bài: 120 phút',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const Text('|', style: TextStyle(color: Colors.black54)),
              const Text(
                '7 phần thi',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const Text('|', style: TextStyle(color: Colors.black54)),
              const Text(
                '200 câu hỏi',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const Text('|', style: TextStyle(color: Colors.black54)),
              const Text(
                '226 bình luận',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              const Icon(Icons.people, size: 16, color: Colors.black54),
              const Text(
                '359028 người đã luyện tập đề thi này',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Chú ý: để được quy đổi sang scaled score (ví dụ trên thang điểm 990 cho TOEIC hoặc 9.0 cho IELTS), vui lòng chọn chế độ làm FULL TEST.',
            style: TextStyle(fontSize: 14, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
