class CourseTeacher {
  final int id;
  final String name;
  final String credentials;

  CourseTeacher(
      {required this.id, required this.name, required this.credentials});

  factory CourseTeacher.fromJson(Map<String, dynamic> json) {
    return CourseTeacher(
      id: json['id'],
      name: json['name'],
      credentials: json['credentials'],
    );
  }
}
