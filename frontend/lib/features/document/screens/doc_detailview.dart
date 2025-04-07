import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/RelatedArticle_model.dart';
import 'package:flutter_elearning_project/features/document/model/doc_list_model.dart';
import 'package:flutter_elearning_project/features/document/screens/cmt_section.dart';
import 'package:flutter_elearning_project/features/document/screens/related_article_list.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:intl/intl.dart';

// ✅ Import widget bo góc style đẹp
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';

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
      print('Lỗi: $e');
      setState(() => isLoadingRelated = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.title),
        backgroundColor: TColors.primary,
        foregroundColor: Colors.white,
      ),
      body: TPrimaryHeaderContainer(
        child: Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 18, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(doc.author,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(formatVietnamDate(doc.date),
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: doc.imageUrl.startsWith('http')
                          ? Image.network(
                              doc.imageUrl,
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              doc.imageUrl,
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 200,
                              fit: BoxFit.cover,
                            )),
                ),
                const SizedBox(height: 16),
                Text(doc.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                isLoadingRelated
                    ? const Center(child: CircularProgressIndicator())
                    : RelatedArticleList(relatedArticles: relatedArticles),
                const SizedBox(height: 24),
                CommentSection(documentId: doc.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatVietnamDate(DateTime utcDate) {
    final vn = utcDate.add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(vn);
  }
}
