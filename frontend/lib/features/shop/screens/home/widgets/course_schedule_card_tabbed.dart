import 'package:flutter/material.dart';
import 'edit_tab_content.dart';
import 'weekly_schedule_tab.dart';

class CourseScheduleCardTabbed extends StatefulWidget {
  final String courseName;
  final String courseType;
  final String frequency;
  final Map<String, List<String>> tasksPerTab;

  const CourseScheduleCardTabbed({
    super.key,
    required this.courseName,
    required this.courseType,
    required this.frequency,
    required this.tasksPerTab,
  });

  @override
  State<CourseScheduleCardTabbed> createState() =>
      _CourseScheduleCardTabbedState();
}

class _CourseScheduleCardTabbedState extends State<CourseScheduleCardTabbed> {
  late Map<String, List<String>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = Map.from(widget.tasksPerTab);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final tabTitles = _tasks.keys.toList();

    return DefaultTabController(
      length: tabTitles.length,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text('Khóa học: ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      widget.courseName,
                      style: TextStyle(
                        color: isDark ? Colors.blue[300] : Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('${widget.courseType}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.frequency),
                  ],
                ),

                const SizedBox(height: 12),
                TabBar(
                  isScrollable: false, //  Không scroll, chia đều
                  labelColor: Colors.blue,
                  unselectedLabelColor:
                      isDark ? Colors.grey[400] : Colors.grey[600],
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  indicatorColor: Colors.blue,
                  indicatorWeight: 3, // gạch dưới dày hơn chút cho rõ
                  tabs: tabTitles
                      .map(
                        (t) => Tab(
                          child: Center(
                            child: Text(
                              t,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 8),

                // Nội dung TabBar
                Expanded(
                  child: TabBarView(
                    children: tabTitles.map((tabTitle) {
                      if (tabTitle == 'Chỉnh sửa') {
                        return EditTabContent(
                          tasks: _tasks,
                          onAddTask: (group, task) {
                            setState(() {
                              _tasks[group]!.add(task);
                            });
                          },
                          onDeleteTask: (group, index) {
                            setState(() {
                              _tasks[group]!.removeAt(index);
                            });
                          },
                        );
                      } else if (tabTitle == 'Theo tuần') {
                        // Tạo dữ liệu mẫu cho tuần
                        final today = DateTime.now();
                        final weekTasks = {
                          for (int i = 0; i < 7; i++)
                            today.add(Duration(days: i)):
                                _tasks.values.expand((e) => e).toList()
                        };

                        return WeeklyScheduleTab(tasksByDate: weekTasks);
                      } else {
                        final tasks = _tasks[tabTitle]!;
                        return _TaskChecklist(tasks: tasks);
                      }
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Active label
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget checklist bên trong tab
class _TaskChecklist extends StatefulWidget {
  final List<String> tasks;

  const _TaskChecklist({required this.tasks});

  @override
  State<_TaskChecklist> createState() => _TaskChecklistState();
}

class _TaskChecklistState extends State<_TaskChecklist> {
  late List<bool> isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = List.generate(widget.tasks.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        return CheckboxListTile(
          title: Text(widget.tasks[index]),
          value: isChecked[index],
          onChanged: (val) {
            setState(() => isChecked[index] = val ?? false);
          },
        );
      },
    );
  }
}
