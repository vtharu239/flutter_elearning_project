class Comment {
  final int id;
  final int userId;
  final String username;
  final String fullName;
  final String content;
  final String date;
  final int? parentId;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.content,
    required this.date,
    this.parentId,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      fullName: json['fullName'],
      content: json['content'],
      date: json['date'],
      parentId: json['parentId'],
      replies: (json['replies'] ?? [])
          .map<Comment>((r) => Comment.fromJson(r))
          .toList(),
    );
  }
}
