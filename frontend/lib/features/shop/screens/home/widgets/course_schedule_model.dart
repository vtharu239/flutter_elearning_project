class TaskItem {
  String title;
  bool checked;

  TaskItem({required this.title, this.checked = false});

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      title: json['title'],
      checked: json['checked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'checked': checked,
      };
}

class WeeklyGroup {
  String day;
  List<TaskItem> tasks;

  WeeklyGroup({required this.day, required this.tasks});

  factory WeeklyGroup.fromJson(Map<String, dynamic> json) {
    return WeeklyGroup(
      day: json['day'],
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
}

class CustomTabGroup {
  String name;
  List<TaskItem> tasks;

  CustomTabGroup({required this.name, required this.tasks});

  factory CustomTabGroup.fromJson(Map<String, dynamic> json) {
    return CustomTabGroup(
      name: json['name'],
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => TaskItem.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
}

class CourseScheduleModel {
  int id;
  int courseId;
  List<TaskItem> daily;
  List<WeeklyGroup> weekly;
  List<CustomTabGroup> customTabs;

  CourseScheduleModel({
    required this.id,
    required this.courseId,
    required this.daily,
    required this.weekly,
    required this.customTabs,
  });

  factory CourseScheduleModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return CourseScheduleModel(
      id: json['id'],
      courseId: json['courseId'],
      daily: (data['daily'] as Map<String, dynamic>? ?? {})
          .entries
          .expand((entry) => (entry.value as List<dynamic>)
              .map((e) => TaskItem(title: e.toString())))
          .toList(),
      weekly: (data['weekly'] as List<dynamic>? ?? [])
          .map((e) => WeeklyGroup.fromJson(e))
          .toList(),
      customTabs: (data['customTabs'] as List<dynamic>? ?? [])
          .map((e) => CustomTabGroup.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'data': {
          'daily': daily.map((e) => e.toJson()).toList(),
          'weekly': weekly.map((e) => e.toJson()).toList(),
          'customTabs': customTabs.map((e) => e.toJson()).toList(),
        },
      };
}
