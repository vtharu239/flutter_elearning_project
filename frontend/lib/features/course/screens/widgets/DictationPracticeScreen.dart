import 'package:flutter/material.dart';

class DictationPracticeScreen extends StatefulWidget {
  const DictationPracticeScreen({super.key});

  @override
  State<DictationPracticeScreen> createState() =>
      _DictationPracticeScreenState();
}

class _DictationPracticeScreenState extends State<DictationPracticeScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool showVietnameseMeaning = true;
  bool autoReplay = false;
  String correctWord = "đường hầm"; // Mock correct word for this example
  String? errorMessage;

  void checkAnswer() {
    setState(() {
      if (_answerController.text.trim().toLowerCase() ==
          correctWord.toLowerCase()) {
        errorMessage = null;
        // Move to the next word (mocked for now)
        _answerController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đúng rồi! Chuyển sang từ tiếp theo.')),
        );
      } else {
        errorMessage = 'Sai rồi! Thử lại nhé.';
      }
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Luyện tập: Nghe chính tả'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn chế độ luyện tập:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    items: const [
                      DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả')),
                      DropdownMenuItem(
                          value: 'Trừ các từ đã bỏ qua',
                          child: Text('Trừ các từ đã bỏ qua')),
                      DropdownMenuItem(
                          value: 'Chỉ những từ làm sai',
                          child: Text('Chỉ những từ làm sai')),
                    ],
                    onChanged: (value) {},
                    value: 'Tất cả',
                    underline: const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Lựa chọn từ để luyện',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
              const Text(
                'Xem danh sách các từ bị bỏ qua / sai',
                style: TextStyle(color: Colors.blue, fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Audio Player Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_circle_filled,
                          color: Colors.blue, size: 30),
                      onPressed: () {
                        // Mock audio playback
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: 0,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: const Text(
                        '00:00',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.volume_up,
                              color: Colors.grey, size: 24),
                          onPressed: () {
                            // Toggle sound
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings,
                              color: Colors.grey, size: 24),
                          onPressed: () {
                            // Open settings
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    'Audio 2 (US)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.volume_up, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'đường hầm',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (showVietnameseMeaning) ...[
                const Text(
                  '= a tunnel under the road for people to walk through',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const Text(
                  '/ˈPHien âm/',
                  style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54),
                ),
              ],
              const SizedBox(height: 16),

              // Input and Action Section
              TextField(
                controller: _answerController,
                decoration: InputDecoration(
                  hintText: 'Nhập từ bạn nghe được',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorText: errorMessage,
                ),
                onSubmitted: (value) {
                  checkAnswer();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: checkAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Check kết quả'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: showVietnameseMeaning,
                        onChanged: (value) {
                          setState(() {
                            showVietnameseMeaning = value;
                          });
                        },
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                      const Text('Hiển nghĩa tiếng Việt'),
                    ],
                  ),
                  Row(
                    children: [
                      Switch(
                        value: autoReplay,
                        onChanged: (value) {
                          setState(() {
                            autoReplay = value;
                          });
                        },
                        activeColor: Colors.blue,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey[300],
                      ),
                      const Text('Auto replay'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Từ tiếp theo',
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Đã biết, bỏ qua và không test từ này nữa',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Instructions Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.yellow[50],
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• List gồm 55 từ',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '• Để check đáp án, bạn gõ từ bạn nghe được và bấm Enter. Sau đó bạn click vào hình là có thể check.',
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '• Từ vững sẽ xuất hiện dưới đây sau khi bạn check đáp án hoặc chuyển câu',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
