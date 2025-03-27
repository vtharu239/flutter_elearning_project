import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/document/model/category_model.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category; // Nhận category từ danh sách

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.title), // Tiêu đề danh mục
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề danh mục
            Text(
              "Danh mục: ${category.title}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Danh sách sub-category
            const Text(
              "Chủ đề liên quan:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: category.subCategories.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.bookmark, color: Colors.blue),
                    title: Text(category.subCategories[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}