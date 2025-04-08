class RelatedArticle {
  final int id;
  final int categoryId;
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String date;

  RelatedArticle({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.date,
  });

  factory RelatedArticle.fromJson(Map<String, dynamic> json) {
    return RelatedArticle(
      id: json['id'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      author: json['author'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
