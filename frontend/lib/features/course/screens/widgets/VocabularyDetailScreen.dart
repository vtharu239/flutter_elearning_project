import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/controller/CourseCurriculumItem.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VocabularyDetailScreen extends StatelessWidget {
  final List<VocabularyWord> vocabularyWords;
  final String subItemName;
  final FlutterTts flutterTts = FlutterTts();

  VocabularyDetailScreen({
    super.key,
    required this.vocabularyWords,
    required this.subItemName,
  }) {
    flutterTts.setLanguage('en-US'); // Mặc định là US
  }

  Future<void> _speak(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subItemName),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: vocabularyWords.isEmpty
          ? const Center(child: Text('Không có từ vựng nào.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vocabularyWords.length,
              itemBuilder: (context, index) {
                final word = vocabularyWords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              word.word,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () {
                                    _speak(word.word, 'en-GB'); // Phát âm UK
                                  },
                                  tooltip: 'Phát âm UK',
                                ),
                                const Text('UK'),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () {
                                    _speak(word.word, 'en-US'); // Phát âm US
                                  },
                                  tooltip: 'Phát âm US',
                                ),
                                const Text('US'),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Định nghĩa:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          word.definition,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '= ${word.explanation ?? 'a person responsible for the money in a business'}',
                          style: const TextStyle(
                              fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ví dụ:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),

                        if (word.examples.isNotEmpty)
                          ...word.examples.map((example) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.volume_up,
                                      size: 20,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        example as String,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        const SizedBox(height: 16),
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://via.placeholder.com/150'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
