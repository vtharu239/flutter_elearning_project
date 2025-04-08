import 'package:flutter/material.dart';

class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

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
        title: const Text('TỪ VỰNG: Flashcards'),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Luyện tập Flashcards" button - Full width
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Handle "Luyện tập Flashcards" action
                },
                style: TextButton.styleFrom(
                  alignment: Alignment.center,
                  foregroundColor: const Color.fromARGB(255, 146, 144, 144),
                  backgroundColor: Colors.white,
                  side: const BorderSide(
                      color: Color.fromARGB(255, 137, 136, 136)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, // Thêm padding ngang để đẹp hơn
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Luyện tập Flashcards',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // "Xem ngẫu nhiên" and "Dừng học list này" buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle "Xem ngẫu nhiên" action
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Xem ngẫu nhiên',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle "Dừng học list này" action
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Dừng học list này',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Tổng số từ', '55', Colors.green),
                _buildStatItem('Đã học', '55', Colors.blue),
                _buildStatItem('Đã nhớ', '55', Colors.purple),
                _buildStatItem('Cần ôn tập', '0', Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'List có 55 từ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Vocabulary item 1: accountant
            _buildVocabularyItem(
              word: 'accountant (n)',
              phonetic: '/əˈkaʊn.tənt/',
              meaning:
                  'Định nghĩa:\nNgười phụ trách kiểm tra và tính toán trong một doanh nghiệp, kế toán',
              examples: [
                'My [accountant] takes care of the taxes (E-Dịch: Kế toán của tôi lo liệu các loại thuế).',
                'Trainee [accountants] average £12,000 per year (E-Dịch: Thực tập sinh kế toán trung bình kiếm được 12,000 bảng Anh mỗi năm).',
                '[His accountant] had aided and abetted him in the fraud (E-Dịch: Kế toán của anh ấy đã giúp đỡ và tiếp tay cho anh ấy trong vụ lừa đảo).',
                'Dịch: Kế toán của anh ấy đã giúp đỡ và tiếp tay cho anh ấy trong vụ lừa đảo vì anh ấy không có đủ kỹ năng để làm việc này một mình.',
              ],
            ),
            const SizedBox(height: 16),
            // Vocabulary item 2: airport
            _buildVocabularyItem(
              word: 'airport (n)',
              phonetic: '/ˈeə.pɔːt/',
              meaning: 'Định nghĩa:\nSân bay',
              examples: [
                '[Security checks] have become really strict at the [airport] (E-Dịch: Kiểm tra an ninh ở sân bay đã trở nên rất nghiêm ngặt).',
                'I checked online and saw that the plane had already touched down at the [airport] (E-Dịch: Tôi đã kiểm tra trực tuyến và thấy rằng máy bay đã hạ cánh tại sân bay).',
                'One of our representatives will meet you at the [airport] and take you to your hotel (E-Dịch: Một trong những đại diện của chúng tôi sẽ gặp bạn tại sân bay và đưa bạn đến khách sạn của bạn).',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularyItem({
    required String word,
    required String phonetic,
    required String meaning,
    required List<String> examples,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  // Handle audio playback for the word
                },
              ),
            ],
          ),
          Text(
            phonetic,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            meaning,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ví dụ:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...examples.map((example) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(
                        example,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: FlashcardScreen(),
  ));
}
