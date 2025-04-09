import 'package:flutter/material.dart';

class EditTabContent extends StatefulWidget {
  final Map<String, List<String>> tasks;
  final Function(String group, String task) onAddTask;
  final Function(String group, int index) onDeleteTask;

  const EditTabContent({
    super.key,
    required this.tasks,
    required this.onAddTask,
    required this.onDeleteTask,
  });

  @override
  State<EditTabContent> createState() => _EditTabContentState();
}

class _EditTabContentState extends State<EditTabContent> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    widget.tasks.keys.forEach((group) {
      _controllers[group] = TextEditingController();
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.tasks.keys.map((group) {
        final tasks = widget.tasks[group]!;

        return Card(
          color: Colors.lightBlue.shade50,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tiêu đề nhóm
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      group,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                /// Input thêm task
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[group],
                        decoration: const InputDecoration(
                          hintText: ' Thêm task',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            widget.onAddTask(group, value.trim());
                            _controllers[group]!.clear();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final value = _controllers[group]!.text.trim();
                        if (value.isNotEmpty) {
                          widget.onAddTask(group, value);
                          _controllers[group]!.clear();
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// Danh sách task
                ...tasks.asMap().entries.map((entry) {
                  final i = entry.key;
                  final task = entry.value;

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.drag_indicator),
                    title: Text(task),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => widget.onDeleteTask(group, i),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
