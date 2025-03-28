
class DocumentsListItem {
  final int id;
  final String category;
  final String title;
  final String description;
  final String imageUrl;
  final int commentCount;
  final String author;
  final String date;

  DocumentsListItem({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.commentCount,
    required this.author,
    required this.date,
  });
}