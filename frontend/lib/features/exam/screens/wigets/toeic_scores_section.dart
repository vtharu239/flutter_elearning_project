import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';

class ToeicScoresSection extends StatelessWidget {
  final Map<String, dynamic> toeicScores;

  const ToeicScoresSection({super.key, required this.toeicScores});

  Widget _buildToeicScoreCard({
    required String title,
    required String score,
    required String maxScore,
    required String correct,
    required String total,
    Color? color,

  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.blue,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "$score/$maxScore",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Trả lời đúng: $correct/$total",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildToeicScoreCard(
          title: 'Listening',
          score: '${toeicScores['listening']['score']}',
          maxScore: '${toeicScores['listening']['maxScore']}',
          correct: '${toeicScores['listening']['correct']}',
          total: '${toeicScores['listening']['total']}',
          color: darkMode ? Colors.grey[800] : Colors.white,
        ),
        _buildToeicScoreCard(
          title: 'Reading',
          score: '${toeicScores['reading']['score']}',
          maxScore: '${toeicScores['reading']['maxScore']}',
          correct: '${toeicScores['reading']['correct']}',
          total: '${toeicScores['reading']['total']}',
          color: darkMode ? Colors.grey[800] : Colors.white,
        ),
      ],
    );
  }
}
