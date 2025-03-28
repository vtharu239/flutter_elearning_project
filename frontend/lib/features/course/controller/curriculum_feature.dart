class CurriculumFeature {
  final int curriculumId;
  final String feature;

  CurriculumFeature({required this.curriculumId, required this.feature});

  factory CurriculumFeature.fromJson(Map<String, dynamic> json) {
    return CurriculumFeature(
      curriculumId: json['curriculumId'],
      feature: json['feature'],
    );
  }
}
