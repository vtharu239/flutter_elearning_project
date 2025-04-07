import 'package:flutter/material.dart';

class DetailedAnalysisSection extends StatelessWidget {
  final List<dynamic> parts;
  final Map<String, Map<String, dynamic>> tagStats;
  final int currentPartIndex;
  final void Function(int) onPartSelected;

  const DetailedAnalysisSection({
    super.key,
    required this.parts,
    required this.tagStats,
    required this.currentPartIndex,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân tích chi tiết:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: parts.asMap().entries.map((entry) {
              final index = entry.key;
              final part = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    part['title'],
                    style: TextStyle(
                      color: currentPartIndex == index ? Colors.white : Colors.black,
                    ),
                  ),
                  selected: currentPartIndex == index,
                  selectedColor: Colors.blue,
                  backgroundColor: Colors.grey[200],
                  onSelected: (selected) {
                    if (selected) {
                      onPartSelected(index);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.white,
          elevation: 1,
          shadowColor: Colors.blue,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Phân loại câu hỏi')),
                DataColumn(label: Text('Số câu đúng')),
                DataColumn(label: Text('Số câu sai')),
                DataColumn(label: Text('Số câu bỏ qua')),
                DataColumn(label: Text('Độ chính xác')),
                DataColumn(label: Text('Danh sách câu hỏi')),
              ],
              rows: [
                ...tagStats.entries
                    .where((entry) =>
                        entry.key.contains(parts[currentPartIndex]['title']))
                    .map(
                  (entry) {
                    final tag = entry.key;
                    final stats = entry.value;
                    final accuracy =
                        (stats['correct'] / stats['total'] * 100).toStringAsFixed(2);

                    final sequentialQuestionIds =
                        stats['questionIds'].map((id) => id.toString()).join(', ');

                    return DataRow(
                      cells: [
                        DataCell(Text(tag)),
                        DataCell(Text(stats['correct'].toString())),
                        DataCell(Text(stats['wrong'].toString())),
                        DataCell(Text(stats['skipped'].toString())),
                        DataCell(Text('$accuracy%')),
                        DataCell(Text(sequentialQuestionIds)),
                      ],
                    );
                  },
                ),
                () {
                  final filteredStats = tagStats.entries.where(
                      (entry) => entry.key.contains(parts[currentPartIndex]['title']));
                  final totalStats = filteredStats.fold<Map<String, int>>(
                    {'correct': 0, 'wrong': 0, 'skipped': 0, 'total': 0},
                    (acc, entry) {
                      acc['correct'] = acc['correct']! + (entry.value['correct'] as int);
                      acc['wrong'] = acc['wrong']! + (entry.value['wrong'] as int);
                      acc['skipped'] =
                          acc['skipped']! + (entry.value['skipped'] as int);
                      acc['total'] = acc['total']! + (entry.value['total'] as int);
                      return acc;
                    },
                  );

                  final totalAccuracy = totalStats['total']! > 0
                      ? (totalStats['correct']! / totalStats['total']! * 100)
                          .toStringAsFixed(2)
                      : '0.00';

                  return DataRow(cells: [
                    DataCell(Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      totalStats['correct'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      totalStats['wrong'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      totalStats['skipped'].toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text(
                      '$totalAccuracy%',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataCell(Text('')),
                  ]);
                }(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}