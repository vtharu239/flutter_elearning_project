class Comment {
  final String username;
  final String date;
  final String content;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.date,
    required this.content,
    this.replies = const [],
  });
}
