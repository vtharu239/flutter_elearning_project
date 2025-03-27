class RelatedArticle {
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String date;

  RelatedArticle({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.date,
  });

  // Nếu lấy từ API, có thể thêm phương thức fromJson
  factory RelatedArticle.fromJson(Map<String, dynamic> json) {
    return RelatedArticle(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      author: json['author'],
      date: json['date'],
    );
  }
}