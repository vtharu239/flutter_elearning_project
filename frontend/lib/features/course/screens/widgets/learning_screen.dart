import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/DictationPracticeScreen.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/FlashcardScreen.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/ListenAndChooseScreen.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/MatchingGameScreen.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/TranslationPracticeScreen.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/VocabularyQuizScreen.dart';

class LearningScreen extends StatefulWidget {
  final String courseTitle;

  const LearningScreen({super.key, required this.courseTitle});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> learningParts = [
    {
      'title': 'TỪ VỰNG TOEIC',
      'progress': 0.0,
    },
    {
      'title': 'NGỮ PHÁP TOEIC',
      'progress': 0.0,
    },
    {
      'title': 'Part 1: Photographs - Nghe tranh',
      'progress': 0.0,
    },
    {
      'title': 'Part 2: Question - Response - Hỏi - đáp',
      'progress': 0.0,
    },
    {
      'title': 'Part 3: Conversations - Nghe hiểu đối thoại',
      'progress': 0.0,
    },
    {
      'title': 'Part 4: Talks - Nghe hiểu bài nói',
      'progress': 0.0,
    },
    {
      'title': 'Part 5: Incomplete Sentences - Điền từ vào câu',
      'progress': 0.0,
    },
    {
      'title': 'Part 6: Text Completion - Điền từ vào đoạn văn',
      'progress': 0.0,
    },
    {
      'title': 'Part 7: Reading Comprehension - Đọc hiểu văn bản',
      'progress': 0.0,
    },
    {
      'title': 'Luyện nghe chep chính tả TOEIC',
      'progress': 0.0,
    },
    {
      'title': 'Ôn tập Flashcards',
      'progress': 0.0,
    },
    {
      'title': 'Gia hạn khóa học',
      'progress': 0.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: learningParts.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: Text(widget.courseTitle),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: learningParts.map((part) {
                return Tab(
                  child: Text(
                    part['title'],
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: learningParts.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> part = entry.value;

                if (index == 0) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          part['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Đạt 0% bài học hoàn tất:',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: part['progress'],
                          backgroundColor: Colors.grey[300],
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 16),
                        Container(
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
                              const Text(
                                'List 1',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildLessonItem(
                                'TỪ VỰNG: Flashcards',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FlashcardScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Trắc nghiệm từ vựng',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VocabularyQuizScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Tìm cặp',
                                false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MatchingGameScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Nghe từ vựng',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ListenAndChooseScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Dịch nghĩa / Diễn từ',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TranslationPracticeScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Nghe chính tả',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DictationPracticeScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
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
                              const Text(
                                'List 2',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildLessonItem(
                                'TỪ VỰNG: Flashcards',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FlashcardScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Trắc nghiệm từ vựng',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VocabularyQuizScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Tìm cặp',
                                false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MatchingGameScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Nghe từ vựng',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ListenAndChooseScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Dịch nghĩa / Diễn từ',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TranslationPracticeScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildLessonItem(
                                'LUYỆN TẬP: Nghe chính tả',
                                true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const DictationPracticeScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        part['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Đạt 0% bài học hoàn tất:',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: part['progress'],
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(String title, bool isCompleted,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            isCompleted
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  )
                : const Icon(
                    Icons.edit,
                    color: Colors.grey,
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
