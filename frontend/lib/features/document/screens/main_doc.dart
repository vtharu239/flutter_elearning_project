import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/category_model.dart';
import 'package:flutter_elearning_project/features/document/screens/cate_detail.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_list.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_list_view.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_detailview.dart';

class MainDocScreen extends StatefulWidget {
  const MainDocScreen({super.key});

  @override
  State<MainDocScreen> createState() => _MainDocScreenState();
}

class _MainDocScreenState extends State<MainDocScreen> {
  Map<String, bool> expandedCategories = {};

  @override
  void initState() {
    super.initState();
    for (var category in categories) {
      expandedCategories[category.title] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tài liệu - STUDYMATE"),
        backgroundColor: const Color.fromARGB(255, 49, 75, 226),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề tổng hợp tài liệu
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "TỔNG HỢP TÀI LIỆU:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            // Danh sách tài liệu
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final doc = documents[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DocumentDetailScreen(document: doc),
                      ),
                    );
                  },
                  child: DocumentsListView(item: doc),
                );
              },
            ),
            const SizedBox(height: 16),

            // Tiêu đề danh mục
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Chuyên mục",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Danh sách danh mục
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isExpanded = expandedCategories[category.title] ?? false;

                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.black,
                      ),
                      onTap: () {
                        setState(() {
                          expandedCategories[category.title] = !isExpanded;
                        });
                      },
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: category.subCategories.map((subCat) {
                            return ListTile(
                              title: Text(
                                subCat,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                // Điều hướng đến CategoryDetailScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryDetailScreen(
                                        category: category),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    const Divider(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}