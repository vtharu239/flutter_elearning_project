
class CourseReview {
  final int id;
  final String userName;
  final String userInfo;
  final String comment;

  CourseReview({
    required this.id,
    required this.userName,
    required this.userInfo,
    required this.comment,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: json['id'],
      userName: json['userName'],
      userInfo: json['userInfo'],
      comment: json['comment'],
    );
  }
}
