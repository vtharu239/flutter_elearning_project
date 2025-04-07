class DocumentsListItem {
  final int id;
  final int categoryId;
  final String category;
  final String title;
  final String description;
  final String imageUrl;
  final int commentCount;
  final String author;
  final DateTime date;

  DocumentsListItem({
    required this.id,
    required this.categoryId,
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.commentCount,
    required this.author,
    required this.date,
  });
  factory DocumentsListItem.fromJson(Map<String, dynamic> json) {
    return DocumentsListItem(
      id: json['id'],
      categoryId: json['categoryId'],
      category: json['category'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      commentCount: json['commentCount'] ?? 0,
      author: json['author'],
      date: DateTime.parse(json['date']),
    );
  }
}
