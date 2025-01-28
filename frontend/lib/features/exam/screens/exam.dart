import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/search_container.dart';
import 'package:flutter_elearning_project/features/exam/screens/wigets/exam_appbar.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class ExamScreen extends StatelessWidget {
  const ExamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TExamAppBar(),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  
                  // Search bar with filter button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                    child: Row(
                      children: [
                        const Expanded(
                          child: TSerachContainer(text: 'Tìm kiếm đề thi...'),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        IconButton(
                          onPressed: () => _showFilterBottomSheet(context),
                          icon: const Icon(Icons.filter_list, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Subject grid
                  Padding(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Column(
                      children: [
                        const TSectionHeading(
                          title: 'Môn học',
                          showActionButton: false,
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 4,
                          mainAxisSpacing: TSizes.gridViewSpacing,
                          crossAxisSpacing: TSizes.gridViewSpacing,
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            _SubjectCard(
                              icon: Icons.calculate,
                              title: 'Toán học',
                              examCount: 150,
                            ),
                            _SubjectCard(
                              icon: Icons.science,
                              title: 'Vật lý',
                              examCount: 120,
                            ),
                            _SubjectCard(
                              icon: Icons.science_outlined,
                              title: 'Hóa học',
                              examCount: 100,
                            ),
                            _SubjectCard(
                              icon: Icons.language,
                              title: 'Tiếng Anh',
                              examCount: 200,
                            ),
                            _SubjectCard(
                              icon: Icons.history_edu,
                              title: 'Lịch sử',
                              examCount: 80,
                            ),
                            _SubjectCard(
                              icon: Icons.public,
                              title: 'Địa lý',
                              examCount: 90,
                            ),
                            _SubjectCard(
                              icon: Icons.psychology,
                              title: 'GDCD',
                              examCount: 70,
                            ),
                            _SubjectCard(
                              icon: Icons.biotech,
                              title: 'Sinh học',
                              examCount: 110,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body content
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort dropdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Sắp xếp theo: '),
                      DropdownButton<String>(
                        value: 'newest',
                        items: const [
                          DropdownMenuItem(value: 'newest', child: Text('Mới nhất')),
                          DropdownMenuItem(value: 'popular', child: Text('Phổ biến nhất')),
                          DropdownMenuItem(value: 'difficulty', child: Text('Độ khó')),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  
                  // Featured Exams Section
                  const TSectionHeading(
                    title: 'Đề thi nổi bật',
                    showActionButton: true,
                    buttonTitle: 'Xem tất cả',
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _FeaturedExamsList(),
                  
                  const SizedBox(height: TSizes.spaceBtwSections),
                  
                  // Recent Exams Section
                  const TSectionHeading(
                    title: 'Đề thi gần đây',
                    showActionButton: true,
                    buttonTitle: 'Xem tất cả',
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  _RecentExamsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  final List<String> selectedSubjects = [];
  String selectedDifficulty = 'all';
  String selectedType = 'all';
  RangeValues durationRange = const RangeValues(0, 180);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bộ lọc',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          
          // Difficulty filter
          const Text('Độ khó:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả',
                selected: selectedDifficulty == 'all',
                onSelected: (selected) => setState(() => selectedDifficulty = 'all'),
              ),
              _FilterChip(
                label: 'Dễ',
                selected: selectedDifficulty == 'easy',
                onSelected: (selected) => setState(() => selectedDifficulty = 'easy'),
              ),
              _FilterChip(
                label: 'Trung bình',
                selected: selectedDifficulty == 'medium',
                onSelected: (selected) => setState(() => selectedDifficulty = 'medium'),
              ),
              _FilterChip(
                label: 'Khó',
                selected: selectedDifficulty == 'hard',
                onSelected: (selected) => setState(() => selectedDifficulty = 'hard'),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Exam type filter
          const Text('Loại đề:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Tất cả',
                selected: selectedType == 'all',
                onSelected: (selected) => setState(() => selectedType = 'all'),
              ),
              _FilterChip(
                label: 'Đề thi thử',
                selected: selectedType == 'mock',
                onSelected: (selected) => setState(() => selectedType = 'mock'),
              ),
              _FilterChip(
                label: 'Kiểm tra',
                selected: selectedType == 'test',
                onSelected: (selected) => setState(() => selectedType = 'test'),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Duration range filter
          const Text('Thời gian (phút):', style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: durationRange,
            min: 0,
            max: 180,
            divisions: 18,
            labels: RangeLabels(
              durationRange.start.round().toString(),
              durationRange.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() => durationRange = values);
            },
          ),
          const SizedBox(height: TSizes.spaceBtwItems),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Áp dụng'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int examCount;

  const _SubjectCard({
    required this.icon,
    required this.title,
    required this.examCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(TSizes.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: TSizes.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: TSizes.xs),
              Text(
                '$examCount đề',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String title;
  final String subject;
  final String duration;
  final int questionCount;
  final int attemptCount;
  final String difficulty;
  final double rating;
  final String type;
  final VoidCallback onTap;

  const _ExamCard({
    required this.title,
    required this.subject,
    required this.duration,
    required this.questionCount,
    required this.attemptCount,
    required this.difficulty,
    required this.rating,
    required this.type,
    required this.onTap,
  });

  Color _getDifficultyColor() {
    switch (difficulty.toLowerCase()) {
      case 'dễ':
        return Colors.green;
      case 'trung bình':
        return Colors.orange;
      case 'khó':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
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
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: _getDifficultyColor(),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.sm),
            Row(
              children: [
                _InfoChip(Icons.book, subject),
                const SizedBox(width: TSizes.sm),
                _InfoChip(Icons.timer, duration),
                const SizedBox(width: TSizes.sm),
                _InfoChip(Icons.quiz, '$questionCount câu'),
                const SizedBox(width: TSizes.sm),
                _InfoChip(Icons.category, type),
              ],
            ),
            const SizedBox(height: TSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: TSizes.sm),
                    Text(
                      '$attemptCount lượt thi',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Làm bài'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedExamsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return _ExamCard(
          title: 'Đề thi thử THPT QG 2024 - Lần ${index + 1}',
          subject: 'Toán học',
          duration: '120 phút',
          questionCount: 50,
          attemptCount: 1200,
          difficulty: "Khó",
          rating: 5,
          type: "Toeic",
          onTap: () {},
        );
      },
    );
  }
}

class _RecentExamsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.spaceBtwItems),
      itemBuilder: (context, index) {
        return _ExamCard(
          title: 'Đề kiểm tra 15 phút - Chương ${index + 1}',
          subject: 'Vật lý',
          duration: '15 phút',
          questionCount: 10,
          attemptCount: 450,
           difficulty: "Khó",
          rating: 5,
          type: "Toeic",
          onTap: () {},
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}