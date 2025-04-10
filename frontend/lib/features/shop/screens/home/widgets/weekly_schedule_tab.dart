import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyScheduleTab extends StatefulWidget {
  final Map<DateTime, List<String>> tasksByDate;

  const WeeklyScheduleTab({super.key, required this.tasksByDate});

  @override
  State<WeeklyScheduleTab> createState() => _WeeklyScheduleTabState();
}

class _WeeklyScheduleTabState extends State<WeeklyScheduleTab> {
  late Map<DateTime, List<bool>> checkStatus;

  @override
  void initState() {
    super.initState();
    checkStatus = {
      for (var date in widget.tasksByDate.keys)
        date: List.filled(widget.tasksByDate[date]!.length, false)
    };
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final sortedDates = widget.tasksByDate.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: sortedDates.map((date) {
          final tasks = widget.tasksByDate[date]!;
          final checks = checkStatus[date]!;

          return Container(
            width: 240,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.blueGrey[800] : Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...tasks.asMap().entries.map((entry) {
                  final i = entry.key;
                  final task = entry.value;

                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(task, style: const TextStyle(fontSize: 13)),
                    value: checks[i],
                    onChanged: (val) {
                      setState(() {
                        checks[i] = val ?? false;
                      });
                    },
                  );
                }),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('EEEE, dd-MM-yyyy', 'vi_VN');
    return formatter.format(date);
  }
}
