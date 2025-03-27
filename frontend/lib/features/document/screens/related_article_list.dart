import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';

class RelatedArticleList extends StatelessWidget {
  final List<RelatedArticle> relatedArticles;

  RelatedArticleList({required this.relatedArticles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Các bài viết cùng chủ đề",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Column(
          children: relatedArticles.map((article) {
            return Card(
              color: Color(0xFFEAF4FF),
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    "assets/doc/thekeytoieltssuccess.png${article.imageUrl}", // Đường dẫn đến ảnh trong thư mục assets
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(article.title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text("${article.date} bởi ${article.author}",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () {
                  // Chuyển đến bài viết chi tiết khác
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}