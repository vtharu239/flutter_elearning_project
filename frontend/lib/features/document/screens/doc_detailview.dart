import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';
import 'package:flutter_elearning_project/features/document/model/doc_list_model.dart';
import 'package:flutter_elearning_project/features/document/screens/cmt_section.dart';
import 'package:flutter_elearning_project/features/document/screens/related_article_list.dart';

class DocumentDetailScreen extends StatelessWidget {
  final DocumentsListItem document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final List<RelatedArticle> relatedArticles = [
      RelatedArticle(
        title:
            "Describe a time you visited a new place - Bài mẫu IELTS Speaking",
        description: "Hãy tham khảo bài mẫu 8.0+ chủ đề này...",
        imageUrl: "https://via.placeholder.com/80",
        author: "Bùi Hằng",
        date: "08/03/2025",
      ),
      RelatedArticle(
        title: "Describe a story someone told you and you remember",
        description: "Hãy tham khảo bài mẫu 8.0+ chủ đề này...",
        imageUrl: "https://via.placeholder.com/80",
        author: "Bùi Hằng",
        date: "08/03/2025",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin tài liệu
            Text(document.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.black54),
                const SizedBox(width: 4),
                Text(document.author,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.black54),
                const SizedBox(width: 4),
                Text(document.date,
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 16),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/doc/thekeytoieltssuccess.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(document.description, style: const TextStyle(fontSize: 16)),

            // Hiển thị danh sách bài viết cùng chủ đề
            RelatedArticleList(relatedArticles: relatedArticles),

            // Hiển thị bình luận
            const CommentSection(),
          ],
        ),
      ),
    );
  }
}
