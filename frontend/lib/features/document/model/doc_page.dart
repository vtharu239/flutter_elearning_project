import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/doc_list_model.dart';
import 'package:flutter_elearning_project/features/document/screens/doc_list_view.dart';

class DocPage extends StatefulWidget {
  const DocPage({super.key});

  @override
  State<DocPage> createState() => _DocPageState();
}

class _DocPageState extends State<DocPage> {
  final List<DocumentsListItem> items = [
    DocumentsListItem(
        id: 1,
        category: "IELTS MATERIALS",
        title: "The Key to IELTS Success",
        description: "Sách hướng dẫn chiến lược đạt điểm cao IELTS...",
        imageUrl: "assets/doc/thekeytoieltssuccess.png",
        commentCount: 3,
        author: "hhhh",
        date: "2/1/2022"),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return DocumentsListView(item: item);
        });
  }
}