import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';
import 'package:flutter_elearning_project/features/document/model/doc_list_model.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_detailview.dart';
import 'package:flutter_elearning_project/features/document/date_utils.dart';

class RelatedArticleList extends StatelessWidget {
  final List<RelatedArticle> relatedArticles;

  const RelatedArticleList({super.key, required this.relatedArticles});

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
                    child: article.imageUrl.startsWith("http")
                        ? Image.network(article.imageUrl, fit: BoxFit.cover)
                        : Image.asset(article.imageUrl, fit: BoxFit.cover)),
                title: Text(article.title,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text(
                      "${formatVietnamDateFromString(article.date)} bởi ${article.author}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentDetailScreen(
                        document: DocumentsListItem(
                          id: article.id,
                          categoryId: article.categoryId,
                          category: '', // nếu chưa cần thì tạm thời để rỗng
                          title: article.title,
                          description: article.description,
                          imageUrl: article.imageUrl,
                          author: article.author,
                          commentCount: 0, // nếu không truyền cũng được
                          date:
                              DateTime.tryParse(article.date) ?? DateTime.now(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
