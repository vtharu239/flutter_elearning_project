import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';
import 'package:flutter_elearning_project/features/document/model/doc_list_model.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_detailview.dart';
import 'package:flutter_elearning_project/features/document/date_utils.dart'; // Đảm bảo import này
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';

class RelatedArticleList extends StatelessWidget {
  final List<RelatedArticle> relatedArticles;

  const RelatedArticleList({super.key, required this.relatedArticles});

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TSectionHeading(
          title: 'Các bài viết cùng chủ đề',
          showActionButton: false,
        ),
        const SizedBox(height: 20),
        Column(
          children: relatedArticles.map((article) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentDetailScreen(
                      document: DocumentsListItem(
                        id: article.id,
                        categoryId: article.categoryId,
                        category: '', // Tạm để rỗng nếu không có
                        title: article.title,
                        description: article.description,
                        imageUrl: article.imageUrl,
                        author: article.author,
                        commentCount:
                            0, // Không có trong RelatedArticle, để mặc định 0
                        date: DateTime.tryParse(article.date) ?? DateTime.now(),
                      ),
                    ),
                  ),
                );
              },
              child: Card(
                color: darkMode ? Colors.grey[800] : Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: article.imageUrl.startsWith('http')
                            ? Image.network(
                                article.imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                article.imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category (mặc định "Bài viết liên quan")
                            // const Text(
                            //   'Bài viết liên quan',
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     fontWeight: FontWeight.bold,
                            //     color: Colors.blueGrey,
                            //   ),
                            // ),
                            // const SizedBox(height: 4),
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              article.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${formatVietnamDateFromString(article.date)} bởi ${article.author}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
