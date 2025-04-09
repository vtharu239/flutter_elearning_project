import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';

class StatsSection extends StatelessWidget {
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final dynamic scaledScore;
  final bool isFullTest;

  const StatsSection({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.scaledScore,
    required this.isFullTest,
  });

  Widget _buildStatCard({
    required Icon icon,
    required String label,
    required Color labelColor,
    required String value,
    required String unit,
    required Color? backgroundColor,
  }) {
    return SizedBox(
      height: 150,
      width: 90,
      child: Card(
        elevation: 2,
        shadowColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: labelColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runSpacing: 2.0,
        children: [
          _buildStatCard(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
            label: 'Trả lời đúng',
            labelColor: Colors.green,
            value: '$correctCount',
            unit: 'câu hỏi',
            backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
          ),
          _buildStatCard(
            icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
            label: 'Trả lời sai',
            labelColor: Colors.red,
            value: '$wrongCount',
            unit: 'câu hỏi',
            backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
          ),
          _buildStatCard(
            icon: const Icon(Icons.remove_circle, color: Colors.grey, size: 32),
            label: 'Bỏ qua',
            labelColor: Colors.grey,
            value: '$skippedCount',
            unit: 'câu hỏi',
            backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
          ),
          if (isFullTest)
            _buildStatCard(
              icon: const Icon(Icons.flag, color: Colors.blue, size: 32),
              labelColor: Colors.blue,
              label: 'Điểm',
              value: scaledScore != null ? '$scaledScore' : 'N/A',
              unit: '',
              backgroundColor: darkMode ? Colors.grey[800] : Colors.white,
            ),
        ],
      ),
    );
  }
}
