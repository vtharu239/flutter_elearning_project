class CourseObjective {
  final int id;
  final String description;

  CourseObjective({required this.id, required this.description});

  factory CourseObjective.fromJson(Map<String, dynamic> json) {
    return CourseObjective(
      id: json['id'],
      description: json['objective'],
    );
  }
}
