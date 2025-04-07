import 'package:flutter/material.dart';

class SummarySection extends StatelessWidget {
  final int correctCount;
  final int totalQuestions;
  final String accuracy;
  final String completionTime;

  const SummarySection({
    super.key,
    required this.correctCount,
    required this.totalQuestions,
    required this.accuracy,
    required this.completionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                const Text('Kết quả làm bài', style: TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  '$correctCount/$totalQuestions',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.percent, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                const Text('Độ chính xác (#đúng/#tổng)',
                    style: TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  '$accuracy%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                const Text('Thời gian hoàn thành',
                    style: TextStyle(fontSize: 16)),
                const Spacer(),
                Text(
                  completionTime,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}