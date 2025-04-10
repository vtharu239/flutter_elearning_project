class CourseReview {
  final int id;
  final String userName;
  final String userInfo;
  final String comment;
  final double rating; // Thêm trường rating
  final String createdAt;

  CourseReview({
    required this.id,
    required this.userName,
    required this.userInfo,
    required this.comment,
    required this.rating, // Thêm vào constructor
    required this.createdAt,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['id'],
      userName: json['userName'],
      userInfo: json['userInfo'],
      comment: json['comment'],
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : double.parse(json['rating'].toString()), // Xử lý chuyển đổi rating
      createdAt: json['createdAt'],
    );
  }
}
