class Course {
  final int id;
  final String title;
  final String description;
  final double rating;
  final int ratingCount;
  final int studentCount;
  final double originalPrice;
  final double discountPercentage;
  final String? imageUrl;
  final int categoryId;
  final String? categoryName;
  final int topics;
  final int lessons;
  final int exercises;
  final int validity;
  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.rating,
    required this.ratingCount,
    required this.studentCount,
    required this.originalPrice,
    required this.discountPercentage,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
    required this.topics,
    required this.lessons,
    required this.exercises,
    required this.validity,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      rating: _parseDouble(json['rating']),
      ratingCount: _parseInt(json['ratingCount']),
      studentCount: _parseInt(json['studentCount']),
      originalPrice: _parseDouble(json['originalPrice']),
      discountPercentage: _parseDouble(json['discountPercentage']),
      categoryId: _parseInt(json['categoryId']),
      categoryName: json['categoryName'],
      topics: _parseInt(json['topics']),
      lessons: _parseInt(json['lessons']),
      exercises: _parseInt(json['exercises']),
      validity: _parseInt(json['validity']),
    );
  }
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
