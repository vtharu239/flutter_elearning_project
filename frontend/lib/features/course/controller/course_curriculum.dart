import 'package:flutter_elearning_project/features/course/controller/curriculum_feature.dart';

class CourseCurriculum {
  final int courseId;
  final String title;
  final double? rating;
  final int? reviews;
  final int? students;
  final List<CurriculumFeature> features;

  CourseCurriculum({
    required this.courseId,
    required this.title,
    this.rating,
    this.reviews,
    this.students,
    this.features = const [],
  });

  factory CourseCurriculum.fromJson(Map<String, dynamic> json) {
    return CourseCurriculum(
      courseId: json['courseId'],
      title: json['title'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      reviews: json['reviews'],
      students: json['students'],
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => CurriculumFeature.fromJson(e))
              .toList() ??
          [],
    );
  }
}
