import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';
import 'package:flutter_elearning_project/features/document/model/doc_list_model.dart';
import 'package:flutter_elearning_project/features/document/screens/cmt_section.dart';
import 'package:flutter_elearning_project/features/document/screens/related_article_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:intl/intl.dart';

class DocumentDetailScreen extends StatefulWidget {
  final DocumentsListItem document;

  const DocumentDetailScreen({super.key, required this.document});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  List<RelatedArticle> relatedArticles = [];
  bool isLoadingRelated = true;

  @override
  void initState() {
    super.initState();
    loadRelated();
  }

  @override
  void didUpdateWidget(covariant DocumentDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.id != widget.document.id) {
      setState(() {
        isLoadingRelated = true;
        relatedArticles.clear();
      });
      loadRelated();
    }
  }

  Future<void> loadRelated() async {
    try {
      final uri = Uri.parse(ApiConstants.getUrl(ApiConstants.getAllDocuments))
          .replace(queryParameters: {
        'categoryId': widget.document.categoryId.toString()
      });

      final response = await http.get(uri, headers: ApiConstants.getHeaders());

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          relatedArticles = data
              .map((e) => RelatedArticle.fromJson(e))
              .where((article) => article.id != widget.document.id)
              .toList();
          isLoadingRelated = false;
        });
      } else {
        throw Exception('Lỗi tải bài viết liên quan');
      }
    } catch (e) {
      log('Lỗi: $e');
      setState(() => isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(doc.title),
      ),
      backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person,
                          size: 22,
                          color: darkMode ? Colors.white : Colors.black),
                      const SizedBox(width: 6),
                      Text(
                        doc.author,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: darkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(width: 36),
                      Icon(Icons.calendar_today,
                          size: 20,
                          color: darkMode ? Colors.white : Colors.black),
                      const SizedBox(width: 6),
                      Text(formatVietnamDate(doc.date),
                          style: TextStyle(
                              color: darkMode ? Colors.white : Colors.black,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: doc.imageUrl.startsWith('http')
                        ? Image.network(
                            doc.imageUrl,
                            width: MediaQuery.of(context).size.width * 4.5,
                            height: 400,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            doc.imageUrl,
                            width: MediaQuery.of(context).size.width * 4.5,
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(doc.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  isLoadingRelated
                      ? const Center(child: CircularProgressIndicator())
                      : RelatedArticleList(relatedArticles: relatedArticles),
                  const SizedBox(height: 20),
                  CommentSection(documentId: doc.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatVietnamDate(DateTime utcDate) {
    final vn = utcDate.add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(vn);
  }
}
